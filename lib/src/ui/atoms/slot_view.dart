import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/game_state.dart';
import 'colors.dart';
import 'suit_shape.dart';

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
