import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tvoji deckovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novi deck',
            onPressed: () => _onAddTap(context, ref, decksAsync.valueOrNull),
          ),
        ],
      ),
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Greška: $e')),
        data: (decks) => decks.isEmpty
            ? _EmptyState(onAddTap: () => _onAddTap(context, ref, decks))
            : _HomeBody(decks: decks),
      ),
    );
  }

  Future<void> _onAddTap(
    BuildContext context,
    WidgetRef ref,
    List<Deck>? currentDecks,
  ) async {
    final isPremium = await ref.read(premiumStatusProvider.future);
    if (!context.mounted) return;
    if (!isPremium && (currentDecks?.length ?? 0) >= PremiumLimits.maxDecks) {
      await showUpgradeDialog(context);
      return;
    }
    if (context.mounted) _showCreateSheet(context, ref);
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeckFormSheet(
        onSaved: () => ref.invalidate(decksStreamProvider),
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _DueTodayCard(decks: decks),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Svi deckovi',
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

// ── "Na redu danas" card ──────────────────────────────────────────────────────

class _DueTodayCard extends ConsumerWidget {
  const _DueTodayCard({required this.decks});
  final List<Deck> decks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(totalDueCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final bgColor = isDark
        ? const Color(0xFF1A2A40)
        : const Color(0xFFE3F0FF);

    return dueAsync.when(
      loading: () => _cardShell(
        context,
        bgColor: bgColor,
        accent: accent,
        onTap: null,
        child: const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (due) {
        final allDone = due == 0;
        final cardBg = allDone
            ? (isDark ? const Color(0xFF1A3028) : const Color(0xFFE8F5E9))
            : bgColor;
        final iconColor = allDone ? AppColors.badgeGreen(context) : accent;

        return _cardShell(
          context,
          bgColor: cardBg,
          accent: iconColor,
          onTap: allDone ? null : () => context.push('/study/all'),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  allDone ? Icons.check_circle_outline : Icons.schedule_outlined,
                  color: iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone ? 'Sve naučeno za danas!' : 'Na redu danas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allDone
                          ? 'Nema kartica na čekanju. Odlično!'
                          : '$due ${_cardWord(due)} čeka na ponavljanje',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (!allDone) ...[
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: accent),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _cardShell(
    BuildContext context, {
    required Color bgColor,
    required Color accent,
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: child,
      ),
    );
  }

  String _cardWord(int n) {
    if (n == 1) return 'kartica';
    if (n >= 2 && n <= 4) return 'kartice';
    return 'kartica';
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
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textMuted = AppColors.textMuted(context);

    final dueCount = dueAsync.valueOrNull ?? 0;

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
                    '${deck.cardCount} kartica · $dueCount na čekanju',
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
              'Nema deckova',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodaj prvi deck i počni učiti\ns pametnim ponavljanjem.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj prvi deck'),
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
            _isEditing ? 'Uredi deck' : 'Novi deck',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Naziv decka',
              counterText: '',
            ),
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          Text(
            'Boja',
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
              child: Text(_isEditing ? 'Spremi' : 'Spremi'),
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
    if (isNew) deck.createdAt = DateTime.now();

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
    required this.onEdited,
    required this.onDeleted,
  });

  final Deck deck;
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
            title: const Text('Uredi deck'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: context,
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
              'Obriši deck',
              style: TextStyle(color: AppColors.badgeRed(context)),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ref);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši deck?'),
        content: Text(
          'Ovo će trajno obrisati "${deck.name}" i sve njegove kartice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Obriši',
              style: TextStyle(color: AppColors.badgeRed(context)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(isarServiceProvider).deleteDeck(deck.id);
      onDeleted();
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
