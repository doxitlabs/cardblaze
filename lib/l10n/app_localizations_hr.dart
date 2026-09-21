// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'CardBlaze';

  @override
  String get home_title => 'Danas';

  @override
  String get today_card_title => 'Kartice za danas';

  @override
  String today_card_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartice',
      one: '1 kartica',
      zero: 'Sve završeno!',
    );
    return '$_temp0';
  }

  @override
  String get no_cards_due => 'Sve naučeno danas!';

  @override
  String get all_decks => 'Svi deckovi';

  @override
  String get add_deck => 'Dodaj deck';

  @override
  String get deck_name => 'Naziv decka';

  @override
  String get deck_name_hint => 'Naziv decka';

  @override
  String get select_color => 'Odaberi boju';

  @override
  String get color_label => 'Boja';

  @override
  String get save => 'Spremi';

  @override
  String get cancel => 'Odustani';

  @override
  String get delete_btn => 'Obriši';

  @override
  String get study_now => 'Uči sada';

  @override
  String get add_card => 'Dodaj karticu';

  @override
  String get front => 'Prednja strana';

  @override
  String get back => 'Stražnja strana';

  @override
  String get my_decks => 'Tvoji deckovi';

  @override
  String get due_today => 'Na redu danas';

  @override
  String get all_done_today => 'Sve naučeno za danas!';

  @override
  String get all_done_subtitle => 'Nema kartica na čekanju. Odlično!';

  @override
  String cards_waiting(int count) {
    return 'kartica na čekanju: $count';
  }

  @override
  String get no_decks_title => 'Nema deckova';

  @override
  String get no_decks_body =>
      'Dodaj prvi deck i počni učiti s pametnim ponavljanjem.';

  @override
  String get add_first_deck => 'Dodaj prvi deck';

  @override
  String get new_deck_label => 'Novi deck';

  @override
  String get edit_deck => 'Uredi deck';

  @override
  String get delete_deck => 'Obriši deck';

  @override
  String get delete_confirm_title => 'Obriši deck?';

  @override
  String delete_confirm_body(String name) {
    return 'Ovo će trajno obrisati \"$name\" i sve njegove kartice.';
  }

  @override
  String deck_subtitle(int cards, int due) {
    return '$cards odgovorenih · $due preostalo';
  }

  @override
  String get generate_title => 'AI Generiranje';

  @override
  String get generate_subtitle =>
      'Generiraj kartice iz teksta, teme, PDF-a ili DOCX-a';

  @override
  String get text_mode => 'Tekst';

  @override
  String get topic_mode => 'Tema';

  @override
  String get pdf_mode => 'Dokument';

  @override
  String get select_deck => 'Odaberi deck';

  @override
  String get new_deck => 'Novi deck';

  @override
  String get card_count => 'Maks. broj kartica';

  @override
  String get generate_btn => 'Generiraj';

  @override
  String cards_saved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartica spremljeno!',
      one: '1 kartica spremljena!',
    );
    return '$_temp0';
  }

  @override
  String get error_enter_text => 'Unesi tekst ili temu.';

  @override
  String get error_select_deck => 'Odaberi deck ili kreiraj novi.';

  @override
  String get error_deck_name => 'Unesi naziv novog decka.';

  @override
  String get stats_title => 'Statistika';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dana',
      one: '1 dan',
      zero: '0 dana',
    );
    return '$_temp0';
  }

  @override
  String get cards_this_week => 'Naučeno ovaj tjedan';

  @override
  String get accuracy => 'Točnost';

  @override
  String get total_cards => 'Ukupno kartica';

  @override
  String get active_decks => 'Aktivni deckovi';

  @override
  String get settings_title => 'Postavke';

  @override
  String get general_tab => 'Opće';

  @override
  String get subscription_tab => 'Pretplata';

  @override
  String get appearance_section => 'Izgled';

  @override
  String get theme_label => 'Tema';

  @override
  String get light_theme => 'Svijetla';

  @override
  String get dark_theme => 'Tamna';

  @override
  String get language_section => 'Jezik';

  @override
  String get language_ui_label => 'Jezik sučelja';

  @override
  String get other_section => 'Ostalo';

  @override
  String get notifications => 'Obavijesti';

  @override
  String get privacy => 'Pravila privatnosti';

  @override
  String get about => 'O aplikaciji';

  @override
  String get manage_subscription => 'Upravljaj pretplatom';

  @override
  String get restore_purchase => 'Obnovi kupnju';

  @override
  String get restore_snack_success => 'Kupnja uspješno obnovljena!';

  @override
  String get restore_snack_none => 'Nema aktivne pretplate za obnovu.';

  @override
  String get restore_snack_error => 'Greška pri obnovi kupnje.';

  @override
  String get current_plan => 'Tvoj plan';

  @override
  String get free_plan => 'Besplatan';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_title => 'Otključaj CardBlaze Pro';

  @override
  String get monthly_price => 'Mjesečno';

  @override
  String get yearly_price => 'Godišnje';

  @override
  String save_percent(int percent) {
    return 'Uštedi $percent%';
  }

  @override
  String get nav_decks => 'Deckovi';

  @override
  String get nav_generate => 'Generiraj';

  @override
  String get nav_stats => 'Statistika';

  @override
  String get nav_settings => 'Postavke';

  @override
  String get deck_not_found => 'Deck nije pronađen';

  @override
  String get edit_deck_tooltip => 'Uredi deck';

  @override
  String get delete_deck_tooltip => 'Obriši deck';

  @override
  String get cards_section => 'Kartice';

  @override
  String get stat_total => 'Ukupno';

  @override
  String get stat_pending => 'Na čekanju';

  @override
  String get stat_learned => 'Naučeno';

  @override
  String study_now_due(int count) {
    return 'Učiti sada ($count na redu)';
  }

  @override
  String get add_card_manual => 'Dodaj karticu ručno';

  @override
  String get no_cards_title => 'Nema kartica';

  @override
  String get no_cards_body => 'Dodaj kartice ručno ili koristi AI Generate.';

  @override
  String get no_cards_body_ai =>
      'Koristi AI Generate za kreiranje kartica iz teksta, teme ili dokumenta.';

  @override
  String get edit_card_title => 'Uredi karticu';

  @override
  String get new_card_title => 'Nova kartica';

  @override
  String get front_label => 'Pitanje (front)';

  @override
  String get front_hint => 'Unesi pitanje...';

  @override
  String get back_label => 'Odgovor (back)';

  @override
  String get back_hint => 'Unesi odgovor...';

  @override
  String get save_changes_btn => 'Spremi izmjene';

  @override
  String get save_card_btn => 'Spremi karticu';

  @override
  String get name_label => 'Naziv';

  @override
  String get streak_motivation_0 => 'Počni danas i izgradi naviku!';

  @override
  String get streak_motivation_low => 'Dobar početak — nastavi!';

  @override
  String get streak_motivation_mid => 'Odlično! Svaki dan se isplati.';

  @override
  String get streak_motivation_high => 'Nevjerojatno! Ti si na pravom putu.';

  @override
  String streak_motivation_legend(int days) {
    return 'Legenda! $days dana bez prestanka!';
  }

  @override
  String get upgrade_ai_recap => 'Nadogradi za AI recap';

  @override
  String get view_pro_btn => 'Pogledaj Pro';

  @override
  String get pro_welcome => 'Dobrodošao u CardBlaze Pro! 🎉';

  @override
  String get topic_hint => 'npr. Fotosinteza, Rimsko pravo...';

  @override
  String get text_paste_hint => 'Zalijepite tekst ovdje...';

  @override
  String get upgrade_btn => 'Nadogradi na Pro';

  @override
  String get upgrade_dialog_subtitle =>
      'Otključaj sve značajke CardBlaze Pro plana.';

  @override
  String get benefit_unlimited_decks =>
      'Neograničen broj deckova (besplatno: 1)';

  @override
  String get benefit_cards_per_deck =>
      'Do 100 kartica po decku (besplatno: 15)';

  @override
  String get benefit_ai_generation => 'Neograničena AI generacija kartica';

  @override
  String get benefit_pdf_import => 'Uvoz PDF i DOCX dokumenata';

  @override
  String get benefit_advanced_stats => 'Napredne statistike učenja';

  @override
  String get version => 'Verzija';

  @override
  String get question_label => 'PITANJE';

  @override
  String get no_cards_today => 'Nema kartica za danas!';

  @override
  String get all_cards_current => 'Sve kartice su ažurne.';

  @override
  String get back_btn => 'Natrag';

  @override
  String get session_complete => 'Sesija završena!';

  @override
  String get session_correct => 'Točno';

  @override
  String get session_incorrect => 'Netočno';

  @override
  String get session_accuracy => 'Točnost';

  @override
  String get finish_btn => 'Završi';

  @override
  String get next_btn => 'Dalje';

  @override
  String get notifications_on => 'Uključeno';

  @override
  String get notifications_off => 'Dodirnite za uključivanje podsjetnika';

  @override
  String get deck_all_learned => 'Sve naučeno';

  @override
  String get answered_label => 'Odgovoreno:';

  @override
  String get pending_label => 'na čekanju';
}
