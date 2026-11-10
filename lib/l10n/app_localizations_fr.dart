// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => 'Vous avez gagné !';

  @override
  String get emptyColumn => 'Colonne vide, rois seulement';

  @override
  String nestOf(String suit) {
    return 'Nid de $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'As';

  @override
  String get rankJack => 'Valet';

  @override
  String get rankQueen => 'Dame';

  @override
  String get rankKing => 'Roi';

  @override
  String get suitClubs => 'trèfle';

  @override
  String get suitSpades => 'pique';

  @override
  String get suitHearts => 'cœur';

  @override
  String get suitDiamonds => 'carreau';

  @override
  String winSummary(String moves, String time) {
    return '$moves en $time';
  }

  @override
  String get howToPlayBody =>
      'Placez toutes les cartes dans les quatre nids, de l’As au Roi, par couleur.\n\nDans les colonnes, une carte se pose sur une carte d’un rang au-dessus, de l’autre couleur, et les suites bougent ensemble. Seul un Roi peut aller dans une colonne vide.\n\nCliquez sur la pioche pour tirer une carte. Quand elle est vide, cliquez encore pour retourner la défausse.\n\nPoints : 5 de la défausse vers une colonne, 10 vers un nid, 5 pour chaque carte retournée face visible, moins 15 pour reprendre une carte d’un nid et moins 100 pour retourner la défausse.\n\nCtrl+Z annule, Ctrl+R recommence cette partie et Ctrl+N en lance une nouvelle.';

  @override
  String get aboutBody =>
      'La réussite classique avec des calopsittes. Sans publicité, sans télémétrie et sans compte.';

  @override
  String get aboutLegal =>
      'Code sous licence Apache 2.0. Illustrations des cartes sous CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
      zero: '0 point',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Points';

  @override
  String get drawCard => 'Piocher une carte';

  @override
  String get turnWasteOver => 'Retourner la défausse';

  @override
  String get emptyWaste => 'Défausse';

  @override
  String get faceDownCard => 'Carte face cachée';
}
