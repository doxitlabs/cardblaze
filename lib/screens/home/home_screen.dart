import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/models/deck.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/services/premium_service.dart';
import 'package:cardblaze/theme/app_theme.dart';
import 'package:cardblaze/widgets/upgrade_dialog.dart';

// ── M-04 deck color palette (6 options) ──────────────────────────────────────

const _kColorOptions = [
  _ColorOption(hex: '4A9EFF', label: 'Plava'),
  _ColorOption(hex: '43A047', label: 'Zelena'),
  _ColorOption(hex: '7B4FA0', label: 'Ljubičasta'),
  _ColorOption(hex: 'F57C00', label: 'Narančasta'),
  _ColorOption(hex: '00ACC1', label: 'Tirkizna'),
  _ColorOption(hex: 'E91E63', label: 'Roza'),
];

class _ColorOption {
  const _ColorOption({required this.hex, required this.label});
  final String hex;
  final String label;
}

// ── HomeScreen ────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(cardsRefreshProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksStreamProvider);

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CardBlaze'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddTap(context, decksAsync.valueOrNull),
        icon: const Icon(Icons.add),
        label: Text(l.new_deck_label),
      ),
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allDecks) {
          final locale = Localizations.localeOf(context).languageCode;
          final decks = allDecks
              .where((d) => d.language == null || d.language == locale)
              .toList();
          return decks.isEmpty
              ? _EmptyState(onAddTap: () => _onAddTap(context, decks))
              : _HomeBody(decks: decks);
        },
      ),
    );
  }

  Future<void> _onAddTap(BuildContext context, List<Deck>? currentDecks) async {
    final isPremium = await ref.read(premiumStatusProvider.future);
    if (!context.mounted) return;
    if (!isPremium && (currentDecks?.length ?? 0) >= PremiumLimits.maxDecks) {
      await showUpgradeDialog(context);
      return;
    }
    if (context.mounted) _showCreateSheet(context);
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeckFormSheet(
        onSaved: () {
          ref.invalidate(decksStreamProvider);
          ref.invalidate(allDecksProvider);
        },
      ),
    );
  }
}

// ── Home body (due card + deck list) ─────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.decks});
  final List<Deck> decks;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PendingCard()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              AppLocalizations.of(context).all_decks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _DeckListTile(deck: decks[i]),
            childCount: decks.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Pending cards summary card ────────────────────────────────────────────────

class _PendingCard extends ConsumerWidget {
  const _PendingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(totalLearnedPendingProvider);
    final stats = statsAsync.valueOrNull;
    final learned = stats?.learned ?? 0;
    final pending = stats?.pending ?? 0;
    final total = learned + pending;
    if (total == 0) return const SizedBox.shrink();

    final accent = AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A2A40) : const Color(0xFFE3F0FF);
    const learnedColor = Color(0xFF4A9EFF);
    const pendingColor = Color(0xFFE53935);
    final learnedFraction = total > 0 ? learned / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_fire_department_rounded, color: accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '${AppLocalizations.of(context).answered_label} ',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '$learned',
                          style: TextStyle(
                            color: learnedColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '  ·  $pending ${AppLocalizations.of(context).pending_label}',
                          style: TextStyle(
                            color: pendingColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(height: 6, color: pendingColor.withValues(alpha: 0.3)),
                        FractionallySizedBox(
                          widthFactor: learnedFraction,
                          child: Container(height: 6, color: learnedColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Deck list tile ────────────────────────────────────────────────────────────

class _DeckListTile extends ConsumerWidget {
  const _DeckListTile({required this.deck});
  final Deck deck;

  Color get _color {
    final hex = deck.colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(deckDueCountProvider(deck.id));
    final wrongAsync = ref.watch(deckWrongCountProvider(deck.id));
    final hasSessionAsync = ref.watch(deckHasSessionProvider(deck.id));
    final totalAsync = ref.watch(deckTotalCountProvider(deck.id));
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textMuted = AppColors.textMuted(context);

    final dueCount = dueAsync.valueOrNull ?? 0;
    final wrongCount = wrongAsync.valueOrNull ?? 0;
    final hasSession = hasSessionAsync.valueOrNull ?? false;
    final totalCount = totalAsync.valueOrNull ?? 0;
    // naučeno = total - wrongCount (only meaningful after first session)
    final learnedCount = hasSession ? (totalCount - wrongCount).clamp(0, totalCount) : 0;
    final pendingCount = hasSession ? wrongCount : totalCount;

    return GestureDetector(
      onTap: () => context.push('/deck/${deck.id}'),
      onLongPress: () => _showOptions(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (!hasSession)
                        ? AppLocalizations.of(context).deck_subtitle(0, totalCount)
                        : (wrongCount == 0)
                            ? AppLocalizations.of(context).deck_all_learned
                            : AppLocalizations.of(context).deck_subtitle(learnedCount, pendingCount),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Due badge
            _DueBadge(due: dueCount),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeckOptionsSheet(
        deck: deck,
        outerContext: context,
        onEdited: () {
          ref.invalidate(decksStreamProvider);
          ref.invalidate(deckByIdProvider(deck.id));
          ref.invalidate(allDecksProvider);
        },
        onDeleted: () {
          ref.invalidate(decksStreamProvider);
          ref.invalidate(allDecksProvider);
        },
      ),
    );
  }
}

// ── Due badge ─────────────────────────────────────────────────────────────────

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.due});
  final int due;

  @override
  Widget build(BuildContext context) {
    final isDue = due > 0;
    final bg = isDue ? AppColors.badgeRed(context) : AppColors.badgeGreen(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$due',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: bg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTap});
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 80,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).no_decks_title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).no_decks_body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).add_first_deck),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Deck form bottom sheet (create) ──────────────────────────────────────────

class _DeckFormSheet extends ConsumerStatefulWidget {
  const _DeckFormSheet({
    this.existingDeck,
    required this.onSaved,
  });

  final Deck? existingDeck;
  final VoidCallback onSaved;

  @override
  ConsumerState<_DeckFormSheet> createState() => _DeckFormSheetState();
}

class _DeckFormSheetState extends ConsumerState<_DeckFormSheet> {
  late final TextEditingController _nameController;
  late String _selectedHex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingDeck?.name ?? '',
    );
    _selectedHex = widget.existingDeck?.colorHex ?? _kColorOptions.first.hex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingDeck != null;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            _isEditing
                ? AppLocalizations.of(context).edit_deck
                : AppLocalizations.of(context).new_deck_label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).deck_name_hint,
              counterText: '',
            ),
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).color_label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kColorOptions.map((opt) {
              final color = _hexToColor(opt.hex);
              final selected = opt.hex == _selectedHex;
              return GestureDetector(
                onTap: () => setState(() => _selectedHex = opt.hex),
                child: Tooltip(
                  message: opt.label,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(AppLocalizations.of(context).save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final service = ref.read(isarServiceProvider);
    final isNew = widget.existingDeck == null;
    final deck = widget.existingDeck ?? Deck();
    deck
      ..name = name
      ..colorHex = _selectedHex;
    if (isNew) {
      deck.createdAt = DateTime.now();
      deck.language = Localizations.localeOf(context).languageCode;
    }

    await service.saveDeck(deck);
    if (mounted) {
      widget.onSaved();
      Navigator.pop(context);
    }
  }
}

// ── Deck options sheet (edit / delete) ────────────────────────────────────────

class _DeckOptionsSheet extends ConsumerWidget {
  const _DeckOptionsSheet({
    required this.deck,
    required this.outerContext,
    required this.onEdited,
    required this.onDeleted,
  });

  final Deck deck;
  final BuildContext outerContext;
  final VoidCallback onEdited;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(AppLocalizations.of(context).edit_deck),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: outerContext,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _DeckFormSheet(
                  existingDeck: deck,
                  onSaved: onEdited,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.badgeRed(context)),
            title: Text(
              AppLocalizations.of(context).delete_deck,
              style: TextStyle(color: AppColors.badgeRed(context)),
            ),
            onTap: () async {
              // Show confirm dialog ON TOP of the open sheet (context is valid here)
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(AppLocalizations.of(ctx).delete_confirm_title),
                  content: Text(AppLocalizations.of(ctx).delete_confirm_body(deck.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppLocalizations.of(ctx).cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        AppLocalizations.of(ctx).delete_btn,
                        style: TextStyle(color: AppColors.badgeRed(ctx)),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                if (context.mounted) Navigator.pop(context);
                await ref.read(isarServiceProvider).deleteDeck(deck.id);
                onDeleted();
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
