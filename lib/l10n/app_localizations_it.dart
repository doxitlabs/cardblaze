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
  String get select_color => 'Seleziona colore';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get study_now => 'Studia ora';

  @override
  String get add_card => 'Aggiungi carta';

  @override
  String get front => 'Fronte';

  @override
  String get back => 'Retro';

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
  String get theme_label => 'Tema';

  @override
  String get light_theme => 'Chiaro';

  @override
  String get dark_theme => 'Scuro';

  @override
  String get language_label => 'Lingua';

  @override
  String get notifications => 'Notifiche';

  @override
  String get privacy => 'Informativa sulla privacy';

  @override
  String get about => 'Informazioni';

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
  String get restore_purchase => 'Ripristina acquisti';

  @override
  String get current_plan => 'Piano attuale';

  @override
  String get free_plan => 'Gratuito';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_btn => 'Passa a Pro';
}
