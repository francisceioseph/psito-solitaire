// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => 'Gewonnen!';

  @override
  String get emptyColumn => 'Leere Spalte, nur Könige';

  @override
  String nestOf(String suit) {
    return 'Nest für $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$suit-$rank';
  }

  @override
  String get rankAce => 'Ass';

  @override
  String get rankJack => 'Bube';

  @override
  String get rankQueen => 'Dame';

  @override
  String get rankKing => 'König';

  @override
  String get suitClubs => 'Kreuz';

  @override
  String get suitSpades => 'Pik';

  @override
  String get suitHearts => 'Herz';

  @override
  String get suitDiamonds => 'Karo';

  @override
  String winSummary(String moves, String time) {
    return '$moves in $time';
  }

  @override
  String get howToPlayBody =>
      'Bringe alle Karten in die vier Nester, vom Ass bis zum König, nach Farbe.\n\nIn den Spalten kommt eine Karte auf eine um einen Rang höhere der anderen Farbe, und Folgen ziehen zusammen. Nur ein König darf in eine leere Spalte.\n\nKlicke auf den Stapel, um eine Karte zu ziehen. Ist er leer, klicke noch einmal, um die Ablage umzudrehen.\n\nPunkte: 5 von der Ablage in eine Spalte, 10 in ein Nest, 5 für jede aufgedeckte Karte, minus 15 für eine Karte, die aus einem Nest zurückgeholt wird, und minus 100 für das Umdrehen der Ablage.\n\nStrg+Z macht rückgängig, Strg+R startet dieses Spiel neu und Strg+N beginnt ein neues.';

  @override
  String get aboutBody =>
      'Klassische Patience mit Nymphensittichen. Ohne Werbung, ohne Telemetrie und ohne Konto.';

  @override
  String get aboutLegal =>
      'Code unter der Apache-2.0-Lizenz. Kartengrafiken unter CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte',
      one: '1 Punkt',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Punkte';

  @override
  String get drawCard => 'Karte ziehen';

  @override
  String get turnWasteOver => 'Ablage umdrehen';

  @override
  String get emptyWaste => 'Ablage';

  @override
  String get faceDownCard => 'Verdeckte Karte';
}
