import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import 'app_bar.dart';
import 'board.dart';
import 'card_face.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.number});

  /// A fixed game number. Without one, the deal is random.
  final int? number;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _idle = Duration(seconds: 45);
  static const _peekTime = Duration(milliseconds: 3200);

  late final GameController _game = GameController(number: widget.number);
  Timer? _timer;
  bool _peeking = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _waitIdle();
  }

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
    _timer?.cancel();
    _game.dispose();
    super.dispose();
  }

  void _waitIdle() {
    _timer?.cancel();
    _timer = Timer(_idle, _peek);
  }

  void _peek() {
    setState(() => _peeking = true);
    _timer = Timer(_peekTime, () {
      setState(() => _peeking = false);
      _waitIdle();
    });
  }

  void _activity() {
    if (_peeking) setState(() => _peeking = false);
    _waitIdle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PsitoColors.felt,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
              _game.undo,
          const SingleActivator(LogicalKeyboardKey.keyN, control: true):
              _game.newGame,
          const SingleActivator(LogicalKeyboardKey.keyR, control: true):
              _game.restart,
        },
        child: Focus(
          autofocus: true,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _activity(),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: _game,
                  builder: (context, _) => GameAppBar(game: _game),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.1,
                            colors: [
                              PsitoColors.feltGlow,
                              PsitoColors.felt,
                              PsitoColors.feltDark,
                            ],
                            stops: [0, .6, 1],
                          ),
                        ),
                      ),
                      Board(game: _game),
                      _Peek(visible: _peeking),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A cockatiel that peeks from the corner when nothing happens for a while.
class _Peek extends StatelessWidget {
  const _Peek({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => Positioned(
    right: 24,
    bottom: 0,
    height: 190,
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: AnimatedSlide(
            offset: visible ? const Offset(0, .12) : const Offset(0, 1.1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            child: Transform.rotate(
              angle: -.16,
              child: Image.asset('assets/mascot/peek.png'),
            ),
          ),
        ),
      ),
    ),
  );
}
