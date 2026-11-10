import 'package:flutter/material.dart';

import '../../game/game_state.dart';

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
