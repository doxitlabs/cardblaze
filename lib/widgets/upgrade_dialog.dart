import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/theme/app_theme.dart';
import 'package:cardblaze/l10n/app_localizations.dart';

// ─── checkPremium helper ──────────────────────────────────────────────────────
//
// Usage:
//   if (!await checkPremium(context, ref)) return;
//
// Returns true if user is premium (caller may proceed).
// Returns false and shows UpgradeDialog if user is free.

Future<bool> checkPremium(BuildContext context, WidgetRef ref) async {
  final isPremium = await ref.read(premiumStatusProvider.future);
  if (isPremium) return true;
  if (context.mounted) {
    await showUpgradeDialog(context);
  }
  return false;
}

Future<void> showUpgradeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => const UpgradeDialog(),
  );
}

// ─── UpgradeDialog ────────────────────────────────────────────────────────────

class UpgradeDialog extends StatelessWidget {
  const UpgradeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final purple = AppColors.purple(context);
    final purpleBg = AppColors.purpleBg(context);
    final cs = Theme.of(context).colorScheme;

    final benefits = [
      (icon: Icons.layers_outlined,         text: l.benefit_unlimited_decks),
      (icon: Icons.style_outlined,          text: l.benefit_cards_per_deck),
      (icon: Icons.auto_awesome_outlined,   text: l.benefit_ai_generation),
      (icon: Icons.picture_as_pdf_outlined, text: l.benefit_pdf_import),
      (icon: Icons.ios_share_outlined,      text: l.benefit_pdf_export),
      (icon: Icons.bar_chart_outlined,      text: l.benefit_advanced_stats),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: purpleBg, shape: BoxShape.circle),
              child: Icon(Icons.workspace_premium, color: purple, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              l.upgrade_btn,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l.upgrade_dialog_subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: purpleBg, borderRadius: BorderRadius.circular(8)),
                      child: Icon(b.icon, color: purple, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(b.text, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Roboto'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/settings?tab=1');
                },
                child: Text(l.upgrade_btn),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel, style: TextStyle(color: cs.outline)),
            ),
          ],
        ),
      ),
    );
  }
}
