import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_solitaire/src/ui/peek.dart';

const area = Size(1000, 700);

// Points of the drawing from its centre, in head heights.
const beak = Offset(.316, .18);
const neckLeft = Offset(-.316, .274);
const neckRight = Offset(.216, .489);

/// Where a point of the drawing lands on the screen.
Offset place(PeekSpot spot, Offset point) {
  final height = peekHeight(area);
  final x = (spot.mirrored ? -point.dx : point.dx) * height;
  final y = point.dy * height;
  final c = cos(spot.angle);
  final s = sin(spot.angle);
  return peekCenter(spot, area, height, 1) +
      Offset(x * c - y * s, x * s + y * c);
}

bool outside(Offset point) => !(Offset.zero & area).contains(point);

void main() {
  final spots = [
    for (final edge in PeekEdge.values)
      for (final along in const [.2, .4, .6, .8]) PeekSpot(edge, along),
  ];

  test('the cut of the neck never shows', () {
    for (final spot in spots) {
      expect(outside(place(spot, neckLeft)), isTrue, reason: '${spot.edge}');
      expect(outside(place(spot, neckRight)), isTrue, reason: '${spot.edge}');
    }
  });

  test('the beak looks towards the middle of the table', () {
    for (final spot in spots) {
      final center = peekCenter(spot, area, peekHeight(area), 1);
      final looking = place(spot, beak).dx - center.dx;
      final middle = area.width / 2 - center.dx;
      expect(looking * middle, greaterThan(0), reason: '${spot.edge}');
    }
  });

  test('the eye and the beak are on the screen', () {
    for (final spot in spots) {
      expect(outside(place(spot, const Offset(.07, .04))), isFalse);
      expect(outside(place(spot, beak)), isFalse);
    }
  });

  test('hidden, the head is entirely out of the screen', () {
    final height = peekHeight(area);
    final radius = Offset(height * 268 / 420, height).distance / 2;
    for (final spot in spots) {
      final center = peekCenter(spot, area, height, 0);
      final distance = switch (spot.edge) {
        PeekEdge.bottom => center.dy - area.height,
        PeekEdge.top => -center.dy,
        PeekEdge.left => -center.dx,
        PeekEdge.right => center.dx - area.width,
      };
      expect(distance, greaterThanOrEqualTo(radius));
    }
  });

  test('never comes twice in a row from the same edge', () {
    final random = Random(1);
    PeekSpot? last;
    final seen = <PeekEdge>{};
    for (var i = 0; i < 200; i++) {
      final spot = nextPeekSpot(random, last);
      expect(spot.edge, isNot(last?.edge));
      expect(spot.along, inInclusiveRange(0, 1));
      seen.add(spot.edge);
      last = spot;
    }
    expect(seen, PeekEdge.values.toSet());
  });
}
