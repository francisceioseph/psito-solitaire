import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../game/game_state.dart';

/// Where everything goes for a given window size.
class BoardLayout {
  BoardLayout._(this.size, this.cardWidth, this.cardHeight, this.gap, this.left);

  factory BoardLayout.fit(Size size) {
    final gap = (size.width * .012).clamp(6.0, 16.0);
    final byWidth = (size.width - pad * 2 - gap * 6) / 7;
    final byHeight = (size.height - pad * 2 - gap * 2) / 3.9 / aspect;
    final width = max(24.0, min(byWidth, byHeight));
    final height = width * aspect;
    final left = (size.width - (width * 7 + gap * 6)) / 2;
    return BoardLayout._(size, width, height, gap, left);
  }

  static const pad = 12.0;
  static const aspect = 1.4;

  final Size size;
  final double cardWidth;
  final double cardHeight;
  final double gap;
  final double left;

  double get _tableauTop => pad + cardHeight + gap * 2;

  double _columnX(int column) => left + column * (cardWidth + gap);

  Offset slot(Pile pile) => switch (pile.kind) {
    PileKind.stock => Offset(_columnX(0), pad),
    PileKind.waste => Offset(_columnX(1), pad),
    PileKind.foundation => Offset(_columnX(pile.index + 3), pad),
    PileKind.column => Offset(_columnX(pile.index), _tableauTop),
  };

  /// Where the card at [index] goes in a column of [count] cards, with the
  /// first [hidden] face down. The column shrinks when it would not fit.
  Offset columnCard(Pile pile, int index, int count, int hidden) {
    final faceDown = cardHeight * .09;
    final faceUp = cardHeight * .225;
    double height(int cards) =>
        min(cards, hidden) * faceDown + max(0, cards - hidden) * faceUp;

    final room = size.height - _tableauTop - pad - cardHeight;
    final total = height(count - 1);
    final squeeze = total > room && total > 0 ? room / total : 1.0;
    return slot(pile) + Offset(0, height(index) * squeeze);
  }

  /// The place that can receive cards under a point, if there is one.
  Pile? pileAt(Offset point) {
    final column = ((point.dx - left + gap / 2) / (cardWidth + gap)).floor();
    if (column < 0 || column > 6) return null;
    if (point.dy >= _tableauTop - gap) return Pile.column(column);
    return column >= 3 ? Pile.foundation(column - 3) : null;
  }
}
