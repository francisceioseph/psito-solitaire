import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Psito Solitaire'**
  String get appTitle;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get youWon;

  /// No description provided for @emptyColumn.
  ///
  /// In en, this message translates to:
  /// **'Empty column, kings only'**
  String get emptyColumn;

  /// No description provided for @nestOf.
  ///
  /// In en, this message translates to:
  /// **'Nest of {suit}'**
  String nestOf(String suit);

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'{rank} of {suit}'**
  String cardName(String rank, String suit);

  /// No description provided for @rankAce.
  ///
  /// In en, this message translates to:
  /// **'Ace'**
  String get rankAce;

  /// No description provided for @rankJack.
  ///
  /// In en, this message translates to:
  /// **'Jack'**
  String get rankJack;

  /// No description provided for @rankQueen.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get rankQueen;

  /// No description provided for @rankKing.
  ///
  /// In en, this message translates to:
  /// **'King'**
  String get rankKing;

  /// No description provided for @suitClubs.
  ///
  /// In en, this message translates to:
  /// **'clubs'**
  String get suitClubs;

  /// No description provided for @suitSpades.
  ///
  /// In en, this message translates to:
  /// **'spades'**
  String get suitSpades;

  /// No description provided for @suitHearts.
  ///
  /// In en, this message translates to:
  /// **'hearts'**
  String get suitHearts;

  /// No description provided for @suitDiamonds.
  ///
  /// In en, this message translates to:
  /// **'diamonds'**
  String get suitDiamonds;

  /// No description provided for @winSummary.
  ///
  /// In en, this message translates to:
  /// **'{moves} in {time}'**
  String winSummary(String moves, String time);

  /// No description provided for @howToPlayBody.
  ///
  /// In en, this message translates to:
  /// **'Move all the cards to the four nests, from Ace to King, by suit.\n\nIn the columns, a card goes on one rank higher, of the other colour, and sequences move together. Only a King can go to an empty column.\n\nClick the deck to draw a card. When it runs out, click again to turn the waste over.\n\nPoints: 5 from the waste to a column, 10 to a nest, 5 for each card turned face up, minus 15 for taking a card from a nest and minus 100 for turning the waste over.\n\nCtrl+Z undoes, Ctrl+R restarts this game and Ctrl+N starts a new one.'**
  String get howToPlayBody;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Classic solitaire with cockatiels. No ads, no telemetry and no account.'**
  String get aboutBody;

  /// No description provided for @aboutLegal.
  ///
  /// In en, this message translates to:
  /// **'Code under the Apache 2.0 license. Card art under CC0.'**
  String get aboutLegal;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 point} other{{count} points}}'**
  String points(int count);

  /// No description provided for @statScore.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statScore;

  /// No description provided for @drawCard.
  ///
  /// In en, this message translates to:
  /// **'Draw a card'**
  String get drawCard;

  /// No description provided for @turnWasteOver.
  ///
  /// In en, this message translates to:
  /// **'Turn the waste over'**
  String get turnWasteOver;

  /// No description provided for @emptyWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get emptyWaste;

  /// No description provided for @faceDownCard.
  ///
  /// In en, this message translates to:
  /// **'Face-down card'**
  String get faceDownCard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
