// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Psito Solitaire';

  @override
  String get youWon => 'Você venceu!';

  @override
  String get emptyColumn => 'Coluna vazia, só para Reis';

  @override
  String nestOf(String suit) {
    return 'Ninho de $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'Ás';

  @override
  String get rankJack => 'Valete';

  @override
  String get rankQueen => 'Dama';

  @override
  String get rankKing => 'Rei';

  @override
  String get suitClubs => 'paus';

  @override
  String get suitSpades => 'espadas';

  @override
  String get suitHearts => 'copas';

  @override
  String get suitDiamonds => 'ouros';

  @override
  String winSummary(String moves, String time) {
    return '$moves em $time';
  }

  @override
  String get howToPlayBody =>
      'Leve todas as cartas para os quatro ninhos, do Ás ao Rei, por naipe.\n\nNas colunas, a carta vai sobre outra um número acima, de cor diferente, e as sequências se movem juntas. Só um Rei pode ir para uma coluna vazia.\n\nClique no monte para comprar uma carta. Quando ele acabar, clique de novo para virar o descarte.\n\nPontos: 5 do descarte para uma coluna, 10 para um ninho, 5 por carta revelada, menos 15 ao tirar uma carta de um ninho e menos 100 ao virar o descarte.\n\nCtrl+Z desfaz, Ctrl+R recomeça este jogo e Ctrl+N começa um novo.';

  @override
  String get aboutBody =>
      'Paciência clássica com calopsitas. Sem anúncios, sem telemetria e sem conta.';

  @override
  String get aboutLegal =>
      'Código sob a licença Apache 2.0. Arte das cartas sob CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos',
      one: '1 ponto',
      zero: '0 pontos',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Pontos';

  @override
  String get drawCard => 'Comprar uma carta';

  @override
  String get turnWasteOver => 'Virar o descarte';

  @override
  String get emptyWaste => 'Descarte';

  @override
  String get faceDownCard => 'Carta virada para baixo';
}
