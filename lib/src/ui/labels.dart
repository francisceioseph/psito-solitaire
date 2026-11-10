import '../../l10n/app_localizations.dart';
import '../game/game_state.dart';

/// The name of a card for screen readers, such as "Queen of hearts".
String cardName(AppLocalizations l10n, PlayingCard card) {
  final rank = switch (card.rank) {
    1 => l10n.rankAce,
    11 => l10n.rankJack,
    12 => l10n.rankQueen,
    13 => l10n.rankKing,
    _ => '${card.rank}',
  };
  return l10n.cardName(rank, suitName(l10n, card.suit));
}

String suitName(AppLocalizations l10n, Suit suit) => switch (suit) {
  Suit.clubs => l10n.suitClubs,
  Suit.spades => l10n.suitSpades,
  Suit.hearts => l10n.suitHearts,
  Suit.diamonds => l10n.suitDiamonds,
};
