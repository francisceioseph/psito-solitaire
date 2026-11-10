import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/game_state.dart';
import 'colors.dart';

/// Every card is an image painted by tool/prepare_art.py, so that the text and
/// the suits come out smooth and the same on every system.
String cardArt(PlayingCard card) {
  final rank = switch (card.rank) {
    1 => 'ace',
    11 => 'jack',
    12 => 'queen',
    13 => 'king',
    _ => '${card.rank}',
  };
  return 'assets/cards/${rank}_${card.suit.name}.jpg';
}

const cardBack = 'assets/cards/back.jpg';

Iterable<String> allCardArt() sync* {
  yield cardBack;
  for (final suit in Suit.values) {
    for (var rank = 1; rank <= 13; rank++) {
      yield cardArt(PlayingCard(suit, rank));
    }
  }
}

class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.card,
    this.selected = false,
    this.faceUp = true,
  });

  final PlayingCard card;
  final bool selected;
  final bool faceUp;

  Widget _side(BorderRadius radius, String asset) => DecoratedBox(
    decoration: BoxDecoration(
      color: PsitoColors.cream,
      borderRadius: radius,
      boxShadow: const [
        BoxShadow(color: Color(0x4D000000), blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? PsitoColors.accent : PsitoColors.edge,
                width: selected ? 3 : 1,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final radius = BorderRadius.circular(box.maxWidth * .06);
        // The card turns around its vertical axis when it is revealed.
        return TweenAnimationBuilder<double>(
          tween: Tween(end: faceUp ? 1 : 0),
          duration: still ? Duration.zero : const Duration(milliseconds: 240),
          builder: (context, value, _) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(pi * (1 - value)),
            child: value > .5
                ? _side(radius, cardArt(card))
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _side(radius, cardBack),
                  ),
          ),
        );
      },
    );
  }
}
