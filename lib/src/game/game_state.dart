import 'package:flutter/foundation.dart';

/// The four suits. Clubs and spades are black; hearts and diamonds are red.
enum Suit {
  clubs,
  spades,
  hearts,
  diamonds;

  bool get isRed => this == hearts || this == diamonds;
}

@immutable
class PlayingCard {
  const PlayingCard(this.suit, this.rank) : assert(rank >= 1 && rank <= 13);

  final Suit suit;

  /// 1 is the ace, 11 the jack, 12 the queen and 13 the king.
  final int rank;

  /// A number from 0 to 51 that identifies the card.
  int get id => suit.index * 13 + rank - 1;

  bool canStackOn(PlayingCard other) =>
      suit.isRed != other.suit.isRed && rank == other.rank - 1;

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.suit == suit && other.rank == rank;

  @override
  int get hashCode => id;

  @override
  String toString() => '$rank${suit.name[0]}';
}

enum PileKind { column, stock, waste, foundation }

/// A place on the table where cards can be.
@immutable
class Pile {
  const Pile.column(this.index) : kind = PileKind.column;
  const Pile.stock() : kind = PileKind.stock, index = 0;
  const Pile.waste() : kind = PileKind.waste, index = 0;
  const Pile.foundation(this.index) : kind = PileKind.foundation;

  final PileKind kind;
  final int index;

  @override
  bool operator ==(Object other) =>
      other is Pile && other.kind == kind && other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);

  @override
  String toString() => '${kind.name}[$index]';
}

/// Shuffles the deck for a game number. The same number always gives the same
/// deal, on every platform, because the generator is written here.
List<PlayingCard> shuffledDeck(int number) {
  final deck = [
    for (final suit in Suit.values)
      for (var rank = 1; rank <= 13; rank++) PlayingCard(suit, rank),
  ];
  var seed = number & 0x7fffffff;
  int next(int bound) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (seed >> 8) % bound;
  }

  for (var i = deck.length - 1; i > 0; i--) {
    final j = next(i + 1);
    final swap = deck[i];
    deck[i] = deck[j];
    deck[j] = swap;
  }
  return deck;
}

/// The table at one moment. It never changes: a move gives a new state.
@immutable
class GameState {
  const GameState({
    required this.columns,
    required this.hidden,
    required this.stock,
    required this.waste,
    required this.foundations,
  });

  factory GameState.deal(int number) {
    final deck = shuffledDeck(number);
    final columns = <List<PlayingCard>>[];
    var taken = 0;
    for (var i = 0; i < 7; i++) {
      columns.add(deck.sublist(taken, taken + i + 1));
      taken += i + 1;
    }
    return GameState(
      columns: columns,
      hidden: [for (var i = 0; i < 7; i++) i],
      stock: deck.sublist(taken),
      waste: const [],
      foundations: const [0, 0, 0, 0],
    );
  }

  final List<List<PlayingCard>> columns;

  /// How many cards at the start of each column are face down.
  final List<int> hidden;

  /// The face-down pile. Its last card is the next one to be drawn.
  final List<PlayingCard> stock;
  final List<PlayingCard> waste;

  /// The highest rank collected for each suit, by [Suit.index].
  final List<int> foundations;

  bool get isWon => foundations.every((rank) => rank == 13);

  /// Everything is face up and in the columns: the rest plays itself.
  bool get canFinish =>
      !isWon && stock.isEmpty && waste.isEmpty && hidden.every((h) => h == 0);

  bool canCollect(PlayingCard card) =>
      foundations[card.suit.index] == card.rank - 1;

  /// Whether the last [count] cards of a column are face up and in sequence.
  bool isRun(int column, int count) {
    final cards = columns[column];
    if (count < 1 || count > cards.length - hidden[column]) return false;
    for (var i = cards.length - count; i < cards.length - 1; i++) {
      if (!cards[i + 1].canStackOn(cards[i])) return false;
    }
    return true;
  }

  bool canPick(Pile pile, int count) => switch (pile.kind) {
    PileKind.column => isRun(pile.index, count),
    PileKind.waste => count == 1 && waste.isNotEmpty,
    PileKind.foundation => count == 1 && foundations[pile.index] > 0,
    PileKind.stock => false,
  };

  /// The cards that would leave [pile].
  List<PlayingCard> cardsFrom(Pile pile, int count) => switch (pile.kind) {
    PileKind.column => columns[pile.index].sublist(
      columns[pile.index].length - count,
    ),
    PileKind.waste => [waste.last],
    PileKind.foundation => [
      PlayingCard(Suit.values[pile.index], foundations[pile.index]),
    ],
    PileKind.stock => const [],
  };

  /// The state after the move, or null if the rules do not allow it.
  GameState? move(Pile from, int count, Pile to) {
    if (from == to || !canPick(from, count)) return null;
    final moving = cardsFrom(from, count);
    final lead = moving.first;

    switch (to.kind) {
      case PileKind.foundation:
        if (from.kind == PileKind.foundation) return null;
        if (count != 1 || !canCollect(lead)) return null;
      case PileKind.column:
        final target = columns[to.index];
        if (target.isEmpty) {
          if (lead.rank != 13) return null;
        } else if (!lead.canStackOn(target.last)) {
          return null;
        }
      case PileKind.stock:
      case PileKind.waste:
        return null;
    }

    final newColumns = [for (final column in columns) [...column]];
    final newHidden = [...hidden];
    final newWaste = [...waste];
    final newFoundations = [...foundations];

    switch (from.kind) {
      case PileKind.column:
        final cards = newColumns[from.index];
        cards.removeRange(cards.length - count, cards.length);
        // The card that is now on top turns face up.
        if (newHidden[from.index] >= cards.length) {
          newHidden[from.index] = cards.isEmpty ? 0 : cards.length - 1;
        }
      case PileKind.waste:
        newWaste.removeLast();
      case PileKind.foundation:
        newFoundations[from.index] -= 1;
      case PileKind.stock:
        return null;
    }

    if (to.kind == PileKind.foundation) {
      newFoundations[lead.suit.index] = lead.rank;
    } else {
      newColumns[to.index].addAll(moving);
    }

    return GameState(
      columns: newColumns,
      hidden: newHidden,
      stock: stock,
      waste: newWaste,
      foundations: newFoundations,
    );
  }

  /// One card from the stock, or the waste back to the stock when it is empty.
  /// Null when there is nothing left to draw.
  GameState? draw() {
    if (stock.isEmpty && waste.isEmpty) return null;
    final newStock = [...stock];
    final newWaste = [...waste];
    if (stock.isEmpty) {
      newStock.addAll(waste.reversed);
      newWaste.clear();
    } else {
      newWaste.add(newStock.removeLast());
    }
    return GameState(
      columns: columns,
      hidden: hidden,
      stock: newStock,
      waste: newWaste,
      foundations: foundations,
    );
  }

  /// Where a double click sends the cards: the foundation, then a column with
  /// cards, then an empty column.
  Pile? bestDestination(Pile from, int count) {
    if (!canPick(from, count)) return null;
    final lead = cardsFrom(from, count).first;
    if (count == 1 &&
        from.kind != PileKind.foundation &&
        canCollect(lead)) {
      return Pile.foundation(lead.suit.index);
    }
    bool accepts(Pile pile) => move(from, count, pile) != null;
    for (var i = 0; i < columns.length; i++) {
      final pile = Pile.column(i);
      if (columns[i].isNotEmpty && accepts(pile)) return pile;
    }
    for (var i = 0; i < columns.length; i++) {
      final pile = Pile.column(i);
      if (columns[i].isEmpty && accepts(pile)) return pile;
    }
    return null;
  }

  /// A column whose top card can go to its foundation, if there is one.
  Pile? nextCollectable() {
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].isNotEmpty && canCollect(columns[i].last)) {
        return Pile.column(i);
      }
    }
    return null;
  }

  /// The points of the classic scoring for a move that gave [next].
  int pointsFor(Pile from, Pile to, GameState next) {
    var points = switch ((from.kind, to.kind)) {
      (PileKind.waste, PileKind.column) => 5,
      (PileKind.waste, PileKind.foundation) => 10,
      (PileKind.column, PileKind.foundation) => 10,
      (PileKind.foundation, PileKind.column) => -15,
      _ => 0,
    };
    final turned =
        hidden.fold(0, (a, b) => a + b) - next.hidden.fold(0, (a, b) => a + b);
    if (turned > 0) points += 5;
    return points;
  }
}
