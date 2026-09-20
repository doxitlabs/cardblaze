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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartice čekaju',
      one: '1 kartica čeka',
    );
    return '$_temp0';
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
    return '$cards kartica · $due na čekanju';
  }

  @override
  String get generate_title => 'AI Generiranje';

  @override
  String get generate_subtitle => 'Generiraj kartice iz teksta, teme ili PDF-a';

  @override
  String get text_mode => 'Tekst';

  @override
  String get topic_mode => 'Tema';

  @override
  String get pdf_mode => 'PDF';

  @override
  String get select_deck => 'Odaberi deck';

  @override
  String get new_deck => 'Novi deck';

  @override
  String get card_count => 'Broj kartica';

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
  String get cards_this_week => 'Kartice ovaj tjedan';

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
  String get upgrade_btn => 'Nadogradi na Pro';

  @override
  String get version => 'Verzija';
}
