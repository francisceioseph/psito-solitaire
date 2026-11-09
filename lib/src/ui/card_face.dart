import 'dart:math';

import 'package:flutter/material.dart';

import '../game/game_state.dart';

abstract final class PsitoColors {
  static const felt = Color(0xFF3B6478);
  static const feltGlow = Color(0xFF4A7A90);
  static const feltDark = Color(0xFF2C4E60);
  static const feltLight = Color(0xFF86A9BC);
  static const cream = Color(0xFFF6EED6);
  static const black = Color(0xFF3B3842);
  static const edge = Color(0xFFAE9A74);
  static const accent = Color(0xFFFFC107);
  static const onFelt = Color(0xFFF3EFE0);
  static const onFeltMuted = Color(0xFFA9C2D0);
  static const barTop = Color(0xFF2A4A5C);
  static const barBottom = Color(0xFF213C4C);
}

/// The suits are drawn as shapes so that they look the same on every system,
/// whatever fonts it has.
abstract final class SuitShape {
  static final Path _heart = Path()
    ..moveTo(.5, .96)
    ..cubicTo(.15, .66, 0, .46, 0, .28)
    ..cubicTo(0, .12, .13, 0, .28, 0)
    ..cubicTo(.38, 0, .46, .05, .5, .15)
    ..cubicTo(.54, .05, .62, 0, .72, 0)
    ..cubicTo(.87, 0, 1, .12, 1, .28)
    ..cubicTo(1, .46, .85, .66, .5, .96)
    ..close();

  static final Path _diamond = Path()
    ..moveTo(.5, 0)
    ..quadraticBezierTo(.68, .28, .9, .5)
    ..quadraticBezierTo(.68, .72, .5, 1)
    ..quadraticBezierTo(.32, .72, .1, .5)
    ..quadraticBezierTo(.32, .28, .5, 0)
    ..close();

  static final Path _stem = Path()
    ..moveTo(.46, .55)
    ..quadraticBezierTo(.44, .86, .3, 1)
    ..lineTo(.7, 1)
    ..quadraticBezierTo(.56, .86, .54, .55)
    ..close();

  static final Path _spade = Path()
    ..addPath(
      _heart,
      Offset.zero,
      matrix4: (Matrix4.identity()
            ..translateByDouble(0, .8, 0, 1)
            ..scaleByDouble(1, -.8, 1, 1))
          .storage,
    )
    ..addPath(_stem, Offset.zero);

  static final Path _club = Path()
    ..addOval(Rect.fromCircle(center: const Offset(.5, .25), radius: .24))
    ..addOval(Rect.fromCircle(center: const Offset(.24, .56), radius: .24))
    ..addOval(Rect.fromCircle(center: const Offset(.76, .56), radius: .24))
    ..addOval(Rect.fromCircle(center: const Offset(.5, .46), radius: .14))
    ..addPath(_stem, Offset.zero);

  static void draw(
    Canvas canvas,
    Suit suit,
    Rect rect,
    Color color,
  ) {
    final path = switch (suit) {
      Suit.clubs => _club,
      Suit.spades => _spade,
      Suit.hearts => _heart,
      Suit.diamonds => _diamond,
    };
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.scale(rect.width, rect.height);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }
}

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

/// An empty place on the table: a perch for the free cells, a nest for the
/// foundations.
class SlotView extends StatelessWidget {
  const SlotView.perch({super.key}) : suit = null, isStock = false;
  const SlotView.stock({super.key}) : suit = null, isStock = true;
  const SlotView.nest(Suit this.suit, {super.key}) : isStock = false;

  final Suit? suit;
  final bool isStock;

  @override
  Widget build(BuildContext context) => isStock
      ? Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _SlotPainter(suit)),
            const FractionallySizedBox(
              widthFactor: .42,
              child: FittedBox(
                child: Icon(Icons.replay_rounded, color: PsitoColors.feltLight),
              ),
            ),
          ],
        )
      : _illustrated();

  Widget _illustrated() => Stack(
    fit: StackFit.expand,
    children: [
      CustomPaint(painter: _SlotPainter(suit)),
      Align(
        alignment: suit == null ? Alignment.center : const Alignment(0, .5),
        child: FractionallySizedBox(
          widthFactor: suit == null ? .9 : .84,
          child: Opacity(
            opacity: .92,
            child: Image.asset(
              'assets/slots/${suit == null ? 'perch' : 'nest'}.png',
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    ],
  );
}

class _SlotPainter extends CustomPainter {
  const _SlotPainter(this.suit);

  final Suit? suit;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(size.width * .07),
    );
    canvas.drawRRect(shape, Paint()..color = const Color(0x24000000));
    final line = Paint()
      ..color = PsitoColors.feltLight.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(1.2, size.width * .014);
    canvas.drawRRect(shape, line);

    if (suit case final suit?) {
      final side = size.width * .34;
      SuitShape.draw(
        canvas,
        suit,
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * .26),
          width: side,
          height: side,
        ),
        PsitoColors.feltLight,
      );
    }
  }

  @override
  bool shouldRepaint(_SlotPainter old) => old.suit != suit;
}
