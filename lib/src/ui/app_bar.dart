import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../game/game_controller.dart';
import '../game/scores.dart';
import '../version.dart';
import 'card_face.dart';
import 'victory_panel.dart';

enum _MenuItem { bestGames, chooseGame, howToPlay, about }

/// The bar above the table: the brand, the state of the game and the actions.
class GameAppBar extends StatelessWidget {
  const GameAppBar({super.key, required this.game});

  static const _compact = 860.0;
  static const _narrow = 600.0;

  final GameController game;

  void _showBestGames(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => const _BestGames());
  }

  void _chooseGame(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _ChooseGame(onChosen: game.newGame),
    );
  }

  void _howToPlay(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => const _HowToPlay());
  }

  void _about(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: appVersion,
      applicationIcon: Image.asset('assets/mascot/peek.png', width: 48),
      applicationLegalese: l10n.aboutLegal,
      children: [
        const SizedBox(height: 16),
        Text(l10n.aboutBody),
        const SizedBox(height: 8),
        const SelectableText('https://francisceioseph.github.io/psito-solitaire/'),
      ],
    );
  }

  void _onMenu(BuildContext context, _MenuItem item) => switch (item) {
    _MenuItem.bestGames => _showBestGames(context),
    _MenuItem.chooseGame => _chooseGame(context),
    _MenuItem.howToPlay => _howToPlay(context),
    _MenuItem.about => _about(context),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [PsitoColors.barTop, PsitoColors.barBottom],
        ),
        border: Border(bottom: BorderSide(color: Color(0x33000000))),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxWidth < _compact;
          final narrow = box.maxWidth < _narrow;
          final brand = _Brand(showName: !compact, title: l10n.appTitle);
          final stats = _GameStats(game: game, showNumber: !narrow);
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!narrow)
                _BarButton(
                  tooltip: l10n.bestGames,
                  icon: Icons.emoji_events_outlined,
                  onPressed: () => _showBestGames(context),
                ),
              _BarButton(
                tooltip: '${l10n.undo}  (Ctrl+Z)',
                icon: Icons.undo_rounded,
                onPressed: game.canUndo ? game.undo : null,
              ),
              _BarButton(
                tooltip: '${l10n.restart}  (Ctrl+R)',
                icon: Icons.replay_rounded,
                onPressed: game.restart,
              ),
              const SizedBox(width: 6),
              _NewGameButton(
                label: l10n.newGame,
                iconOnly: compact,
                onPressed: game.newGame,
              ),
              PopupMenuButton<_MenuItem>(
                tooltip: l10n.moreOptions,
                iconColor: PsitoColors.onFelt,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.more_vert_rounded, size: 21),
                onSelected: (item) => _onMenu(context, item),
                itemBuilder: (context) => [
                  if (narrow)
                    PopupMenuItem(
                      value: _MenuItem.bestGames,
                      child: Text(l10n.bestGames),
                    ),
                  PopupMenuItem(
                    value: _MenuItem.chooseGame,
                    child: Text(l10n.chooseGame),
                  ),
                  PopupMenuItem(
                    value: _MenuItem.howToPlay,
                    child: Text(l10n.howToPlay),
                  ),
                  PopupMenuItem(
                    value: _MenuItem.about,
                    child: Text(l10n.about),
                  ),
                ],
              ),
            ],
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            // The stats are centred only when there is room on both sides.
            child: Row(
              children: compact
                  ? [brand, const SizedBox(width: 12), stats, const Spacer(), actions]
                  : [
                      Expanded(child: brand),
                      stats,
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: actions,
                        ),
                      ),
                    ],
            ),
          );
        },
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.showName, required this.title});

  final bool showName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Image.asset(
            'assets/mascot/peek.png',
            height: 34,
            filterQuality: FilterQuality.medium,
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'CardSerif',
                fontSize: 19,
                color: PsitoColors.onFelt,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GameStats extends StatelessWidget {
  const _GameStats({required this.game, required this.showNumber});

  final GameController game;
  final bool showNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x26000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showNumber) ...[
              _Stat(label: l10n.statGame, value: '${game.number}'),
              const _StatDivider(),
            ],
            _Stat(label: l10n.statScore, value: '${game.score}'),
            const _StatDivider(),
            _GameClock(game: game, label: l10n.statTime),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => const VerticalDivider(
    width: 1,
    thickness: 1,
    indent: 4,
    endIndent: 4,
    color: Color(0x1FFFFFFF),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                height: 1.25,
                letterSpacing: .9,
                fontWeight: FontWeight.w600,
                color: PsitoColors.onFeltMuted,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: PsitoColors.onFelt,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The time played, redrawn once per second.
class _GameClock extends StatefulWidget {
  const _GameClock({required this.game, required this.label});

  final GameController game;
  final String label;

  @override
  State<_GameClock> createState() => _GameClockState();
}

class _GameClockState extends State<_GameClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _Stat(label: widget.label, value: formatTime(widget.game.seconds));
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 21),
    style: IconButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: PsitoColors.onFelt,
      disabledForegroundColor: PsitoColors.feltLight.withValues(alpha: .55),
      hoverColor: const Color(0x1AFFFFFF),
    ),
  );
}

class _NewGameButton extends StatelessWidget {
  const _NewGameButton({
    required this.label,
    required this.iconOnly,
    required this.onPressed,
  });

  final String label;
  final bool iconOnly;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: PsitoColors.cream,
      foregroundColor: PsitoColors.barBottom,
      padding: EdgeInsets.symmetric(horizontal: iconOnly ? 10 : 14),
      minimumSize: const Size(40, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    );
    const icon = Icon(Icons.casino_outlined, size: 19);
    if (iconOnly) {
      return Tooltip(
        message: '$label  (Ctrl+N)',
        child: FilledButton(onPressed: onPressed, style: style, child: icon),
      );
    }
    return Tooltip(
      message: 'Ctrl+N',
      child: FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon,
        label: Text(label),
      ),
    );
  }
}

class _BestGames extends StatelessWidget {
  const _BestGames();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.bestGames),
      content: SizedBox(
        width: 340,
        child: FutureBuilder<List<Score>>(
          future: const ScoreStore().load(),
          builder: (context, snapshot) =>
              ScoreTable(scores: snapshot.data ?? const []),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _HowToPlay extends StatelessWidget {
  const _HowToPlay();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.howToPlay),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: Text(l10n.howToPlayBody)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _ChooseGame extends StatefulWidget {
  const _ChooseGame({required this.onChosen});

  final void Function(int number) onChosen;

  @override
  State<_ChooseGame> createState() => _ChooseGameState();
}

class _ChooseGameState extends State<_ChooseGame> {
  final _number = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  int? get _value {
    final value = int.tryParse(_number.text);
    return value != null && value > 0 ? value : null;
  }

  void _submit() {
    final value = _value;
    if (value == null) return;
    Navigator.of(context).pop();
    widget.onChosen(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.chooseGame),
      content: TextField(
        controller: _number,
        autofocus: true,
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.statGame,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ListenableBuilder(
          listenable: _number,
          builder: (context, _) => FilledButton(
            onPressed: _value == null ? null : _submit,
            child: Text(l10n.play),
          ),
        ),
      ],
    );
  }
}
