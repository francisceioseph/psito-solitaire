import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';
import 'package:psito_solitaire/l10n/app_localizations.dart';
import 'package:psito_solitaire/src/game/game_controller.dart';
import 'package:psito_solitaire/src/game/game_state.dart';
import 'package:psito_solitaire/src/game/scores.dart';
import 'package:psito_solitaire/src/ui/organisms/board.dart';
import 'package:psito_solitaire/src/ui/atoms/card_face.dart';
import 'package:psito_solitaire/src/ui/pages/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpGame(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        GamesUiLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: GameScreen(number: 3),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

GameState tableOf(
  List<List<PlayingCard>> columns, {
  List<int> foundations = const [0, 0, 0, 0],
  List<PlayingCard> stock = const [],
}) => GameState(
  columns: [
    ...columns,
    for (var i = columns.length; i < 7; i++) <PlayingCard>[],
  ],
  hidden: const [0, 0, 0, 0, 0, 0, 0],
  stock: stock,
  waste: const [],
  foundations: foundations,
);

/// A board with a red 7 in the first column and a black 8 in the second.
Future<GameController> pumpBoard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final game = GameController(number: 1, collectDelay: Duration.zero);
  addTearDown(game.dispose);
  game.state = tableOf([
    [const PlayingCard(Suit.hearts, 7)],
    [const PlayingCard(Suit.spades, 8)],
  ], stock: [const PlayingCard(Suit.clubs, 2)]);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GamesUiLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Board(game: game)),
    ),
  );
  await tester.pump();
  return game;
}

Finder faceOf(int rank) => find.byWidgetPredicate(
  (widget) => widget is CardFace && widget.card.rank == rank,
);

GameState almostWon() => tableOf(
  [
    [const PlayingCard(Suit.hearts, 13)],
    [const PlayingCard(Suit.diamonds, 13)],
    [const PlayingCard(Suit.spades, 13)],
  ],
  foundations: const [13, 12, 12, 12],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the winner saves a name and sees the best games', (tester) async {
    final game = await pumpBoard(tester);
    game.state = almostWon();
    game.sendAway(const Pile.column(0), 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(game.state.isWon, isTrue);
    expect(find.text('Você venceu!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Melhores partidas'), findsOneWidget);
    final saved = await const ScoreStore().load();
    expect(saved.single.name, 'Ana');
    expect(saved.single.points, 30);
    await finish(tester);
  });

  testWidgets('the victory panel fits a small window', (tester) async {
    final game = await pumpBoard(tester);
    tester.view.physicalSize = const Size(480, 300);
    game.state = almostWon();
    game.sendAway(const Pile.column(0), 0);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('the menu starts a game by its number', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(find.text('Escolher número do jogo'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();
    await tester.tap(find.text('Jogar'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('42'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('the bar shows the new game button in wide windows', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    expect(find.text('Novo jogo'), findsOneWidget);
    await finish(tester);
    await pumpGame(tester, const Size(700, 500));
    expect(find.text('Novo jogo'), findsNothing);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('dragging a card drops it on a column', (tester) async {
    final game = await pumpBoard(tester);
    final from = tester.getCenter(faceOf(7));
    final to = tester.getCenter(faceOf(8));
    await tester.dragFrom(from, to - from + const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.columns[1].length, 2);
    expect(game.state.columns[0], isEmpty);
    expect(game.moves, 1);
    await finish(tester);
  });

  testWidgets('a drop that the rules refuse keeps the card', (tester) async {
    final game = await pumpBoard(tester);
    final from = tester.getCenter(faceOf(8));
    final to = tester.getCenter(faceOf(7));
    final tick = game.rejectTick;
    await tester.dragFrom(from, to - from);
    await tester.pump(const Duration(milliseconds: 400));
    expect(game.state.columns[1].length, 1);
    expect(game.rejectTick, tick + 1);
    await finish(tester);
  });

  testWidgets('a double click sends the card away', (tester) async {
    final game = await pumpBoard(tester);
    await tester.tap(faceOf(7));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(faceOf(7));
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.columns[1].length, 2);
    await finish(tester);
  });

  testWidgets('a click on the stock draws a card', (tester) async {
    final game = await pumpBoard(tester);
    await tester.tap(faceOf(2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.waste.single, const PlayingCard(Suit.clubs, 2));
    expect(game.state.stock, isEmpty);
    await finish(tester);
  });

  testWidgets('shows the table and the score', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    expect(find.text('Psito Solitaire'), findsOneWidget);
    expect(find.text('PONTOS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.casino_outlined));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('3'), findsNothing);
    await finish(tester);
  });

  testWidgets('fits small and large windows without overflowing', (tester) async {
    for (final size in const [Size(480, 360), Size(1920, 1080), Size(800, 1200)]) {
      await pumpGame(tester, size);
      expect(tester.takeException(), isNull);
    }
    await finish(tester);
  });
}
