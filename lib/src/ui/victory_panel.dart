import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../game/game_controller.dart';
import '../game/scores.dart';
import 'card_face.dart';

/// The best games, with the [highlight] one in bold.
class ScoreTable extends StatelessWidget {
  const ScoreTable({super.key, required this.scores, this.highlight});

  final List<Score> scores;
  final Score? highlight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (scores.isEmpty) return Text(l10n.noScores);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < scores.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: DefaultTextStyle.merge(
              style: identical(scores[i], highlight)
                  ? const TextStyle(fontWeight: FontWeight.w800)
                  : null,
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('${i + 1}.')),
                  Expanded(
                    child: Text(
                      scores[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.points(scores[i].points)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    child: Text(
                      formatTime(scores[i].seconds),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Asks for the winner's name and shows where the game landed.
class VictoryPanel extends StatefulWidget {
  const VictoryPanel({super.key, required this.game, required this.store});

  final GameController game;
  final ScoreStore store;

  @override
  State<VictoryPanel> createState() => _VictoryPanelState();
}

class _VictoryPanelState extends State<VictoryPanel> {
  final _name = TextEditingController();
  List<Score>? _scores;
  Score? _mine;

  @override
  void initState() {
    super.initState();
    widget.store.lastName().then((name) {
      if (mounted && _name.text.isEmpty) _name.text = name;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _mine != null) return;
    final game = widget.game;
    final mine = Score(
      name: name,
      points: game.score,
      seconds: game.seconds,
      game: game.number,
    );
    final scores = insertScore(await widget.store.load(), mine);
    await widget.store.save(scores);
    await widget.store.saveName(name);
    if (mounted) {
      setState(() {
        _scores = scores;
        _mine = mine;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = widget.game;
    final scores = _scores;
    return Card(
      color: PsitoColors.cream,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.youWon,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: PsitoColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.winSummary(
                  l10n.points(game.score),
                  formatTime(game.seconds),
                ),
              ),
              const SizedBox(height: 16),
              if (scores == null) ...[
                TextField(
                  controller: _name,
                  autofocus: true,
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: l10n.yourName,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: game.newGame,
                      child: Text(l10n.skip),
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: _name,
                      builder: (context, _) => FilledButton(
                        onPressed: _name.text.trim().isEmpty ? null : _save,
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  l10n.bestGames,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ScoreTable(scores: scores, highlight: _mine),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: game.newGame,
                  child: Text(l10n.playAgain),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
