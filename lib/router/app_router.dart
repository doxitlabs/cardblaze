import 'package:go_router/go_router.dart';
import 'package:cardblaze/screens/home/home_screen.dart';
import 'package:cardblaze/screens/deck_detail/deck_detail_screen.dart';
import 'package:cardblaze/screens/study/study_screen.dart';
import 'package:cardblaze/screens/ai_generate/ai_generate_screen.dart';
import 'package:cardblaze/screens/stats/stats_screen.dart';
import 'package:cardblaze/screens/settings/settings_screen.dart';
import 'package:cardblaze/screens/privacy/privacy_policy_screen.dart';
import 'package:cardblaze/screens/splash/splash_screen.dart';
import 'package:cardblaze/widgets/scaffold_with_nav.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ── Shell: ekrani s bottom navom ────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/generate',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AiGenerateScreen()),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return NoTransitionPage(child: SettingsScreen(initialTab: tab));
          },
        ),
      ],
    ),

    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(
        onDone: () => context.go('/'),
      ),
    ),

    // ── Fullscreen rute (bez bottom nav) ────────────────────────────────────
    GoRoute(
      path: '/deck/:id',
      builder: (context, state) =>
          DeckDetailScreen(deckId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/study/:deckId',
      builder: (context, state) =>
          StudyScreen(deckId: state.pathParameters['deckId']!),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
