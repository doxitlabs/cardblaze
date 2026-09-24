import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/providers/theme_provider.dart';
import 'package:cardblaze/providers/locale_provider.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/services/notification_service.dart';
import 'package:cardblaze/services/premium_service.dart';
import 'package:cardblaze/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(context);

    return Scaffold(
      appBar: AppBar(
        title: GradientTitle(AppLocalizations.of(context).settings_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: TabBar(
              controller: _tab,
              tabs: [
                Tab(text: AppLocalizations.of(context).general_tab),
                Tab(text: AppLocalizations.of(context).subscription_tab),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _GeneralTab(),
          _SubscriptionTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────── TAB 1: Općenito ─────────────────

class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _SectionHeader(l.appearance_section),
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: l.theme_label,
          trailing: _ThemeSegmentedButton(themeMode: themeMode, ref: ref),
        ),
        const SizedBox(height: 8),
        _SectionHeader(l.language_section),
        _SettingsTile(
          icon: Icons.language_outlined,
          title: l.language_ui_label,
          trailing: _LocaleDropdown(locale: locale, ref: ref),
        ),
        const SizedBox(height: 8),
        _SectionHeader(l.other_section),
        const _NotificationTile(),
        _TappableTile(
          icon: Icons.privacy_tip_outlined,
          title: l.privacy,
          onTap: () => context.push('/privacy'),
        ),
        const _AboutTile(),
      ],
    );
  }
}

// ─── Theme segmented button ───────────────────────────────────────────────────

class _ThemeSegmentedButton extends StatelessWidget {
  const _ThemeSegmentedButton({required this.themeMode, required this.ref});
  final ThemeMode themeMode;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      style: SegmentedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
        visualDensity: VisualDensity.compact,
      ),
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(AppLocalizations.of(context).light_theme),
          icon: const Icon(Icons.light_mode_outlined, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text(AppLocalizations.of(context).dark_theme),
          icon: const Icon(Icons.dark_mode_outlined, size: 16),
        ),
      ],
      selected: {themeMode == ThemeMode.system ? ThemeMode.dark : themeMode},
      onSelectionChanged: (set) {
        ref.read(themeModeProvider.notifier).setMode(set.first);
      },
    );
  }
}

// ─── Locale dropdown ──────────────────────────────────────────────────────────

const _kLocales = [
  (locale: Locale('hr'), label: '\u{1F1ED}\u{1F1F7} Hrvatski'),
  (locale: Locale('en'), label: '\u{1F1EC}\u{1F1E7} English'),
  (locale: Locale('de'), label: '\u{1F1E9}\u{1F1EA} Deutsch'),
  (locale: Locale('fr'), label: '\u{1F1EB}\u{1F1F7} Français'),
  (locale: Locale('it'), label: '\u{1F1EE}\u{1F1F9} Italiano'),
];

class _LocaleDropdown extends StatelessWidget {
  const _LocaleDropdown({required this.locale, required this.ref});
  final Locale locale;
  final WidgetRef ref;

  String get _currentLabel {
    for (final e in _kLocales) {
      if (e.locale.languageCode == locale.languageCode) return e.label;
    }
    return '\u{1F1EC}\u{1F1E7} English';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = AppColors.border(context);

    return PopupMenuButton<Locale>(
      onSelected: (l) => ref.read(localeProvider.notifier).setLocale(l),
      itemBuilder: (_) => _kLocales
          .map((e) => PopupMenuItem(
                value: e.locale,
                child: Text(e.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentLabel,
              style: const TextStyle(fontSize: 13, fontFamily: 'Roboto'),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 18, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}

// ─── Notification tile ───────────────────────────────────────────────────────

class _NotificationTile extends StatefulWidget {
  const _NotificationTile();

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _enabled = false;
  int _hour = 9;
  int _minute = 0;

  @override
  void initState() {
    super.initState();
    notificationService.isEnabled().then((v) {
      if (mounted) setState(() => _enabled = v);
    });
    notificationService.getTime().then((t) {
      if (mounted) setState(() { _hour = t.$1; _minute = t.$2; });
    });
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final granted = await notificationService.requestPermission();
      if (!granted) return;
    }
    await notificationService.setEnabled(value);
    if (mounted) setState(() => _enabled = value);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null) return;
    await notificationService.setTime(picked.hour, picked.minute);
    if (mounted) setState(() { _hour = picked.hour; _minute = picked.minute; });
  }

  String get _timeLabel {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const _IconBox(icon: Icons.notifications_outlined),
      title: Text(l.notifications),
      subtitle: Text(
        _enabled ? l.notifications_on : l.notifications_off,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_enabled)
            TextButton(
              onPressed: _pickTime,
              child: Text(_timeLabel),
            ),
          Switch(
            value: _enabled,
            onChanged: _toggle,
          ),
        ],
      ),
    );
  }
}

// ─── About tile ───────────────────────────────────────────────────────────────

class _AboutTile extends ConsumerStatefulWidget {
  const _AboutTile();

  @override
  ConsumerState<_AboutTile> createState() => _AboutTileState();
}

class _AboutTileState extends ConsumerState<_AboutTile> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const _IconBox(icon: Icons.info_outline),
      title: Text(l.about),
      subtitle: Text('CardBlaze $_version · DoxITLabs'),
    );
  }
}

// ──────────────────────────────────────────── TAB 2: Pretplata ───────────────

class _SubscriptionTab extends ConsumerWidget {
  const _SubscriptionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final offeringsAsync = ref.watch(offeringsProvider);
    final decksAsync = ref.watch(decksStreamProvider);

    final deckCount = decksAsync.valueOrNull?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        offeringsAsync.when(
          loading: () => const _PremiumCardSkeleton(),
          error: (_, __) => const _PremiumCardSkeleton(),
          data: (packages) => _PremiumCard(packages: packages),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => _restorePurchases(context, ref),
            child: Text(AppLocalizations.of(context).restore_purchase),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _SectionHeader(AppLocalizations.of(context).current_plan),
        isPremiumAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _PlanTile(isPremium: false, deckCount: deckCount),
          data: (isPremium) =>
              _PlanTile(isPremium: isPremium, deckCount: deckCount),
        ),
        _TappableTile(
          icon: Icons.open_in_new_outlined,
          title: AppLocalizations.of(context).manage_subscription,
          onTap: _openManageSubscription,
        ),
      ],
    );
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final svc = ref.read(premiumServiceProvider);
    final result = await svc.restorePurchases();
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    if (result != null) {
      final active = result.entitlements.active.containsKey(PremiumService.entitlementId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(active ? l.restore_snack_success : l.restore_snack_none),
        ),
      );
      ref.invalidate(isPremiumProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.restore_snack_error)),
      );
    }
  }

  Future<void> _openManageSubscription() async {
    const url =
        'https://play.google.com/store/account/subscriptions?package=com.doxitlabs.cardblaze';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── Premium card ─────────────────────────────────────────────────────────────

class _PremiumCard extends ConsumerWidget {
  const _PremiumCard({required this.packages});
  final List<Package> packages;

  List<String> _featureList(AppLocalizations l) => [
    l.benefit_unlimited_decks,
    l.benefit_cards_per_deck,
    l.benefit_ai_generation,
    l.benefit_pdf_import,
    l.benefit_pdf_export,
    l.benefit_advanced_stats,
  ];

  static const _purpleGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D1F6E), Color(0xFF6B4FA0), Color(0xFF9B59B6)],
  );

  Package? get _monthly => packages
      .where((p) =>
          p.packageType == PackageType.monthly ||
          p.storeProduct.identifier.startsWith(PremiumProductIds.monthly))
      .firstOrNull;

  Package? get _yearly => packages
      .where((p) =>
          p.packageType == PackageType.annual ||
          p.storeProduct.identifier.startsWith(PremiumProductIds.yearly))
      .firstOrNull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: _purpleGrad,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium,
                      color: Colors.amber, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'CardBlaze Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Features
            ..._featureList(AppLocalizations.of(context)).map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      f,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Price buttons
            Row(
              children: [
                Expanded(
                  child: _PriceButton(
                    label: _monthly != null
                        ? AppLocalizations.of(context).price_per_month(_monthly!.storeProduct.priceString)
                        : '—',
                    featured: false,
                    onTap: _monthly != null
                        ? () => _purchase(context, ref, _monthly!)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriceButton(
                    label: _yearly != null
                        ? AppLocalizations.of(context).price_per_year(_yearly!.storeProduct.priceString)
                        : '—',
                    featured: true,
                    onTap: _yearly != null
                        ? () => _purchase(context, ref, _yearly!)
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B4FA0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: _yearly != null
                    ? () => _purchase(context, ref, _yearly!)
                    : (_monthly != null
                        ? () => _purchase(context, ref, _monthly!)
                        : null),
                child: Text(AppLocalizations.of(context).upgrade_btn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(
      BuildContext context, WidgetRef ref, Package package) async {
    final svc = ref.read(premiumServiceProvider);
    final result = await svc.purchase(package);
    if (!context.mounted) return;
    if (result != null && result.entitlements.active.containsKey(PremiumService.entitlementId)) {
      ref.invalidate(isPremiumProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pro_welcome)),
      );
    }
  }
}

// ─── Price button ─────────────────────────────────────────────────────────────

class _PriceButton extends StatelessWidget {
  const _PriceButton({
    required this.label,
    required this.featured,
    required this.onTap,
  });
  final String label;
  final bool featured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: featured
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: featured
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: featured ? const Color(0xFF6B4FA0) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium card skeleton ────────────────────────────────────────────────────

class _PremiumCardSkeleton extends StatelessWidget {
  const _PremiumCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D1F6E), Color(0xFF6B4FA0), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ─── Plan tile ────────────────────────────────────────────────────────────────

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.isPremium, required this.deckCount});
  final bool isPremium;
  final int deckCount;

  @override
  Widget build(BuildContext context) {
    final purple = AppColors.purple(context);
    final purpleBg = AppColors.purpleBg(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPremium ? purpleBg : AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium
                ? purple.withValues(alpha: 0.4)
                : AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.workspace_premium : Icons.person_outline,
              color: isPremium ? purple : AppColors.textSecondary(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium
                        ? AppLocalizations.of(context).pro_plan
                        : AppLocalizations.of(context).free_plan,
                    style: TextStyle(
                      color:
                          isPremium ? purple : AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  if (!isPremium)
                    Text(
                      '$deckCount/${PremiumLimits.maxDecks}',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  if (isPremium)
                    Text(
                      AppLocalizations.of(context).pro_plan,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),
                ],
              ),
            ),
            if (isPremium)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context).pro_plan,
                  style: TextStyle(
                    color: purple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────── Shared widgets ──────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: cs.primary, size: 20),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(icon: icon),
      title: Text(title),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _TappableTile extends StatelessWidget {
  const _TappableTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(icon: icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      onTap: onTap,
    );
  }
}
