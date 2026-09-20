import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_it.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('hr'),
    Locale('it')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CardBlaze'**
  String get appName;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get home_title;

  /// No description provided for @today_card_title.
  ///
  /// In en, this message translates to:
  /// **'Cards due today'**
  String get today_card_title;

  /// No description provided for @today_card_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All done!} =1{1 card} other{{count} cards}}'**
  String today_card_count(int count);

  /// No description provided for @no_cards_due.
  ///
  /// In en, this message translates to:
  /// **'All learned today!'**
  String get no_cards_due;

  /// No description provided for @all_decks.
  ///
  /// In en, this message translates to:
  /// **'All Decks'**
  String get all_decks;

  /// No description provided for @add_deck.
  ///
  /// In en, this message translates to:
  /// **'Add Deck'**
  String get add_deck;

  /// No description provided for @deck_name.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deck_name;

  /// No description provided for @deck_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deck_name_hint;

  /// No description provided for @select_color.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get select_color;

  /// No description provided for @color_label.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color_label;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete_btn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_btn;

  /// No description provided for @study_now.
  ///
  /// In en, this message translates to:
  /// **'Study Now'**
  String get study_now;

  /// No description provided for @add_card.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get add_card;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @my_decks.
  ///
  /// In en, this message translates to:
  /// **'Your Decks'**
  String get my_decks;

  /// No description provided for @due_today.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get due_today;

  /// No description provided for @all_done_today.
  ///
  /// In en, this message translates to:
  /// **'All done today!'**
  String get all_done_today;

  /// No description provided for @all_done_subtitle.
  ///
  /// In en, this message translates to:
  /// **'No cards pending. Excellent!'**
  String get all_done_subtitle;

  /// No description provided for @cards_waiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card due} other{{count} cards due}}'**
  String cards_waiting(int count);

  /// No description provided for @no_decks_title.
  ///
  /// In en, this message translates to:
  /// **'No Decks'**
  String get no_decks_title;

  /// No description provided for @no_decks_body.
  ///
  /// In en, this message translates to:
  /// **'Add your first deck and start learning with spaced repetition.'**
  String get no_decks_body;

  /// No description provided for @add_first_deck.
  ///
  /// In en, this message translates to:
  /// **'Add First Deck'**
  String get add_first_deck;

  /// No description provided for @new_deck_label.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get new_deck_label;

  /// No description provided for @edit_deck.
  ///
  /// In en, this message translates to:
  /// **'Edit Deck'**
  String get edit_deck;

  /// No description provided for @delete_deck.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck'**
  String get delete_deck;

  /// No description provided for @delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete deck?'**
  String get delete_confirm_title;

  /// No description provided for @delete_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\" and all its cards.'**
  String delete_confirm_body(String name);

  /// No description provided for @deck_subtitle.
  ///
  /// In en, this message translates to:
  /// **'{cards} cards · {due} due'**
  String deck_subtitle(int cards, int due);

  /// No description provided for @generate_title.
  ///
  /// In en, this message translates to:
  /// **'AI Generate'**
  String get generate_title;

  /// No description provided for @generate_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate flashcards from text, topic, or PDF'**
  String get generate_subtitle;

  /// No description provided for @text_mode.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text_mode;

  /// No description provided for @topic_mode.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topic_mode;

  /// No description provided for @pdf_mode.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf_mode;

  /// No description provided for @select_deck.
  ///
  /// In en, this message translates to:
  /// **'Select deck'**
  String get select_deck;

  /// No description provided for @new_deck.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get new_deck;

  /// No description provided for @card_count.
  ///
  /// In en, this message translates to:
  /// **'Number of cards'**
  String get card_count;

  /// No description provided for @generate_btn.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate_btn;

  /// No description provided for @cards_saved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card saved!} other{{count} cards saved!}}'**
  String cards_saved(int count);

  /// No description provided for @error_enter_text.
  ///
  /// In en, this message translates to:
  /// **'Enter text or a topic.'**
  String get error_enter_text;

  /// No description provided for @error_select_deck.
  ///
  /// In en, this message translates to:
  /// **'Select a deck or create a new one.'**
  String get error_select_deck;

  /// No description provided for @error_deck_name.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the new deck.'**
  String get error_deck_name;

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats_title;

  /// No description provided for @streak_days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String streak_days(int count);

  /// No description provided for @cards_this_week.
  ///
  /// In en, this message translates to:
  /// **'Cards this week'**
  String get cards_this_week;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @total_cards.
  ///
  /// In en, this message translates to:
  /// **'Total cards'**
  String get total_cards;

  /// No description provided for @active_decks.
  ///
  /// In en, this message translates to:
  /// **'Active decks'**
  String get active_decks;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @general_tab.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general_tab;

  /// No description provided for @subscription_tab.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription_tab;

  /// No description provided for @appearance_section.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance_section;

  /// No description provided for @theme_label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme_label;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark_theme;

  /// No description provided for @language_section.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_section;

  /// No description provided for @language_ui_label.
  ///
  /// In en, this message translates to:
  /// **'UI Language'**
  String get language_ui_label;

  /// No description provided for @other_section.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_section;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manage_subscription;

  /// No description provided for @restore_purchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore_purchase;

  /// No description provided for @restore_snack_success.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored successfully!'**
  String get restore_snack_success;

  /// No description provided for @restore_snack_none.
  ///
  /// In en, this message translates to:
  /// **'No active subscription to restore.'**
  String get restore_snack_none;

  /// No description provided for @restore_snack_error.
  ///
  /// In en, this message translates to:
  /// **'Error restoring purchase.'**
  String get restore_snack_error;

  /// No description provided for @current_plan.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get current_plan;

  /// No description provided for @free_plan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free_plan;

  /// No description provided for @pro_plan.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro_plan;

  /// No description provided for @upgrade_title.
  ///
  /// In en, this message translates to:
  /// **'Unlock CardBlaze Pro'**
  String get upgrade_title;

  /// No description provided for @monthly_price.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly_price;

  /// No description provided for @yearly_price.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly_price;

  /// No description provided for @save_percent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String save_percent(int percent);

  /// No description provided for @nav_decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get nav_decks;

  /// No description provided for @nav_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get nav_generate;

  /// No description provided for @nav_stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get nav_stats;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @upgrade_btn.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgrade_btn;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'hr', 'it'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
