import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../../l10n/l10n.dart';
import '../../game/game_controller.dart';
import '../../game/scores.dart';

/// The best games: the most points first, and the time for the ties.
class SolitaireScoreTable extends StatelessWidget {
  const SolitaireScoreTable({super.key, required this.scores, this.highlight});

  final List<Score> scores;
  final Score? highlight;

  @override
  Widget build(BuildContext context) => ScoreTable<Score>(
    scores: scores,
    highlight: highlight,
    name: (score) => score.name,
    details: (score) => [
      Text(context.l10n.points(score.points)),
      const SizedBox(width: 12),
      SizedBox(
        width: 48,
        child: Text(formatTime(score.seconds), textAlign: TextAlign.end),
      ),
    ],
  );
}

/// Asks for the winner's name and shows where the game landed.
class VictoryPanel extends StatelessWidget {
  const VictoryPanel({super.key, required this.game, required this.store});

  final GameController game;
  final ScoreStore store;

  Future<Widget> _save(String name) async {
    final mine = Score(
      name: name,
      points: game.score,
      seconds: game.seconds,
      game: game.number,
    );
    final scores = insertScore(await store.load(), mine);
    await store.save(scores);
    await store.saveName(name);
    return SolitaireScoreTable(scores: scores, highlight: mine);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VictoryCard(
      title: l10n.youWon,
      summary: l10n.winSummary(
        l10n.points(game.score),
        formatTime(game.seconds),
      ),
      lastName: store.lastName,
      onSave: _save,
      onNewGame: game.newGame,
    );
  }
}
