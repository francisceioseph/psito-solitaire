// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => '你赢了！';

  @override
  String get emptyColumn => '空列，只能放 K';

  @override
  String nestOf(String suit) {
    return '$suit的鸟巢';
  }

  @override
  String cardName(String rank, String suit) {
    return '$suit$rank';
  }

  @override
  String get rankAce => 'A';

  @override
  String get rankJack => 'J';

  @override
  String get rankQueen => 'Q';

  @override
  String get rankKing => 'K';

  @override
  String get suitClubs => '梅花';

  @override
  String get suitSpades => '黑桃';

  @override
  String get suitHearts => '红桃';

  @override
  String get suitDiamonds => '方块';

  @override
  String winSummary(String moves, String time) {
    return '用时 $time，$moves';
  }

  @override
  String get howToPlayBody =>
      '按花色把所有的牌从 A 到 K 移到四个鸟巢里。\n\n在列中，一张牌可以放在比它大一点、颜色不同的牌上，顺序相连的牌可以一起移动。只有 K 可以放进空列。\n\n单击牌堆抽一张牌。牌堆抽完后，再单击一次把弃牌堆翻回去。\n\n得分：从弃牌堆移到列得 5 分，移进鸟巢得 10 分，每翻开一张牌得 5 分，从鸟巢取回一张牌扣 15 分，翻回弃牌堆扣 100 分。\n\nCtrl+Z 撤销，Ctrl+R 重新开始本局，Ctrl+N 开始新的一局。';

  @override
  String get aboutBody => '与玄凤鹦鹉一起玩的经典纸牌接龙。没有广告，没有遥测，也不需要账号。';

  @override
  String get aboutLegal => '代码采用 Apache 2.0 许可证。牌面美术采用 CC0。';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分',
    );
    return '$_temp0';
  }

  @override
  String get statScore => '得分';

  @override
  String get drawCard => '抽一张牌';

  @override
  String get turnWasteOver => '把弃牌堆翻回去';

  @override
  String get emptyWaste => '弃牌堆';

  @override
  String get faceDownCard => '背面朝上的牌';
}
