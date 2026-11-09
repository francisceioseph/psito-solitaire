import 'package:flutter_test/flutter_test.dart';
import 'package:psito_solitaire/src/game/game_controller.dart';
import 'package:psito_solitaire/src/game/game_state.dart';

const _c = Suit.clubs;
const _s = Suit.spades;
const _h = Suit.hearts;
const _d = Suit.diamonds;

GameState table({
  List<List<PlayingCard>> columns = const [],
  List<int>? hidden,
  List<PlayingCard> stock = const [],
  List<PlayingCard> waste = const [],
  List<int> foundations = const [0, 0, 0, 0],
}) => GameState(
  columns: [
    ...columns,
    for (var i = columns.length; i < 7; i++) <PlayingCard>[],
  ],
  hidden: [
    ...?hidden,
    for (var i = hidden?.length ?? 0; i < 7; i++) 0,
  ],
  stock: stock,
  waste: waste,
  foundations: foundations,
);

const a = Pile.column(0);
const b = Pile.column(1);

void main() {
  group('deal', () {
    test('has seven growing columns and the rest in the stock', () {
      final state = GameState.deal(42);
      expect(state.columns.map((c) => c.length), [1, 2, 3, 4, 5, 6, 7]);
      expect(state.hidden, [0, 1, 2, 3, 4, 5, 6]);
      expect(state.stock.length, 24);
      final all = [...state.columns.expand((c) => c), ...state.stock];
      expect(all.map((c) => c.id).toSet().length, 52);
    });

    test('is the same for the same number', () {
      expect(shuffledDeck(7), shuffledDeck(7));
      expect(shuffledDeck(7), isNot(shuffledDeck(8)));
    });
  });

  group('moves', () {
    test('a column takes a lower card of the other colour', () {
      final state = table(
        columns: [
          [const PlayingCard(_h, 7)],
          [const PlayingCard(_s, 8)],
        ],
      );
      expect(state.move(a, 1, b), isNotNull);
      final black = table(
        columns: [
          [const PlayingCard(_s, 7)],
          [const PlayingCard(_c, 8)],
        ],
      );
      expect(black.move(a, 1, b), isNull);
    });

    test('only a king goes to an empty column', () {
      final queen = table(columns: [[const PlayingCard(_h, 12)]]);
      expect(queen.move(a, 1, b), isNull);
      final king = table(columns: [[const PlayingCard(_h, 13)]]);
      expect(king.move(a, 1, b), isNotNull);
    });

    test('a whole sequence moves at once', () {
      final state = table(
        columns: [
          [
            const PlayingCard(_s, 9),
            const PlayingCard(_h, 8),
            const PlayingCard(_c, 7),
          ],
          [const PlayingCard(_d, 10)],
        ],
      );
      final next = state.move(a, 3, b)!;
      expect(next.columns[1].length, 4);
      expect(next.columns[0], isEmpty);
    });

    test('face-down cards cannot be picked up', () {
      final state = table(
        columns: [
          [const PlayingCard(_s, 9), const PlayingCard(_h, 8)],
        ],
        hidden: [1],
      );
      expect(state.canPick(a, 1), isTrue);
      expect(state.canPick(a, 2), isFalse);
    });

    test('the card left on top turns face up', () {
      final state = table(
        columns: [
          [const PlayingCard(_c, 2), const PlayingCard(_h, 7)],
          [const PlayingCard(_s, 8)],
        ],
        hidden: [1],
      );
      expect(state.move(a, 1, b)!.hidden[0], 0);
    });

    test('foundations go up from the ace and can give a card back', () {
      final ace = table(columns: [[const PlayingCard(_d, 1)]]);
      final next = ace.move(a, 1, const Pile.foundation(0))!;
      expect(next.foundations[_d.index], 1);

      final four = table(
        columns: [[const PlayingCard(_s, 5)]],
        foundations: [0, 0, 4, 0],
      );
      final back = four.move(Pile.foundation(_h.index), 1, a)!;
      expect(back.foundations[_h.index], 3);
      expect(back.columns[0].last, const PlayingCard(_h, 4));
    });
  });

  group('stock', () {
    test('draws one card, then turns the waste back over', () {
      var state = table(
        stock: [const PlayingCard(_c, 3), const PlayingCard(_h, 9)],
      );
      state = state.draw()!;
      expect(state.waste.last, const PlayingCard(_h, 9));
      state = state.draw()!;
      expect(state.stock, isEmpty);
      state = state.draw()!;
      expect(state.waste, isEmpty);
      expect(state.stock.last, const PlayingCard(_h, 9));
      expect(table().draw(), isNull);
    });
  });

  group('points', () {
    GameController controller(GameState state) =>
        GameController(number: 5, collectDelay: Duration.zero)..state = state;

    test('follow the classic scoring', () {
      final waste = controller(
        table(
          columns: [[const PlayingCard(_s, 8)]],
          waste: [const PlayingCard(_h, 7)],
        ),
      );
      waste.moveCards(const Pile.waste(), 1, a);
      expect(waste.score, 5);

      final flip = controller(
        table(
          columns: [
            [const PlayingCard(_c, 2), const PlayingCard(_h, 1)],
          ],
          hidden: [1],
        ),
      );
      flip.moveCards(a, 1, Pile.foundation(_h.index));
      expect(flip.score, 15);
    });

    test('taking from a foundation costs points, never below zero', () {
      final game = controller(
        table(
          columns: [[const PlayingCard(_s, 5)]],
          stock: [const PlayingCard(_c, 9)],
          foundations: [0, 0, 4, 0],
        ),
      )..score = 20;
      game.moveCards(Pile.foundation(_h.index), 1, a);
      expect(game.score, 5);
      game.undo();
      expect(game.score, 20);
      game.score = 3;
      game.moveCards(Pile.foundation(_h.index), 1, a);
      expect(game.score, 0);
    });

    test('turning the waste over costs 100', () {
      final game = controller(
        table(waste: [const PlayingCard(_h, 7)]),
      )..score = 130;
      game.draw();
      expect(game.score, 30);
    });
  });

  group('controller', () {
    GameController controller() =>
        GameController(number: 5, collectDelay: Duration.zero);

    test('undo brings back the table, the moves and the score', () {
      final game = controller();
      final before = game.state;
      game.draw();
      expect(game.moves, 1);
      game.undo();
      expect(game.state, same(before));
      expect(game.moves, 0);
      expect(game.canUndo, isFalse);
    });

    test('a click on a face-down card does nothing', () {
      final game = controller();
      game.tapCard(const Pile.column(3), 0);
      expect(game.selected, isNull);
      expect(game.rejected, isEmpty);
    });

    test('a click on a card and then on a place moves it', () {
      final game = controller();
      game.state = table(
        columns: [
          [const PlayingCard(_h, 7)],
          [const PlayingCard(_s, 8)],
        ],
      );
      game.tapCard(a, 0);
      expect(game.selected?.count, 1);
      game.tapCard(b, 0);
      expect(game.state.columns[1].length, 2);
      expect(game.selected, isNull);
    });

    test('a refused move makes the cards shake', () {
      final game = controller();
      final tick = game.rejectTick;
      game.state = table(
        columns: [
          [const PlayingCard(_s, 9), const PlayingCard(_c, 8)],
        ],
      );
      game.tapCard(a, 0);
      expect(game.rejectTick, tick + 1);
      expect(game.rejected.length, 2);
    });

    test('when everything is face up the game finishes itself', () {
      final game = controller();
      game.state = table(
        columns: [
          [const PlayingCard(_h, 13)],
          [const PlayingCard(_d, 13)],
          [const PlayingCard(_s, 13)],
        ],
        foundations: const [13, 12, 12, 12],
      );
      game.sendAway(a, 0);
      expect(game.state.isWon, isTrue);
      expect(game.score, 30);
    });
  });
}
