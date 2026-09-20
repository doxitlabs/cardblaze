// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CardBlaze';

  @override
  String get home_title => 'Aujourd\'hui';

  @override
  String get today_card_title => 'Cartes du jour';

  @override
  String today_card_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
      zero: 'Tout terminé !',
    );
    return '$_temp0';
  }

  @override
  String get no_cards_due => 'Tout appris aujourd\'hui !';

  @override
  String get all_decks => 'Tous les paquets';

  @override
  String get add_deck => 'Ajouter un paquet';

  @override
  String get deck_name => 'Nom du paquet';

  @override
  String get select_color => 'Choisir une couleur';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get study_now => 'Étudier maintenant';

  @override
  String get add_card => 'Ajouter une carte';

  @override
  String get front => 'Recto';

  @override
  String get back => 'Verso';

  @override
  String get generate_title => 'Générer par IA';

  @override
  String get generate_subtitle =>
      'Générer des cartes à partir de texte, sujet ou PDF';

  @override
  String get text_mode => 'Texte';

  @override
  String get topic_mode => 'Sujet';

  @override
  String get pdf_mode => 'PDF';

  @override
  String get select_deck => 'Choisir un paquet';

  @override
  String get new_deck => 'Nouveau paquet';

  @override
  String get card_count => 'Nombre de cartes';

  @override
  String get generate_btn => 'Générer';

  @override
  String get stats_title => 'Statistiques';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return '$_temp0';
  }

  @override
  String get cards_this_week => 'Cartes cette semaine';

  @override
  String get accuracy => 'Précision';

  @override
  String get total_cards => 'Total des cartes';

  @override
  String get active_decks => 'Paquets actifs';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get general_tab => 'Général';

  @override
  String get subscription_tab => 'Abonnement';

  @override
  String get theme_label => 'Thème';

  @override
  String get light_theme => 'Clair';

  @override
  String get dark_theme => 'Sombre';

  @override
  String get language_label => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String get about => 'À propos';

  @override
  String get upgrade_title => 'Débloquer CardBlaze Pro';

  @override
  String get monthly_price => 'Mensuel';

  @override
  String get yearly_price => 'Annuel';

  @override
  String save_percent(int percent) {
    return 'Économisez $percent%';
  }

  @override
  String get restore_purchase => 'Restaurer les achats';

  @override
  String get current_plan => 'Plan actuel';

  @override
  String get free_plan => 'Gratuit';

  @override
  String get pro_plan => 'Pro';

  @override
  String get upgrade_btn => 'Passer à Pro';
}
