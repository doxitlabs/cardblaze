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
  String get deck_name_hint => 'Deck name';

  @override
  String get select_color => 'Select color';

  @override
  String get color_label => 'Color';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete_btn => 'Delete';

  @override
  String get study_now => 'Study Now';

  @override
  String get add_card => 'Add Card';

  @override
  String get front => 'Front';

  @override
  String get back => 'Back';

  @override
  String get my_decks => 'Your Decks';

  @override
  String get due_today => 'Due Today';

  @override
  String get all_done_today => 'All done today!';

  @override
  String get all_done_subtitle => 'No cards pending. Excellent!';

  @override
  String cards_waiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due',
      one: '1 card due',
    );
    return '$_temp0';
  }

  @override
  String get no_decks_title => 'No Decks';

  @override
  String get no_decks_body =>
      'Add your first deck and start learning with spaced repetition.';

  @override
  String get add_first_deck => 'Add First Deck';

  @override
  String get new_deck_label => 'New Deck';

  @override
  String get edit_deck => 'Edit Deck';

  @override
  String get delete_deck => 'Delete Deck';

  @override
  String get delete_confirm_title => 'Delete deck?';

  @override
  String delete_confirm_body(String name) {
    return 'This will permanently delete \"$name\" and all its cards.';
  }

  @override
  String deck_subtitle(int cards, int due) {
    return '$cards cards · $due due';
  }

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
  String cards_saved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards saved!',
      one: '1 card saved!',
    );
    return '$_temp0';
  }

  @override
  String get error_enter_text => 'Enter text or a topic.';

  @override
  String get error_select_deck => 'Select a deck or create a new one.';

  @override
  String get error_deck_name => 'Enter a name for the new deck.';

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
  String get appearance_section => 'Appearance';

  @override
  String get theme_label => 'Theme';

  @override
  String get light_theme => 'Light';

  @override
  String get dark_theme => 'Dark';

  @override
  String get language_section => 'Language';

  @override
  String get language_ui_label => 'UI Language';

  @override
  String get other_section => 'Other';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get manage_subscription => 'Manage subscription';

  @override
  String get restore_purchase => 'Restore Purchases';

  @override
  String get restore_snack_success => 'Purchase restored successfully!';

  @override
  String get restore_snack_none => 'No active subscription to restore.';

  @override
  String get restore_snack_error => 'Error restoring purchase.';

  @override
  String get current_plan => 'Your plan';

  @override
  String get free_plan => 'Free';

  @override
  String get pro_plan => 'Pro';

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
  String get nav_decks => 'Decks';

  @override
  String get nav_generate => 'Generate';

  @override
  String get nav_stats => 'Stats';

  @override
  String get nav_settings => 'Settings';

  @override
  String get upgrade_btn => 'Upgrade to Pro';

  @override
  String get version => 'Version';
}
