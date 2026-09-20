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
  String get deck_name_hint => 'Nom du paquet';

  @override
  String get select_color => 'Choisir une couleur';

  @override
  String get color_label => 'Couleur';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete_btn => 'Supprimer';

  @override
  String get study_now => 'Étudier maintenant';

  @override
  String get add_card => 'Ajouter une carte';

  @override
  String get front => 'Recto';

  @override
  String get back => 'Verso';

  @override
  String get my_decks => 'Vos paquets';

  @override
  String get due_today => 'À réviser aujourd\'hui';

  @override
  String get all_done_today => 'Tout terminé aujourd\'hui !';

  @override
  String get all_done_subtitle => 'Aucune carte en attente. Excellent !';

  @override
  String cards_waiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes à réviser',
      one: '1 carte à réviser',
    );
    return '$_temp0';
  }

  @override
  String get no_decks_title => 'Aucun paquet';

  @override
  String get no_decks_body =>
      'Ajoutez votre premier paquet et commencez à apprendre avec la répétition espacée.';

  @override
  String get add_first_deck => 'Ajouter le premier paquet';

  @override
  String get new_deck_label => 'Nouveau paquet';

  @override
  String get edit_deck => 'Modifier le paquet';

  @override
  String get delete_deck => 'Supprimer le paquet';

  @override
  String get delete_confirm_title => 'Supprimer le paquet ?';

  @override
  String delete_confirm_body(String name) {
    return 'Cela supprimera définitivement \"$name\" et toutes ses cartes.';
  }

  @override
  String deck_subtitle(int cards, int due) {
    return '$cards cartes · $due à réviser';
  }

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
  String cards_saved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes enregistrées !',
      one: '1 carte enregistrée !',
    );
    return '$_temp0';
  }

  @override
  String get error_enter_text => 'Saisir un texte ou un sujet.';

  @override
  String get error_select_deck => 'Choisir un paquet ou en créer un nouveau.';

  @override
  String get error_deck_name => 'Saisir un nom pour le nouveau paquet.';

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
  String get appearance_section => 'Apparence';

  @override
  String get theme_label => 'Thème';

  @override
  String get light_theme => 'Clair';

  @override
  String get dark_theme => 'Sombre';

  @override
  String get language_section => 'Langue';

  @override
  String get language_ui_label => 'Langue de l\'interface';

  @override
  String get other_section => 'Autre';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String get about => 'À propos';

  @override
  String get manage_subscription => 'Gérer l\'abonnement';

  @override
  String get restore_purchase => 'Restaurer les achats';

  @override
  String get restore_snack_success => 'Achat restauré avec succès !';

  @override
  String get restore_snack_none => 'Aucun abonnement actif à restaurer.';

  @override
  String get restore_snack_error => 'Erreur lors de la restauration.';

  @override
  String get current_plan => 'Votre plan';

  @override
  String get free_plan => 'Gratuit';

  @override
  String get pro_plan => 'Pro';

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
  String get nav_decks => 'Paquets';

  @override
  String get nav_generate => 'Générer';

  @override
  String get nav_stats => 'Stats';

  @override
  String get nav_settings => 'Paramètres';

  @override
  String get upgrade_btn => 'Passer à Pro';

  @override
  String get version => 'Version';
}
