import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import 'game_state.dart';

/// What the player is holding after a click.
@immutable
class Selection {
  const Selection(this.pile, this.count);

  final Pile pile;
  final int count;
}

class _Snapshot {
  const _Snapshot(this.state, this.moves, this.score);

  final GameState state;
  final int moves;
  final int score;
}

/// A game in progress: the table, the score and the undo history.
class GameController extends ChangeNotifier {
  GameController({
    int? number,
    this.collectDelay = const Duration(milliseconds: 130),
    SoundBoard? sounds,
  }) : number = number ?? _randomNumber(),
       state = GameState.deal(number ?? 1),
       sounds = sounds ?? GameSounds.shared {
    state = GameState.deal(this.number);
  }

  static int _randomNumber() => Random().nextInt(999999) + 1;

  static const _recyclePenalty = 100;

  /// The pause between cards when the game finishes itself.
  final Duration collectDelay;

  /// Where the sounds of the table go.
  final SoundBoard sounds;

  /// When a moved card reaches its place, a little before the end of its
  /// flight.
  static const landing = Duration(milliseconds: 240);

  int number;
  GameState state;
  int moves = 0;
  int score = 0;
  Selection? selected;

  /// The cards of the latest move, drawn above the others while they travel.
  Set<int> lastMoved = const {};

  /// The cards of the latest refused move. [rejectTick] tells them to shake.
  Set<int> rejected = const {};
  int rejectTick = 0;

  final List<_Snapshot> _history = [];
  final Stopwatch _clock = Stopwatch();
  Timer? _collectTimer;

  bool get canUndo => _history.isNotEmpty;

  /// The time played, from the first move until the win.
  int get seconds => _clock.elapsed.inSeconds;

  /// Lands the cards of a move from [before], turns over the card they
  /// leave uncovered, and ends the game when it is won.
  void _landed(GameState before) {
    sounds.play(GameSound.place, delay: landing);
    final turned = Iterable.generate(
      before.hidden.length,
    ).any((i) => state.hidden[i] < before.hidden[i]);
    if (turned) {
      sounds.play(GameSound.flip, delay: landing + const Duration(milliseconds: 120));
    }
    if (state.isWon && !before.isWon) {
      _clock.stop();
      sounds.play(GameSound.victory, delay: landing * 2);
    }
  }

  void newGame([int? number]) {
    this.number = number ?? _randomNumber();
    _restart();
  }

  void restart() => _restart();

  void _restart() {
    _collectTimer?.cancel();
    _clock
      ..stop()
      ..reset();
    state = GameState.deal(number);
    moves = 0;
    score = 0;
    selected = null;
    lastMoved = const {};
    rejected = const {};
    _history.clear();
    sounds.play(GameSound.shuffle);
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty) return;
    _collectTimer?.cancel();
    final snapshot = _history.removeLast();
    state = snapshot.state;
    moves = snapshot.moves;
    score = snapshot.score;
    selected = null;
    lastMoved = const {};
    sounds.play(GameSound.place);
    notifyListeners();
  }

  void clearSelection() {
    if (selected == null) return;
    selected = null;
    notifyListeners();
  }

  void _remember() => _history.add(_Snapshot(state, moves, score));

  void _addScore(int points) => score = max(0, score + points);

  void _reject(Iterable<PlayingCard> cards) {
    sounds.play(GameSound.refuse);
    rejected = {for (final card in cards) card.id};
    rejectTick++;
    selected = null;
    notifyListeners();
  }

  /// Refuses a pick up: the cards from [index] down are not a sequence.
  void rejectPick(Pile pile, int index) {
    if (pile.kind != PileKind.column) return;
    _reject(state.columns[pile.index].sublist(index));
  }

  /// Draws from the stock, or turns the waste over when the stock is empty.
  void draw() {
    final recycling = state.stock.isEmpty;
    final next = state.draw();
    if (next == null) return;
    final drawn = recycling ? const <int>{} : {state.stock.last.id};
    _remember();
    state = next;
    moves++;
    if (recycling) _addScore(-_recyclePenalty);
    sounds.play(recycling ? GameSound.deal : GameSound.flip);
    selected = null;
    lastMoved = drawn;
    rejected = const {};
    _clock.start();
    notifyListeners();
  }

  /// Moves the cards, or makes them shake if the rules do not allow it.
  bool moveCards(Pile from, int count, Pile to) {
    final next = state.move(from, count, to);
    if (next == null) {
      if (state.canPick(from, count)) _reject(state.cardsFrom(from, count));
      return false;
    }
    final moved = {for (final card in state.cardsFrom(from, count)) card.id};
    _remember();
    _addScore(state.pointsFor(from, to, next));
    final before = state;
    state = next;
    moves++;
    selected = null;
    lastMoved = moved;
    rejected = const {};
    _clock.start();
    _landed(before);
    notifyListeners();
    _finishIfPossible();
    return true;
  }

  int _countFrom(Pile pile, int index) => pile.kind == PileKind.column
      ? state.columns[pile.index].length - index
      : 1;

  /// A click on the card at [index] of [pile].
  void tapCard(Pile pile, int index) {
    final held = selected;
    if (held != null) {
      if (held.pile == pile) {
        clearSelection();
      } else {
        moveCards(held.pile, held.count, pile);
      }
      return;
    }
    if (pile.kind == PileKind.column && index < state.hidden[pile.index]) {
      return;
    }
    final count = _countFrom(pile, index);
    if (!state.canPick(pile, count)) {
      rejectPick(pile, index);
      return;
    }
    selected = Selection(pile, count);
    notifyListeners();
  }

  /// A click on an empty place.
  void tapEmpty(Pile pile) {
    if (pile.kind == PileKind.stock) {
      draw();
      return;
    }
    final held = selected;
    if (held != null) moveCards(held.pile, held.count, pile);
  }

  /// A double click: sends the cards to the best place there is.
  void sendAway(Pile pile, int index) {
    selected = null;
    if (pile.kind == PileKind.column && index < state.hidden[pile.index]) {
      return;
    }
    final count = _countFrom(pile, index);
    final target = state.bestDestination(pile, count);
    if (target == null) {
      if (state.canPick(pile, count)) {
        _reject(state.cardsFrom(pile, count));
      } else {
        rejectPick(pile, index);
      }
      return;
    }
    moveCards(pile, count, target);
  }

  void _finishIfPossible() {
    _collectTimer?.cancel();
    if (!state.canFinish) return;
    if (collectDelay == Duration.zero) {
      while (state.canFinish && _collectOne()) {}
      return;
    }
    _collectTimer = Timer(collectDelay, () {
      if (_collectOne()) _finishIfPossible();
    });
  }

  bool _collectOne() {
    final from = state.nextCollectable();
    if (from == null) return false;
    final card = state.columns[from.index].last;
    final target = Pile.foundation(card.suit.index);
    final next = state.move(from, 1, target)!;
    _addScore(state.pointsFor(from, target, next));
    final before = state;
    state = next;
    lastMoved = {card.id};
    _landed(before);
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _collectTimer?.cancel();
    super.dispose();
  }
}
