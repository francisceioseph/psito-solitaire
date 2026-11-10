// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => 'Вы выиграли!';

  @override
  String get emptyColumn => 'Пустой столбец, только короли';

  @override
  String nestOf(String suit) {
    return 'Гнездо $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank $suit';
  }

  @override
  String get rankAce => 'Туз';

  @override
  String get rankJack => 'Валет';

  @override
  String get rankQueen => 'Дама';

  @override
  String get rankKing => 'Король';

  @override
  String get suitClubs => 'треф';

  @override
  String get suitSpades => 'пик';

  @override
  String get suitHearts => 'червей';

  @override
  String get suitDiamonds => 'бубен';

  @override
  String winSummary(String moves, String time) {
    return '$moves за $time';
  }

  @override
  String get howToPlayBody =>
      'Переложите все карты в четыре гнезда, от туза до короля, по мастям.\n\nВ столбцах карта кладётся на карту на ранг старше и другого цвета, а последовательности перемещаются вместе. В пустой столбец можно положить только короля.\n\nЩёлкните по колоде, чтобы взять карту. Когда она закончится, щёлкните ещё раз, чтобы перевернуть сброс.\n\nОчки: 5 за карту из сброса в столбец, 10 за карту в гнездо, 5 за каждую открытую карту, минус 15 за карту, взятую из гнезда, и минус 100 за переворот сброса.\n\nCtrl+Z отменяет ход, Ctrl+R начинает эту партию заново, а Ctrl+N начинает новую.';

  @override
  String get aboutBody =>
      'Классический пасьянс с кореллами. Без рекламы, без телеметрии и без учётной записи.';

  @override
  String get aboutLegal =>
      'Код под лицензией Apache 2.0. Рисунки карт под CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count очков',
      few: '$count очка',
      one: '$count очко',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Очки';

  @override
  String get drawCard => 'Взять карту';

  @override
  String get turnWasteOver => 'Перевернуть сброс';

  @override
  String get emptyWaste => 'Сброс';

  @override
  String get faceDownCard => 'Карта рубашкой вверх';
}
