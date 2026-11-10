// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => 'You won!';

  @override
  String get emptyColumn => 'Empty column, kings only';

  @override
  String nestOf(String suit) {
    return 'Nest of $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank of $suit';
  }

  @override
  String get rankAce => 'Ace';

  @override
  String get rankJack => 'Jack';

  @override
  String get rankQueen => 'Queen';

  @override
  String get rankKing => 'King';

  @override
  String get suitClubs => 'clubs';

  @override
  String get suitSpades => 'spades';

  @override
  String get suitHearts => 'hearts';

  @override
  String get suitDiamonds => 'diamonds';

  @override
  String winSummary(String moves, String time) {
    return '$moves in $time';
  }

  @override
  String get howToPlayBody =>
      'Move all the cards to the four nests, from Ace to King, by suit.\n\nIn the columns, a card goes on one rank higher, of the other colour, and sequences move together. Only a King can go to an empty column.\n\nClick the deck to draw a card. When it runs out, click again to turn the waste over.\n\nPoints: 5 from the waste to a column, 10 to a nest, 5 for each card turned face up, minus 15 for taking a card from a nest and minus 100 for turning the waste over.\n\nCtrl+Z undoes, Ctrl+R restarts this game and Ctrl+N starts a new one.';

  @override
  String get aboutBody =>
      'Classic solitaire with cockatiels. No ads, no telemetry and no account.';

  @override
  String get aboutLegal =>
      'Code under the Apache 2.0 license. Card art under CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Points';

  @override
  String get drawCard => 'Draw a card';

  @override
  String get turnWasteOver => 'Turn the waste over';

  @override
  String get emptyWaste => 'Waste';

  @override
  String get faceDownCard => 'Face-down card';
}
