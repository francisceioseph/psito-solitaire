import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

const _peekImage = 'assets/mascot/peek.png';
const _peekAspect = 268 / 420;
const _peekMaxHeight = 190.0;

/// How far the centre of the head stays beyond the edge while hidden, in
/// head heights.
const _hiddenDepth = -.62;

enum PeekEdge { bottom, left, right, top }

/// Where the cockatiel shows up, and how the head has to be turned for it.
///
/// The drawing looks to the right and its neck is cut at the bottom left, so
/// each edge turns it until the cut stays out of the screen, and mirrors it
/// when that is what makes it look towards the table.
class PeekSpot {
  const PeekSpot(this.edge, this.along);

  final PeekEdge edge;

  /// The place along the edge, from 0 to 1.
  final double along;

  bool get mirrored => switch (edge) {
    PeekEdge.bottom => along > .5,
    PeekEdge.left => false,
    PeekEdge.right => true,
    // Upside down, the drawing looks to the left.
    PeekEdge.top => along < .5,
  };

  double get angle {
    final turn = switch (edge) {
      PeekEdge.bottom => -.16,
      PeekEdge.left || PeekEdge.right => .785,
      PeekEdge.top => 2.76,
    };
    return mirrored ? -turn : turn;
  }

  /// How far the centre of the head comes in, in head heights.
  double get depth => switch (edge) {
    PeekEdge.bottom => .29,
    PeekEdge.left || PeekEdge.right => .18,
    PeekEdge.top => .35,
  };
}

/// A spot on a different edge from the [previous] one.
PeekSpot nextPeekSpot(Random random, PeekSpot? previous) {
  final edges = [
    for (final edge in PeekEdge.values)
      if (edge != previous?.edge) edge,
  ];
  final edge = edges[random.nextInt(edges.length)];
  final horizontal = edge == PeekEdge.bottom || edge == PeekEdge.top;
  final margin = horizontal ? .12 : .25;
  return PeekSpot(edge, margin + random.nextDouble() * (1 - 2 * margin));
}

double peekHeight(Size area) => min(_peekMaxHeight, area.shortestSide * .45);

/// The centre of the head when it is [shown] (0 hidden, 1 in place).
Offset peekCenter(PeekSpot spot, Size area, double height, double shown) {
  final depth = lerpDouble(_hiddenDepth * height, spot.depth * height, shown)!;
  return switch (spot.edge) {
    PeekEdge.bottom => Offset(area.width * spot.along, area.height - depth),
    PeekEdge.top => Offset(area.width * spot.along, depth),
    PeekEdge.left => Offset(depth, area.height * spot.along),
    PeekEdge.right => Offset(area.width - depth, area.height * spot.along),
  };
}

/// A cockatiel that peeks from an edge when nothing happens for a while.
///
/// Give each appearance its own key, so that it starts from outside the
/// screen instead of crossing it from the last place.
class Peek extends StatelessWidget {
  const Peek({super.key, required this.spot, required this.visible});

  final PeekSpot spot;
  final bool visible;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, box) {
              final area = box.biggest;
              final height = peekHeight(area);
              final width = height * _peekAspect;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: visible ? 1 : 0),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                builder: (context, shown, child) {
                  final center = peekCenter(spot, area, height, shown);
                  return Stack(
                    children: [
                      Positioned(
                        left: center.dx - width / 2,
                        top: center.dy - height / 2,
                        width: width,
                        height: height,
                        child: child!,
                      ),
                    ],
                  );
                },
                child: Transform.rotate(
                  angle: spot.angle,
                  child: Transform.flip(
                    flipX: spot.mirrored,
                    child: Image.asset(_peekImage),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
