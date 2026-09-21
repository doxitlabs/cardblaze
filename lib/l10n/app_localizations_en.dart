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
    return 'cards due: $count';
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
    return '$cards answered · $due remaining';
  }

  @override
  String get generate_title => 'AI Generate';

  @override
  String get generate_subtitle =>
      'Generate flashcards from text, topic, PDF or DOCX';

  @override
  String get text_mode => 'Text';

  @override
  String get topic_mode => 'Topic';

  @override
  String get pdf_mode => 'Document';

  @override
  String get select_deck => 'Select deck';

  @override
  String get new_deck => 'New deck';

  @override
  String get card_count => 'Max. number of cards';

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
  String get cards_this_week => 'Learned this week';

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
  String get deck_not_found => 'Deck not found';

  @override
  String get edit_deck_tooltip => 'Edit deck';

  @override
  String get delete_deck_tooltip => 'Delete deck';

  @override
  String get cards_section => 'Cards';

  @override
  String get stat_total => 'Total';

  @override
  String get stat_pending => 'Pending';

  @override
  String get stat_learned => 'Learned';

  @override
  String study_now_due(int count) {
    return 'Study Now ($count due)';
  }

  @override
  String get add_card_manual => 'Add card manually';

  @override
  String get no_cards_title => 'No Cards';

  @override
  String get no_cards_body => 'Add cards manually or use AI Generate.';

  @override
  String get no_cards_body_ai =>
      'Use AI Generate to create cards from text, topic or document.';

  @override
  String get edit_card_title => 'Edit card';

  @override
  String get new_card_title => 'New card';

  @override
  String get front_label => 'Question (front)';

  @override
  String get front_hint => 'Enter question...';

  @override
  String get back_label => 'Answer (back)';

  @override
  String get back_hint => 'Enter answer...';

  @override
  String get save_changes_btn => 'Save changes';

  @override
  String get save_card_btn => 'Save card';

  @override
  String get name_label => 'Name';

  @override
  String get streak_motivation_0 => 'Start today and build a habit!';

  @override
  String get streak_motivation_low => 'Great start — keep going!';

  @override
  String get streak_motivation_mid => 'Excellent! Every day counts.';

  @override
  String get streak_motivation_high => 'Amazing! You\'re on the right track.';

  @override
  String streak_motivation_legend(int days) {
    return 'Legend! $days days straight!';
  }

  @override
  String get ai_weekly_recap => 'AI Weekly Recap';

  @override
  String get refresh => 'Refresh';

  @override
  String get upgrade_ai_recap => 'Upgrade for AI recap';

  @override
  String get view_pro_btn => 'View Pro';

  @override
  String get pro_welcome => 'Welcome to CardBlaze Pro! 🎉';

  @override
  String get topic_hint => 'e.g. Photosynthesis, Roman law...';

  @override
  String get text_paste_hint => 'Paste text here...';

  @override
  String get upgrade_btn => 'Upgrade to Pro';

  @override
  String get upgrade_dialog_subtitle => 'Unlock all CardBlaze Pro features.';

  @override
  String get benefit_unlimited_decks => 'Unlimited decks (free: 1)';

  @override
  String get benefit_cards_per_deck => 'Up to 100 cards per deck (free: 15)';

  @override
  String get benefit_ai_generation => 'Unlimited AI card generation';

  @override
  String get benefit_pdf_import => 'PDF & DOCX import';

  @override
  String get benefit_advanced_stats => 'Advanced learning statistics';

  @override
  String get version => 'Version';

  @override
  String get question_label => 'QUESTION';

  @override
  String get no_cards_today => 'No cards for today!';

  @override
  String get all_cards_current => 'All cards are up to date.';

  @override
  String get back_btn => 'Back';

  @override
  String get session_complete => 'Session complete!';

  @override
  String get session_correct => 'Correct';

  @override
  String get session_incorrect => 'Incorrect';

  @override
  String get session_accuracy => 'Accuracy';

  @override
  String get finish_btn => 'Finish';

  @override
  String get next_btn => 'Next';

  @override
  String get notifications_on => 'Enabled';

  @override
  String get notifications_off => 'Tap to enable daily reminder';

  @override
  String get deck_all_learned => 'All learned';

  @override
  String get answered_label => 'Answered:';

  @override
  String get pending_label => 'pending';
}
