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
  String get pdf_mode => 'Documento';

  @override
  String get select_deck => 'Seleziona mazzo';

  @override
  String get new_deck => 'Nuovo mazzo';

  @override
  String get card_count => 'N. max. di carte';

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
  String get deck_not_found => 'Mazzo non trovato';

  @override
  String get edit_deck_tooltip => 'Modifica mazzo';

  @override
  String get delete_deck_tooltip => 'Elimina mazzo';

  @override
  String get cards_section => 'Carte';

  @override
  String get stat_total => 'Totale';

  @override
  String get stat_pending => 'In attesa';

  @override
  String get stat_learned => 'Appreso';

  @override
  String study_now_due(int count) {
    return 'Studia ora ($count in attesa)';
  }

  @override
  String get add_card_manual => 'Aggiungi carta manualmente';

  @override
  String get no_cards_title => 'Nessuna carta';

  @override
  String get no_cards_body => 'Aggiungi carte manualmente o usa AI Generate.';

  @override
  String get no_cards_body_ai =>
      'Usa AI Generate per creare carte da testo, argomento o documento.';

  @override
  String get edit_card_title => 'Modifica carta';

  @override
  String get new_card_title => 'Nuova carta';

  @override
  String get front_label => 'Domanda (fronte)';

  @override
  String get front_hint => 'Inserisci domanda...';

  @override
  String get back_label => 'Risposta (retro)';

  @override
  String get back_hint => 'Inserisci risposta...';

  @override
  String get save_changes_btn => 'Salva modifiche';

  @override
  String get save_card_btn => 'Salva carta';

  @override
  String get name_label => 'Nome';

  @override
  String get streak_motivation_0 => 'Inizia oggi e costruisci un\'abitudine!';

  @override
  String get streak_motivation_low => 'Ottimo inizio — continua così!';

  @override
  String get streak_motivation_mid => 'Eccellente! Ogni giorno conta.';

  @override
  String get streak_motivation_high => 'Incredibile! Sei sulla strada giusta.';

  @override
  String streak_motivation_legend(int days) {
    return 'Leggenda! $days giorni consecutivi!';
  }

  @override
  String get upgrade_ai_recap => 'Passa a Pro per il riepilogo IA';

  @override
  String get view_pro_btn => 'Vedi Pro';

  @override
  String get pro_welcome => 'Benvenuto in CardBlaze Pro! 🎉';

  @override
  String get topic_hint => 'es. Fotosintesi, Diritto romano...';

  @override
  String get text_paste_hint => 'Incolla il testo qui...';

  @override
  String get upgrade_btn => 'Passa a Pro';

  @override
  String get upgrade_dialog_subtitle =>
      'Sblocca tutte le funzionalità di CardBlaze Pro.';

  @override
  String get benefit_unlimited_decks => 'Mazzi illimitati (gratuito: 1)';

  @override
  String get benefit_cards_per_deck =>
      'Fino a 100 carte per mazzo (gratuito: 20)';

  @override
  String get benefit_ai_generation => 'Generazione IA illimitata';

  @override
  String get benefit_pdf_import => 'Importazione PDF e DOCX';

  @override
  String get benefit_advanced_stats => 'Statistiche di apprendimento avanzate';

  @override
  String get version => 'Versione';

  @override
  String get question_label => 'DOMANDA';

  @override
  String get no_cards_today => 'Nessuna carta per oggi!';

  @override
  String get all_cards_current => 'Tutte le carte sono aggiornate.';

  @override
  String get back_btn => 'Indietro';

  @override
  String get session_complete => 'Sessione completata!';

  @override
  String get session_correct => 'Corretto';

  @override
  String get session_incorrect => 'Errato';

  @override
  String get session_accuracy => 'Precisione';

  @override
  String get finish_btn => 'Fine';

  @override
  String get notifications_on => 'Attivato';

  @override
  String get notifications_off =>
      'Tocca per attivare il promemoria giornaliero';
}
