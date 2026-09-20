import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/providers/theme_provider.dart';
import 'package:cardblaze/providers/locale_provider.dart';
import 'package:cardblaze/router/app_router.dart';
import 'package:cardblaze/theme/app_theme.dart';

class CardBlazeApp extends ConsumerWidget {
  const CardBlazeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CardBlaze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
