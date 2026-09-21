// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'CardBlaze';

  @override
  String get home_title => 'Heute';

  @override
  String get today_card_title => 'Karten für heute';

  @override
  String today_card_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '1 Karte',
      zero: 'Alles erledigt!',
    );
    return '$_temp0';
  }

  @override
  String get no_cards_due => 'Alles gelernt heute!';

  @override
  String get all_decks => 'Alle Decks';

  @override
  String get add_deck => 'Deck hinzufügen';

  @override
  String get deck_name => 'Deck-Name';

  @override
  String get deck_name_hint => 'Deck-Name';

  @override
  String get select_color => 'Farbe wählen';

  @override
  String get color_label => 'Farbe';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete_btn => 'Löschen';

  @override
  String get study_now => 'Jetzt lernen';

  @override
  String get add_card => 'Karte hinzufügen';

  @override
  String get front => 'Vorderseite';

  @override
  String get back => 'Rückseite';

  @override
  String get my_decks => 'Deine Decks';

  @override
  String get due_today => 'Heute fällig';

  @override
  String get all_done_today => 'Alles für heute erledigt!';

  @override
  String get all_done_subtitle => 'Keine Karten ausstehend. Ausgezeichnet!';

  @override
  String cards_waiting(int count) {
    return 'Karten fällig: $count';
  }

  @override
  String get no_decks_title => 'Keine Decks';

  @override
  String get no_decks_body =>
      'Füge dein erstes Deck hinzu und beginne mit Spaced Repetition.';

  @override
  String get add_first_deck => 'Erstes Deck hinzufügen';

  @override
  String get new_deck_label => 'Neues Deck';

  @override
  String get edit_deck => 'Deck bearbeiten';

  @override
  String get delete_deck => 'Deck löschen';

  @override
  String get delete_confirm_title => 'Deck löschen?';

  @override
  String delete_confirm_body(String name) {
    return 'Dies löscht \"$name\" und alle Karten dauerhaft.';
  }

  @override
  String deck_subtitle(int cards, int due) {
    return '$cards beantwortet · $due verbleibend';
  }

  @override
  String get generate_title => 'KI-Generierung';

  @override
  String get generate_subtitle => 'Karten aus Text, Thema oder PDF generieren';

  @override
  String get text_mode => 'Text';

  @override
  String get topic_mode => 'Thema';

  @override
  String get pdf_mode => 'Dokument';

  @override
  String get select_deck => 'Deck auswählen';

  @override
  String get new_deck => 'Neues Deck';

  @override
  String get card_count => 'Max. Anzahl Karten';

  @override
  String get generate_btn => 'Generieren';

  @override
  String cards_saved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten gespeichert!',
      one: '1 Karte gespeichert!',
    );
    return '$_temp0';
  }

  @override
  String get error_enter_text => 'Text oder Thema eingeben.';

  @override
  String get error_select_deck => 'Deck auswählen oder neues erstellen.';

  @override
  String get error_deck_name => 'Namen für neues Deck eingeben.';

  @override
  String get stats_title => 'Statistiken';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
      zero: '0 Tage',
    );
    return '$_temp0';
  }

  @override
  String get cards_this_week => 'Gelernt diese Woche';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get total_cards => 'Karten gesamt';

  @override
  String get active_decks => 'Aktive Decks';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get general_tab => 'Allgemein';

  @override
  String get subscription_tab => 'Abonnement';

  @override
  String get appearance_section => 'Aussehen';

  @override
  String get theme_label => 'Design';

  @override
  String get light_theme => 'Hell';

  @override
  String get dark_theme => 'Dunkel';

  @override
  String get language_section => 'Sprache';

  @override
  String get language_ui_label => 'Oberflächensprache';

  @override
  String get other_section => 'Sonstiges';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get about => 'Über die App';

  @override
  String get manage_subscription => 'Abonnement verwalten';

  @override
  String get restore_purchase => 'Käufe wiederherstellen';

  @override
  String get restore_snack_success => 'Kauf erfolgreich wiederhergestellt!';

  @override
  String get restore_snack_none =>
      'Kein aktives Abonnement zum Wiederherstellen.';

  @override
  String get restore_snack_error => 'Fehler beim Wiederherstellen.';

  @override
  String get current_plan => 'Dein Plan';

  @override
  String get free_plan => 'Kostenlos';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_title => 'CardBlaze Pro freischalten';

  @override
  String get monthly_price => 'Monatlich';

  @override
  String get yearly_price => 'Jährlich';

  @override
  String save_percent(int percent) {
    return '$percent% sparen';
  }

  @override
  String get nav_decks => 'Decks';

  @override
  String get nav_generate => 'Generieren';

  @override
  String get nav_stats => 'Statistik';

  @override
  String get nav_settings => 'Einstellungen';

  @override
  String get deck_not_found => 'Deck nicht gefunden';

  @override
  String get edit_deck_tooltip => 'Deck bearbeiten';

  @override
  String get delete_deck_tooltip => 'Deck löschen';

  @override
  String get cards_section => 'Karten';

  @override
  String get stat_total => 'Gesamt';

  @override
  String get stat_pending => 'Ausstehend';

  @override
  String get stat_learned => 'Gelernt';

  @override
  String study_now_due(int count) {
    return 'Jetzt lernen ($count fällig)';
  }

  @override
  String get add_card_manual => 'Karte manuell hinzufügen';

  @override
  String get no_cards_title => 'Keine Karten';

  @override
  String get no_cards_body =>
      'Füge Karten manuell hinzu oder nutze AI Generate.';

  @override
  String get no_cards_body_ai =>
      'Nutze AI Generate, um Karten aus Text, Thema oder Dokument zu erstellen.';

  @override
  String get edit_card_title => 'Karte bearbeiten';

  @override
  String get new_card_title => 'Neue Karte';

  @override
  String get front_label => 'Frage (Vorderseite)';

  @override
  String get front_hint => 'Frage eingeben...';

  @override
  String get back_label => 'Antwort (Rückseite)';

  @override
  String get back_hint => 'Antwort eingeben...';

  @override
  String get save_changes_btn => 'Änderungen speichern';

  @override
  String get save_card_btn => 'Karte speichern';

  @override
  String get name_label => 'Name';

  @override
  String get streak_motivation_0 =>
      'Fang heute an und bau eine Gewohnheit auf!';

  @override
  String get streak_motivation_low => 'Guter Start — weiter so!';

  @override
  String get streak_motivation_mid => 'Ausgezeichnet! Jeder Tag zählt.';

  @override
  String get streak_motivation_high =>
      'Erstaunlich! Du bist auf dem richtigen Weg.';

  @override
  String streak_motivation_legend(int days) {
    return 'Legende! $days Tage am Stück!';
  }

  @override
  String get upgrade_ai_recap => 'Für KI-Recap upgraden';

  @override
  String get view_pro_btn => 'Pro ansehen';

  @override
  String get pro_welcome => 'Willkommen bei CardBlaze Pro! 🎉';

  @override
  String get topic_hint => 'z.B. Fotosynthese, Römisches Recht...';

  @override
  String get text_paste_hint => 'Text hier einfügen...';

  @override
  String get upgrade_btn => 'Auf Pro upgraden';

  @override
  String get upgrade_dialog_subtitle =>
      'Schalte alle CardBlaze Pro-Funktionen frei.';

  @override
  String get benefit_unlimited_decks => 'Unbegrenzte Decks (kostenlos: 1)';

  @override
  String get benefit_cards_per_deck =>
      'Bis zu 100 Karten pro Deck (kostenlos: 15)';

  @override
  String get benefit_ai_generation => 'Unbegrenzte KI-Kartengenerierung';

  @override
  String get benefit_pdf_import => 'PDF & DOCX Import';

  @override
  String get benefit_advanced_stats => 'Erweiterte Lernstatistiken';

  @override
  String get version => 'Version';

  @override
  String get question_label => 'FRAGE';

  @override
  String get no_cards_today => 'Keine Karten für heute!';

  @override
  String get all_cards_current => 'Alle Karten sind aktuell.';

  @override
  String get back_btn => 'Zurück';

  @override
  String get session_complete => 'Einheit abgeschlossen!';

  @override
  String get session_correct => 'Richtig';

  @override
  String get session_incorrect => 'Falsch';

  @override
  String get session_accuracy => 'Genauigkeit';

  @override
  String get finish_btn => 'Fertig';

  @override
  String get next_btn => 'Weiter';

  @override
  String get notifications_on => 'Aktiviert';

  @override
  String get notifications_off => 'Tippen um tägliche Erinnerung zu aktivieren';

  @override
  String get deck_all_learned => 'Alles gelernt';
}
