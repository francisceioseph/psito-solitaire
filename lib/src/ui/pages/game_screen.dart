import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../game/game_controller.dart';
import '../atoms/card_face.dart';
import '../organisms/board.dart';
import '../organisms/solitaire_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.number});

  /// A fixed game number. Without one, the deal is random.
  final int? number;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _game = GameController(number: widget.number);
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final path in allCardArt()) {
      precacheImage(AssetImage(path), context);
    }
    for (final slot in const ['perch', 'nest']) {
      precacheImage(AssetImage('assets/slots/$slot.png'), context);
    }
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GameTable(
    shortcuts: {
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
          _game.undo,
      const SingleActivator(LogicalKeyboardKey.keyN, control: true):
          _game.newGame,
      const SingleActivator(LogicalKeyboardKey.keyR, control: true):
          _game.restart,
    },
    bar: ListenableBuilder(
      listenable: _game,
      builder: (context, _) => SolitaireBar(game: _game),
    ),
    board: Board(game: _game),
  );
}
