import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _policy = <String, List<_Section>>{
    'en': _en,
    'hr': _hr,
    'de': _de,
    'fr': _fr,
    'it': _it,
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final sections = _policy[locale] ?? _policy['en']!;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: GradientTitle(l.privacy),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: l.open_in_browser,
            onPressed: () => launchUrl(
              Uri.parse('https://doxitlabs.github.io/cardblaze-privacy/'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final s = sections[i];
          if (s.heading) {
            return Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                s.text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              s.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _Section {
  const _Section(this.text, {this.heading = false});
  final String text;
  final bool heading;
}

// ── English ───────────────────────────────────────────────────────────────────

const _en = <_Section>[
  _Section('Privacy Policy', heading: true),
  _Section('Last updated: September 2026'),
  _Section('CardBlaze ("we", "our", "the app") is developed by DoxITLabs. This policy explains what data is collected, how it is used, and your rights.'),

  _Section('1. Data We Collect', heading: true),
  _Section('CardBlaze stores all your flashcard decks, cards, and study sessions locally on your device. We do not operate servers that store your personal data.'),

  _Section('2. AI Card Generation', heading: true),
  _Section('When you use the AI generation feature, the text or topic you enter is sent to Groq (groq.com) to generate flashcards. No personal identifying information is transmitted. Please review Groq\'s privacy policy at groq.com/privacy.'),

  _Section('3. Subscriptions', heading: true),
  _Section('Purchases and subscription management are handled by RevenueCat (revenuecat.com) and Google Play. These services may collect transaction data in accordance with their own privacy policies.'),

  _Section('4. Analytics', heading: true),
  _Section('CardBlaze does not collect analytics, crash reports, or usage statistics beyond what Google Play may collect automatically.'),

  _Section('5. Data Sharing', heading: true),
  _Section('We do not sell, trade, or share your personal data with third parties, except as described above (Groq for AI generation, RevenueCat/Google for payments).'),

  _Section('6. Data Deletion', heading: true),
  _Section('All your data is stored locally. You can delete all data by uninstalling the app. To cancel a subscription, use the Google Play subscription management page.'),

  _Section('7. Children\'s Privacy', heading: true),
  _Section('CardBlaze is not directed at children under 13. We do not knowingly collect data from children.'),

  _Section('8. Contact', heading: true),
  _Section('Questions about this policy? Contact us at: doxit.labs@gmail.com'),
];

// ── Hrvatski ──────────────────────────────────────────────────────────────────

const _hr = <_Section>[
  _Section('Politika privatnosti', heading: true),
  _Section('Zadnje ažuriranje: rujan 2026.'),
  _Section('CardBlaze ("mi", "aplikacija") razvija DoxITLabs. Ova politika objašnjava koje podatke prikupljamo, kako ih koristimo i koja su vaša prava.'),

  _Section('1. Podaci koje prikupljamo', heading: true),
  _Section('CardBlaze pohranjuje sve vaše kartice, deckove i sesije učenja lokalno na vašem uređaju. Ne vodimo servere koji pohranjuju vaše osobne podatke.'),

  _Section('2. AI generiranje kartica', heading: true),
  _Section('Kad koristite funkciju AI generiranja, tekst ili tema koje unesete šalju se usluzi Groq (groq.com) radi generiranja kartica. Ne prenose se osobni podaci. Pogledajte politiku privatnosti Groqa na groq.com/privacy.'),

  _Section('3. Pretplate', heading: true),
  _Section('Kupnjama i pretplatama upravljaju RevenueCat (revenuecat.com) i Google Play. Te usluge mogu prikupljati podatke o transakcijama sukladno svojim politikama privatnosti.'),

  _Section('4. Analitika', heading: true),
  _Section('CardBlaze ne prikuplja analitiku, izvješća o greškama niti statistike korištenja osim onih koje automatski prikuplja Google Play.'),

  _Section('5. Dijeljenje podataka', heading: true),
  _Section('Ne prodajemo, ne trgujemo niti dijelimo vaše osobne podatke s trećim stranama, osim kako je opisano gore (Groq za AI, RevenueCat/Google za plaćanja).'),

  _Section('6. Brisanje podataka', heading: true),
  _Section('Svi vaši podaci pohranjeni su lokalno. Možete ih izbrisati deinstalacijom aplikacije. Za otkazivanje pretplate koristite Google Play upravljanje pretplatama.'),

  _Section('7. Privatnost djece', heading: true),
  _Section('CardBlaze nije namijenjen djeci mlađoj od 13 godina. Ne prikupljamo namjerno podatke od djece.'),

  _Section('8. Kontakt', heading: true),
  _Section('Pitanja o ovoj politici? Kontaktirajte nas na: doxit.labs@gmail.com'),
];

// ── Deutsch ───────────────────────────────────────────────────────────────────

const _de = <_Section>[
  _Section('Datenschutzrichtlinie', heading: true),
  _Section('Letzte Aktualisierung: September 2026'),
  _Section('CardBlaze („wir", „App") wird von DoxITLabs entwickelt. Diese Richtlinie erläutert, welche Daten erhoben werden, wie sie verwendet werden und welche Rechte Sie haben.'),

  _Section('1. Erhobene Daten', heading: true),
  _Section('CardBlaze speichert alle Ihre Karteikarten, Decks und Lernsitzungen lokal auf Ihrem Gerät. Wir betreiben keine Server, die Ihre persönlichen Daten speichern.'),

  _Section('2. KI-Kartengenerierung', heading: true),
  _Section('Wenn Sie die KI-Generierungsfunktion nutzen, wird der eingegebene Text oder das Thema an Groq (groq.com) gesendet. Es werden keine personenbezogenen Daten übertragen. Bitte lesen Sie die Datenschutzrichtlinie von Groq unter groq.com/privacy.'),

  _Section('3. Abonnements', heading: true),
  _Section('Käufe und Abonnements werden von RevenueCat (revenuecat.com) und Google Play verwaltet. Diese Dienste können Transaktionsdaten gemäß ihren eigenen Datenschutzrichtlinien erheben.'),

  _Section('4. Analytik', heading: true),
  _Section('CardBlaze erhebt keine Analysedaten, Absturzberichte oder Nutzungsstatistiken über das hinaus, was Google Play automatisch erfasst.'),

  _Section('5. Datenweitergabe', heading: true),
  _Section('Wir verkaufen, handeln oder teilen Ihre persönlichen Daten nicht mit Dritten, außer wie oben beschrieben (Groq für KI, RevenueCat/Google für Zahlungen).'),

  _Section('6. Datenlöschung', heading: true),
  _Section('Alle Ihre Daten werden lokal gespeichert. Sie können alle Daten löschen, indem Sie die App deinstallieren. Zum Kündigen eines Abonnements nutzen Sie die Google Play Abonnementverwaltung.'),

  _Section('7. Datenschutz für Kinder', heading: true),
  _Section('CardBlaze richtet sich nicht an Kinder unter 13 Jahren. Wir erheben wissentlich keine Daten von Kindern.'),

  _Section('8. Kontakt', heading: true),
  _Section('Fragen zu dieser Richtlinie? Kontaktieren Sie uns: doxit.labs@gmail.com'),
];

// ── Français ──────────────────────────────────────────────────────────────────

const _fr = <_Section>[
  _Section('Politique de confidentialité', heading: true),
  _Section('Dernière mise à jour : septembre 2026'),
  _Section('CardBlaze (« nous », « l\'application ») est développé par DoxITLabs. Cette politique explique quelles données sont collectées, comment elles sont utilisées et quels sont vos droits.'),

  _Section('1. Données collectées', heading: true),
  _Section('CardBlaze stocke tous vos paquets, cartes et sessions d\'étude localement sur votre appareil. Nous n\'exploitons pas de serveurs stockant vos données personnelles.'),

  _Section('2. Génération de cartes par IA', heading: true),
  _Section('Lorsque vous utilisez la fonction de génération par IA, le texte ou le sujet saisi est envoyé à Groq (groq.com) pour générer des cartes. Aucune information personnelle n\'est transmise. Veuillez consulter la politique de confidentialité de Groq sur groq.com/privacy.'),

  _Section('3. Abonnements', heading: true),
  _Section('Les achats et abonnements sont gérés par RevenueCat (revenuecat.com) et Google Play. Ces services peuvent collecter des données de transaction conformément à leurs propres politiques.'),

  _Section('4. Analytique', heading: true),
  _Section('CardBlaze ne collecte pas d\'analyses, de rapports d\'erreurs ni de statistiques d\'utilisation au-delà de ce que Google Play collecte automatiquement.'),

  _Section('5. Partage des données', heading: true),
  _Section('Nous ne vendons, n\'échangeons ni ne partageons vos données personnelles avec des tiers, sauf comme décrit ci-dessus (Groq pour l\'IA, RevenueCat/Google pour les paiements).'),

  _Section('6. Suppression des données', heading: true),
  _Section('Toutes vos données sont stockées localement. Vous pouvez les supprimer en désinstallant l\'application. Pour résilier un abonnement, utilisez la gestion des abonnements Google Play.'),

  _Section('7. Confidentialité des enfants', heading: true),
  _Section('CardBlaze ne s\'adresse pas aux enfants de moins de 13 ans. Nous ne collectons pas sciemment de données auprès d\'enfants.'),

  _Section('8. Contact', heading: true),
  _Section('Questions sur cette politique ? Contactez-nous : doxit.labs@gmail.com'),
];

// ── Italiano ──────────────────────────────────────────────────────────────────

const _it = <_Section>[
  _Section('Informativa sulla privacy', heading: true),
  _Section('Ultimo aggiornamento: settembre 2026'),
  _Section('CardBlaze ("noi", "l\'app") è sviluppato da DoxITLabs. Questa informativa spiega quali dati vengono raccolti, come vengono utilizzati e quali sono i vostri diritti.'),

  _Section('1. Dati raccolti', heading: true),
  _Section('CardBlaze conserva tutti i vostri mazzi, le carte e le sessioni di studio localmente sul vostro dispositivo. Non gestiamo server che memorizzano i vostri dati personali.'),

  _Section('2. Generazione carte con IA', heading: true),
  _Section('Quando si utilizza la funzione di generazione con IA, il testo o l\'argomento inserito viene inviato a Groq (groq.com) per generare le carte. Non vengono trasmesse informazioni personali. Si prega di consultare l\'informativa sulla privacy di Groq su groq.com/privacy.'),

  _Section('3. Abbonamenti', heading: true),
  _Section('Acquisti e abbonamenti sono gestiti da RevenueCat (revenuecat.com) e Google Play. Questi servizi possono raccogliere dati sulle transazioni in conformità con le proprie informative.'),

  _Section('4. Analitiche', heading: true),
  _Section('CardBlaze non raccoglie analitiche, report di errori o statistiche di utilizzo oltre a quanto raccolto automaticamente da Google Play.'),

  _Section('5. Condivisione dei dati', heading: true),
  _Section('Non vendiamo, scambiamo né condividiamo i vostri dati personali con terze parti, salvo quanto descritto sopra (Groq per l\'IA, RevenueCat/Google per i pagamenti).'),

  _Section('6. Cancellazione dei dati', heading: true),
  _Section('Tutti i vostri dati sono conservati localmente. È possibile eliminarli disinstallando l\'app. Per annullare un abbonamento, utilizzare la gestione abbonamenti di Google Play.'),

  _Section('7. Privacy dei minori', heading: true),
  _Section('CardBlaze non è destinato a bambini di età inferiore ai 13 anni. Non raccogliamo consapevolmente dati da minori.'),

  _Section('8. Contatti', heading: true),
  _Section('Domande su questa informativa? Contattateci: doxit.labs@gmail.com'),
];
