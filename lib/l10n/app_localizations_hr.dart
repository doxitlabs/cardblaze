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
  String get all_decks => 'Svi špilovi';

  @override
  String get add_deck => 'Dodaj špil';

  @override
  String get deck_name => 'Naziv špila';

  @override
  String get select_color => 'Odaberi boju';

  @override
  String get save => 'Spremi';

  @override
  String get cancel => 'Odustani';

  @override
  String get study_now => 'Uči sada';

  @override
  String get add_card => 'Dodaj karticu';

  @override
  String get front => 'Prednja strana';

  @override
  String get back => 'Stražnja strana';

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
  String get select_deck => 'Odaberi špil';

  @override
  String get new_deck => 'Novi špil';

  @override
  String get card_count => 'Broj kartica';

  @override
  String get generate_btn => 'Generiraj';

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
  String get active_decks => 'Aktivni špilovi';

  @override
  String get settings_title => 'Postavke';

  @override
  String get general_tab => 'Opće';

  @override
  String get subscription_tab => 'Pretplata';

  @override
  String get theme_label => 'Tema';

  @override
  String get light_theme => 'Svijetla';

  @override
  String get dark_theme => 'Tamna';

  @override
  String get language_label => 'Jezik';

  @override
  String get notifications => 'Obavijesti';

  @override
  String get privacy => 'Pravila privatnosti';

  @override
  String get about => 'O aplikaciji';

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
  String get restore_purchase => 'Obnovi kupnje';

  @override
  String get current_plan => 'Trenutni plan';

  @override
  String get free_plan => 'Besplatan';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_btn => 'Nadogradi na Pro';
}
