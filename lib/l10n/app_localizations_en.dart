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
  String get ai_document_loaded => 'Document loaded';

  @override
  String ai_chars_loaded(int count) {
    return '$count characters loaded';
  }

  @override
  String ai_deck_limit_reached(int limit) {
    return 'This deck has reached the maximum number of cards ($limit).';
  }

  @override
  String get ai_unsaved_title => 'Cards not saved';

  @override
  String get ai_unsaved_body =>
      'If you leave this tab, the generated cards you haven\'t saved will be lost.';

  @override
  String get ai_leave_without_saving => 'Leave without saving';

  @override
  String error_text_too_long_pro(int max) {
    return 'Text exceeds the $max character limit. Split the content into parts and generate cards in multiple steps for the same deck.';
  }

  @override
  String error_generic(String details) {
    return 'Error: $details';
  }

  @override
  String get error_text_too_long_free =>
      'Text is too long for the Free plan. Upgrade to Pro for longer texts.';

  @override
  String get export_pdf_action => 'Export to PDF';

  @override
  String get export_pdf_empty => 'This deck has no cards to export.';

  @override
  String export_pdf_error(String details) {
    return 'Error exporting PDF: $details';
  }

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
  String get benefit_pdf_export => 'Export decks to PDF (with answers)';

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

  @override
  String get study_reset_title => 'Start over?';

  @override
  String study_reset_body(int count) {
    return 'All cards in this deck are learned ($count). Studying again will reset their progress. Continue?';
  }

  @override
  String get study_reset_confirm => 'Start over';

  @override
  String get notif_reminder_body => '📚 Time to study! Your cards are waiting.';

  @override
  String get notif_channel_name => 'Daily reminder';

  @override
  String get notif_channel_desc => 'Daily study reminder';

  @override
  String get ai_error_network =>
      'No internet connection. Check your connection and try again.';

  @override
  String get ai_error_failed => 'AI generation failed. Please try again.';

  @override
  String ai_daily_limit_reached(int limit, int used) {
    return 'Daily limit of $limit generations reached ($used/$limit). Upgrade to Pro for unlimited generation.';
  }

  @override
  String get error_loading_decks => 'Error loading decks';

  @override
  String ai_preview_title(int count) {
    return 'Preview ($count cards)';
  }

  @override
  String get open_in_browser => 'Open in browser';

  @override
  String get recap_blur_placeholder =>
      'You made great progress this week! Your accuracy went up and your streak continues. Focus on the harder cards next.';

  @override
  String get error_document_read =>
      'Could not read the document. Make sure it is a valid PDF or DOCX file.';

  @override
  String get color_blue => 'Blue';

  @override
  String get color_green => 'Green';

  @override
  String get color_purple => 'Purple';

  @override
  String get color_orange => 'Orange';

  @override
  String get color_teal => 'Teal';

  @override
  String get color_pink => 'Pink';

  @override
  String price_per_month(String price) {
    return '$price/mo';
  }

  @override
  String price_per_year(String price) {
    return '$price/yr';
  }
}
