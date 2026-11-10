import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../../game/scores.dart';
import '../atoms/card_face.dart';
import '../atoms/slot_view.dart';
import '../labels.dart';
import '../molecules/card_motion.dart';
import 'board_layout.dart';
import 'victory_panel.dart';

class _Placed {
  const _Placed(
    this.card,
    this.pile,
    this.index,
    this.offset,
    this.pileSize,
    this.faceUp,
  );

  final PlayingCard card;
  final Pile pile;
  final int index;
  final Offset offset;
  final int pileSize;
  final bool faceUp;

  bool get isTop => index == pileSize - 1;
}

class _Drag {
  _Drag(this.pile, this.index, this.count);

  final Pile pile;
  final int index;
  final int count;
  Offset delta = Offset.zero;

  bool holds(_Placed placed) => placed.pile == pile && placed.index >= index;
}

/// The table: every card is one widget that travels on its own.
class Board extends StatefulWidget {
  const Board({super.key, required this.game, this.scores = const ScoreStore()});

  final GameController game;
  final ScoreStore scores;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  static const _doubleClick = Duration(milliseconds: 350);

  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );
  _Drag? _drag;
  int? _lastTapCard;
  DateTime _lastTapTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _won = false;

  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    game.addListener(_gameChanged);
  }

  @override
  void dispose() {
    game.removeListener(_gameChanged);
    _win.dispose();
    super.dispose();
  }

  void _gameChanged() {
    final won = game.state.isWon;
    if (won == _won) return;
    _won = won;
    if (won) {
      _win.forward(from: 0);
    } else {
      _win.value = 0;
    }
  }

  List<_Placed> _place(GameState state, BoardLayout layout) {
    final placed = <_Placed>[];
    void pile(
      List<PlayingCard> cards,
      Pile where, {
      required bool faceUp,
      bool onlyTop = false,
    }) {
      // A tall pile of shadows would look like a black smudge.
      for (var i = onlyTop ? max(0, cards.length - 2) : 0; i < cards.length; i++) {
        placed.add(
          _Placed(cards[i], where, i, layout.slot(where), cards.length, faceUp),
        );
      }
    }

    pile(state.stock, const Pile.stock(), faceUp: false, onlyTop: true);
    pile(state.waste, const Pile.waste(), faceUp: true, onlyTop: true);
    for (var suit = 0; suit < 4; suit++) {
      pile(
        [
          for (var rank = 1; rank <= state.foundations[suit]; rank++)
            PlayingCard(Suit.values[suit], rank),
        ],
        Pile.foundation(suit),
        faceUp: true,
      );
    }
    for (var c = 0; c < state.columns.length; c++) {
      final cards = state.columns[c];
      final where = Pile.column(c);
      for (var i = 0; i < cards.length; i++) {
        placed.add(
          _Placed(
            cards[i],
            where,
            i,
            layout.columnCard(where, i, cards.length, state.hidden[c]),
            cards.length,
            i >= state.hidden[c],
          ),
        );
      }
    }
    int layer(_Placed placed) {
      if (_drag?.holds(placed) ?? false) return 2;
      return game.lastMoved.contains(placed.card.id) ? 1 : 0;
    }

    // Dart's sort is not stable, so the original order breaks the ties.
    final order = {for (var i = 0; i < placed.length; i++) placed[i]: i};
    placed.sort((a, b) {
      final byLayer = layer(a).compareTo(layer(b));
      return byLayer != 0 ? byLayer : order[a]!.compareTo(order[b]!);
    });
    return placed;
  }

  void _tap(_Placed placed) {
    if (placed.pile.kind == PileKind.stock) {
      game.draw();
      return;
    }
    if (placed.pile.kind != PileKind.column && !placed.isTop) return;
    final now = DateTime.now();
    final isDouble =
        _lastTapCard == placed.card.id &&
        now.difference(_lastTapTime) < _doubleClick;
    _lastTapCard = placed.card.id;
    _lastTapTime = now;
    if (isDouble) {
      _lastTapCard = null;
      game.sendAway(placed.pile, placed.index);
    } else {
      game.tapCard(placed.pile, placed.index);
    }
  }

  void _panStart(_Placed placed) {
    if (!placed.faceUp || placed.pile.kind == PileKind.stock) return;
    if (placed.pile.kind != PileKind.column && !placed.isTop) return;
    final count = placed.pile.kind == PileKind.column
        ? placed.pileSize - placed.index
        : 1;
    if (!game.state.canPick(placed.pile, count)) {
      game.rejectPick(placed.pile, placed.index);
      return;
    }
    game.clearSelection();
    setState(() => _drag = _Drag(placed.pile, placed.index, count));
  }

  void _panEnd(_Placed placed, BoardLayout layout) {
    final drag = _drag;
    if (drag == null) return;
    setState(() => _drag = null);
    final corner = placed.offset + drag.delta;
    final center =
        corner + Offset(layout.cardWidth / 2, layout.cardHeight * .3);
    final target = layout.pileAt(center);
    if (target == null || target == drag.pile) return;
    game.moveCards(drag.pile, drag.count, target);
  }

  String _cardName(AppLocalizations l10n, _Placed placed) {
    if (placed.pile.kind == PileKind.stock) return l10n.drawCard;
    if (!placed.faceUp) return l10n.faceDownCard;
    final card = placed.card;
    return cardName(l10n, card);
  }

  Widget _slot(BoardLayout layout, Pile pile, String label, Widget child) {
    final at = layout.slot(pile);
    return Positioned(
      left: at.dx,
      top: at.dy,
      width: layout.cardWidth,
      height: layout.cardHeight,
      child: Semantics(
        button: true,
        label: label,
        onTap: () => game.tapEmpty(pile),
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: () => game.tapEmpty(pile),
          child: child,
        ),
      ),
    );
  }

  Widget _card(
    BoardLayout layout,
    _Placed placed,
    AppLocalizations l10n,
    bool still,
  ) {
    final drag = _drag;
    final dragging = drag?.holds(placed) ?? false;
    final held = game.selected;
    final selected =
        held != null &&
        held.pile == placed.pile &&
        placed.index >= placed.pileSize - held.count;
    var at = placed.offset;
    if (dragging) {
      at += drag!.delta;
    }
    if (selected) at -= Offset(0, layout.cardHeight * .05);

    return AnimatedPositioned(
      key: ValueKey(placed.card.id),
      left: at.dx,
      top: at.dy,
      width: layout.cardWidth,
      height: layout.cardHeight,
      duration: dragging || still
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      child: WinBounce(
        animation: _win,
        card: placed.card,
        floor: layout.size.height - layout.cardHeight - placed.offset.dy,
        child: Shake(
          tick: game.rejectTick,
          active: game.rejected.contains(placed.card.id),
          child: Semantics(
            button: true,
            selected: selected,
            label: _cardName(l10n, placed),
            onTap: () => _tap(placed),
            child: GestureDetector(
              excludeFromSemantics: true,
              onTap: () => _tap(placed),
              onPanStart: (_) => _panStart(placed),
              onPanUpdate: (details) {
                if (_drag == null) return;
                setState(() => _drag!.delta += details.delta);
              },
              onPanEnd: (_) => _panEnd(placed, layout),
              onPanCancel: () => setState(() => _drag = null),
              child: CardFace(
                card: placed.card,
                selected: selected,
                faceUp: placed.faceUp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final layout = BoardLayout.fit(box.biggest);
        return ListenableBuilder(
          listenable: game,
          builder: (context, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: game.clearSelection,
            child: Stack(
              children: [
                _slot(
                  layout,
                  const Pile.stock(),
                  l10n.turnWasteOver,
                  const SlotView.stock(),
                ),
                _slot(
                  layout,
                  const Pile.waste(),
                  l10n.emptyWaste,
                  const SlotView.perch(),
                ),
                for (final suit in Suit.values)
                  _slot(
                    layout,
                    Pile.foundation(suit.index),
                    l10n.nestOf(suitName(l10n, suit)),
                    SlotView.nest(suit),
                  ),
                for (var c = 0; c < 7; c++)
                  if (game.state.columns[c].isEmpty)
                    _slot(
                      layout,
                      Pile.column(c),
                      l10n.emptyColumn,
                      const SizedBox.expand(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0x14000000),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                for (final placed in _place(game.state, layout))
                  _card(layout, placed, l10n, still),
                if (game.state.isWon) _victory(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _victory() => Center(
    child: FadeTransition(
      opacity: CurvedAnimation(parent: _win, curve: const Interval(.15, .22)),
      child: VictoryPanel(game: game, store: widget.scores),
    ),
  );
}
