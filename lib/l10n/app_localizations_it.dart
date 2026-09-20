// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'CardBlaze';

  @override
  String get home_title => 'Oggi';

  @override
  String get today_card_title => 'Carte di oggi';

  @override
  String today_card_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
      zero: 'Tutto fatto!',
    );
    return '$_temp0';
  }

  @override
  String get no_cards_due => 'Tutto imparato oggi!';

  @override
  String get all_decks => 'Tutti i mazzi';

  @override
  String get add_deck => 'Aggiungi mazzo';

  @override
  String get deck_name => 'Nome del mazzo';

  @override
  String get deck_name_hint => 'Nome del mazzo';

  @override
  String get select_color => 'Seleziona colore';

  @override
  String get color_label => 'Colore';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete_btn => 'Elimina';

  @override
  String get study_now => 'Studia ora';

  @override
  String get add_card => 'Aggiungi carta';

  @override
  String get front => 'Fronte';

  @override
  String get back => 'Retro';

  @override
  String get my_decks => 'I tuoi mazzi';

  @override
  String get due_today => 'Da ripassare oggi';

  @override
  String get all_done_today => 'Tutto fatto per oggi!';

  @override
  String get all_done_subtitle => 'Nessuna carta in attesa. Eccellente!';

  @override
  String cards_waiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte da ripassare',
      one: '1 carta da ripassare',
    );
    return '$_temp0';
  }

  @override
  String get no_decks_title => 'Nessun mazzo';

  @override
  String get no_decks_body =>
      'Aggiungi il tuo primo mazzo e inizia ad imparare con la ripetizione spaziata.';

  @override
  String get add_first_deck => 'Aggiungi il primo mazzo';

  @override
  String get new_deck_label => 'Nuovo mazzo';

  @override
  String get edit_deck => 'Modifica mazzo';

  @override
  String get delete_deck => 'Elimina mazzo';

  @override
  String get delete_confirm_title => 'Eliminare il mazzo?';

  @override
  String delete_confirm_body(String name) {
    return 'Questo eliminerà definitivamente \"$name\" e tutte le sue carte.';
  }

  @override
  String deck_subtitle(int cards, int due) {
    return '$cards carte · $due da ripassare';
  }

  @override
  String get generate_title => 'Genera con IA';

  @override
  String get generate_subtitle => 'Genera carte da testo, argomento o PDF';

  @override
  String get text_mode => 'Testo';

  @override
  String get topic_mode => 'Argomento';

  @override
  String get pdf_mode => 'PDF';

  @override
  String get select_deck => 'Seleziona mazzo';

  @override
  String get new_deck => 'Nuovo mazzo';

  @override
  String get card_count => 'Numero di carte';

  @override
  String get generate_btn => 'Genera';

  @override
  String cards_saved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte salvate!',
      one: '1 carta salvata!',
    );
    return '$_temp0';
  }

  @override
  String get error_enter_text => 'Inserire testo o argomento.';

  @override
  String get error_select_deck => 'Selezionare un mazzo o crearne uno nuovo.';

  @override
  String get error_deck_name => 'Inserire il nome del nuovo mazzo.';

  @override
  String get stats_title => 'Statistiche';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
      zero: '0 giorni',
    );
    return '$_temp0';
  }

  @override
  String get cards_this_week => 'Carte questa settimana';

  @override
  String get accuracy => 'Precisione';

  @override
  String get total_cards => 'Carte totali';

  @override
  String get active_decks => 'Mazzi attivi';

  @override
  String get settings_title => 'Impostazioni';

  @override
  String get general_tab => 'Generale';

  @override
  String get subscription_tab => 'Abbonamento';

  @override
  String get appearance_section => 'Aspetto';

  @override
  String get theme_label => 'Tema';

  @override
  String get light_theme => 'Chiaro';

  @override
  String get dark_theme => 'Scuro';

  @override
  String get language_section => 'Lingua';

  @override
  String get language_ui_label => 'Lingua dell\'interfaccia';

  @override
  String get other_section => 'Altro';

  @override
  String get notifications => 'Notifiche';

  @override
  String get privacy => 'Informativa sulla privacy';

  @override
  String get about => 'Informazioni';

  @override
  String get manage_subscription => 'Gestisci abbonamento';

  @override
  String get restore_purchase => 'Ripristina acquisti';

  @override
  String get restore_snack_success => 'Acquisto ripristinato con successo!';

  @override
  String get restore_snack_none => 'Nessun abbonamento attivo da ripristinare.';

  @override
  String get restore_snack_error => 'Errore durante il ripristino.';

  @override
  String get current_plan => 'Il tuo piano';

  @override
  String get free_plan => 'Gratuito';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_title => 'Sblocca CardBlaze Pro';

  @override
  String get monthly_price => 'Mensile';

  @override
  String get yearly_price => 'Annuale';

  @override
  String save_percent(int percent) {
    return 'Risparmia il $percent%';
  }

  @override
  String get nav_decks => 'Mazzi';

  @override
  String get nav_generate => 'Genera';

  @override
  String get nav_stats => 'Stats';

  @override
  String get nav_settings => 'Impostazioni';

  @override
  String get upgrade_btn => 'Passa a Pro';

  @override
  String get version => 'Versione';
}
