import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/game_state.dart';

/// Shakes "no" when [tick] changes while [active].
class Shake extends StatefulWidget {
  const Shake({super.key, required this.tick, required this.active, required this.child});

  final int tick;
  final bool active;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.active && widget.tick != old.tick) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final t = _controller.value;
      final dx = sin(t * pi * 5) * 7 * (1 - t);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
  );
}

/// The victory: the cards leave the nests one by one, bouncing off the floor.
class WinBounce extends StatelessWidget {
  const WinBounce({
    super.key,
    required this.animation,
    required this.card,
    required this.floor,
    required this.child,
  });

  static const _gravity = 2400.0;
  static const _bounciness = .74;

  final Animation<double> animation;
  final PlayingCard card;
  final double floor;
  final Widget child;

  double _height(double time) {
    final fall = sqrt(2 * floor / _gravity);
    if (time < fall) return .5 * _gravity * time * time;
    var left = time - fall;
    var speed = _gravity * fall * _bounciness;
    while (speed > 60) {
      final flight = 2 * speed / _gravity;
      if (left < flight) {
        return floor - (speed * left - .5 * _gravity * left * left);
      }
      left -= flight;
      speed *= _bounciness;
    }
    return floor;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final order = (13 - card.rank) * 4 + card.suit.index;
    final direction = card.suit.index.isEven ? -1.0 : 1.0;
    final speed = 150.0 + order % 5 * 45;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final total = animation.value * 9;
        final time = total - order * .1;
        if (animation.value == 0 || time <= 0) return child!;
        return Transform.translate(
          offset: Offset(direction * speed * time, _height(time)),
          child: child,
        );
      },
    );
  }
}
