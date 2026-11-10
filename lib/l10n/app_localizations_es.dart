// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => '¡Ganaste!';

  @override
  String get emptyColumn => 'Columna vacía, solo reyes';

  @override
  String nestOf(String suit) {
    return 'Nido de $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'As';

  @override
  String get rankJack => 'Jota';

  @override
  String get rankQueen => 'Reina';

  @override
  String get rankKing => 'Rey';

  @override
  String get suitClubs => 'tréboles';

  @override
  String get suitSpades => 'picas';

  @override
  String get suitHearts => 'corazones';

  @override
  String get suitDiamonds => 'diamantes';

  @override
  String winSummary(String moves, String time) {
    return '$moves en $time';
  }

  @override
  String get howToPlayBody =>
      'Lleva todas las cartas a los cuatro nidos, del As al Rey, por palo.\n\nEn las columnas, una carta va sobre otra de un valor más alto y del otro color, y las secuencias se mueven juntas. Solo un Rey puede ir a una columna vacía.\n\nHaz clic en el mazo para robar una carta. Cuando se acabe, vuelve a hacer clic para dar la vuelta al descarte.\n\nPuntos: 5 del descarte a una columna, 10 a un nido, 5 por cada carta que se pone boca arriba, menos 15 por sacar una carta de un nido y menos 100 por dar la vuelta al descarte.\n\nCtrl+Z deshace, Ctrl+R reinicia esta partida y Ctrl+N empieza una nueva.';

  @override
  String get aboutBody =>
      'El solitario clásico con cacatúas ninfa. Sin anuncios, sin telemetría y sin cuenta.';

  @override
  String get aboutLegal =>
      'Código bajo la licencia Apache 2.0. Arte de las cartas bajo CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Puntos';

  @override
  String get drawCard => 'Robar una carta';

  @override
  String get turnWasteOver => 'Dar la vuelta al descarte';

  @override
  String get emptyWaste => 'Descarte';

  @override
  String get faceDownCard => 'Carta boca abajo';
}
