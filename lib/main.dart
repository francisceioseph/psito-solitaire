import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'src/ui/card_face.dart';
import 'src/ui/game_screen.dart';

void main() => runApp(const PsitoSolitaireApp());

class PsitoSolitaireApp extends StatelessWidget {
  const PsitoSolitaireApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PsitoColors.felt,
        brightness: Brightness.light,
      ),
    ),
    home: const GameScreen(),
  );
}
