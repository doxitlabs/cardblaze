// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CardBlaze';

  @override
  String get home_title => 'Today';

  @override
  String get today_card_title => 'Cards due today';

  @override
  String today_card_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
      zero: 'All done!',
    );
    return '$_temp0';
  }

  @override
  String get no_cards_due => 'All learned today!';

  @override
  String get all_decks => 'All Decks';

  @override
  String get add_deck => 'Add Deck';

  @override
  String get deck_name => 'Deck name';

  @override
  String get select_color => 'Select color';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get study_now => 'Study Now';

  @override
  String get add_card => 'Add Card';

  @override
  String get front => 'Front';

  @override
  String get back => 'Back';

  @override
  String get generate_title => 'AI Generate';

  @override
  String get generate_subtitle =>
      'Generate flashcards from text, topic, or PDF';

  @override
  String get text_mode => 'Text';

  @override
  String get topic_mode => 'Topic';

  @override
  String get pdf_mode => 'PDF';

  @override
  String get select_deck => 'Select deck';

  @override
  String get new_deck => 'New deck';

  @override
  String get card_count => 'Number of cards';

  @override
  String get generate_btn => 'Generate';

  @override
  String get stats_title => 'Statistics';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get cards_this_week => 'Cards this week';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get total_cards => 'Total cards';

  @override
  String get active_decks => 'Active decks';

  @override
  String get settings_title => 'Settings';

  @override
  String get general_tab => 'General';

  @override
  String get subscription_tab => 'Subscription';

  @override
  String get theme_label => 'Theme';

  @override
  String get light_theme => 'Light';

  @override
  String get dark_theme => 'Dark';

  @override
  String get language_label => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get upgrade_title => 'Unlock CardBlaze Pro';

  @override
  String get monthly_price => 'Monthly';

  @override
  String get yearly_price => 'Yearly';

  @override
  String save_percent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get restore_purchase => 'Restore Purchases';

  @override
  String get current_plan => 'Current plan';

  @override
  String get free_plan => 'Free';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_btn => 'Upgrade to Pro';
}
