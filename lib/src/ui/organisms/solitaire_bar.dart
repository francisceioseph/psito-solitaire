import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../game/game_controller.dart';
import '../../game/scores.dart';
import '../../version.dart';
import 'victory_panel.dart';

/// What Psito Solitaire says about itself.
GameInfo solitaireInfo(AppLocalizations l10n) => GameInfo(
  title: l10n.appTitle,
  version: appVersion,
  howToPlay: l10n.howToPlayBody,
  about: l10n.aboutBody,
  legal: l10n.aboutLegal,
  site: 'https://francisceioseph.github.io/psito-solitaire/',
);

/// The bar of the table: the game number, the points, the clock, the undo
/// and the restart.
class SolitaireBar extends StatelessWidget {
  const SolitaireBar({super.key, required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ui = context.gamesUi;
    return GameBar(
      info: solitaireInfo(l10n),
      onNewGame: game.newGame,
      onBestGames: () => showBestGames(
        context,
        FutureBuilder<List<Score>>(
          future: const ScoreStore().load(),
          builder: (context, snapshot) =>
              SolitaireScoreTable(scores: snapshot.data ?? const []),
        ),
      ),
      menu: [
        GameMenuEntry(
          label: ui.chooseGame,
          onSelected: () => showDialog<void>(
            context: context,
            builder: (_) => ChooseGameDialog(onChosen: game.newGame),
          ),
        ),
      ],
      stats: (space) => StatsPill(
        children: [
          if (!space.narrow)
            StatTile(label: ui.statGame, value: '${game.number}'),
          StatTile(label: l10n.statScore, value: '${game.score}'),
          ClockStat(seconds: () => game.seconds),
        ],
      ),
      actions: (space) => [
        BarButton(
          tooltip: '${ui.undo}  (Ctrl+Z)',
          icon: Icons.undo_rounded,
          onPressed: game.canUndo ? game.undo : null,
        ),
        BarButton(
          tooltip: '${ui.restart}  (Ctrl+R)',
          icon: Icons.replay_rounded,
          onPressed: game.restart,
        ),
      ],
    );
  }
}
