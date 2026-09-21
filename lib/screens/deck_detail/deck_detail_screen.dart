import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/models/deck.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/services/premium_service.dart';
import 'package:cardblaze/theme/app_theme.dart';
import 'package:cardblaze/widgets/upgrade_dialog.dart';
import 'package:cardblaze/l10n/app_localizations.dart';

// ── DeckDetailScreen ──────────────────────────────────────────────────────────

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({super.key, required this.deckId});
  final String deckId;

  int get _id => int.parse(deckId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckStreamProvider(_id));
    final cardsAsync = ref.watch(cardsStreamProvider(_id));

    return deckAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (deck) {
        if (deck == null) {
          return Scaffold(body: Center(child: Text(AppLocalizations.of(context).deck_not_found)));
        }
        return _DeckScreen(deck: deck, cardsAsync: cardsAsync, deckId: _id);
      },
    );
  }
}

// ── Main screen scaffold ──────────────────────────────────────────────────────

class _DeckScreen extends ConsumerWidget {
  const _DeckScreen({
    required this.deck,
    required this.cardsAsync,
    required this.deckId,
  });

  final Deck deck;
  final AsyncValue<List<FlashCard>> cardsAsync;
  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = cardsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          deck.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppLocalizations.of(context).edit_deck_tooltip,
            onPressed: () => _showEditDeck(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppLocalizations.of(context).delete_deck_tooltip,
            onPressed: () => _confirmDeleteDeck(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Stats row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatsRow(deck: deck, cards: cards),
            ),
          ),

          // ── Action buttons ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _StudyNowButton(deckId: deckId, cards: cards),
            ),
          ),
          // ── Cards section header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                AppLocalizations.of(context).cards_section,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          // ── Cards list or empty state ─────────────────────────────────────
          cardsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
            data: (cards) => cards.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyCards())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _CardTile(
                        card: cards[i],
                        onDelete: () => _deleteCard(ref, cards[i]),
                      ),
                      childCount: cards.length,
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showEditDeck(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeckEditSheet(
        deck: deck,
        onSaved: () {
          ref.invalidate(deckStreamProvider(deckId));
          ref.invalidate(decksStreamProvider);
          ref.invalidate(allDecksProvider);
        },
      ),
    );
  }

  Future<void> _confirmDeleteDeck(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l.delete_confirm_title),
          content: Text(l.delete_confirm_body(deck.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete_btn, style: TextStyle(color: AppColors.badgeRed(ctx))),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      final isar = ref.read(isarServiceProvider);
      context.pop();
      await isar.deleteDeck(deckId);
      ref.invalidate(decksStreamProvider);
      ref.invalidate(allDecksProvider);
    }
  }

  void _showCardSheet(
    BuildContext context,
    WidgetRef ref, {
    required FlashCard? existingCard,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CardFormSheet(
        deckId: deckId,
        existingCard: existingCard,
        onSaved: () {
          ref.invalidate(cardsStreamProvider(deckId));
          ref.invalidate(deckStreamProvider(deckId));
          ref.invalidate(deckDueCountProvider(deckId));
          ref.invalidate(decksStreamProvider);
          ref.invalidate(allDecksProvider);
        },
      ),
    );
  }

  void _showEditCard(BuildContext context, WidgetRef ref, FlashCard card) {
    _showCardSheet(context, ref, existingCard: card);
  }

  Future<void> _deleteCard(WidgetRef ref, FlashCard card) async {
    await ref.read(isarServiceProvider).deleteCard(card.id);
    ref.invalidate(cardsStreamProvider(deckId));
    ref.invalidate(deckStreamProvider(deckId));
    ref.invalidate(deckDueCountProvider(deckId));
    ref.invalidate(decksStreamProvider);
    ref.invalidate(allDecksProvider);
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.deck, required this.cards});
  final Deck deck;
  final List<FlashCard> cards;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final dueCount = cards.where((c) => !c.dueDate.isAfter(now)).length;
    final learnedCount = cards.where((c) => c.repetitions >= 1 && c.dueDate.isAfter(now)).length;
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: l.stat_total,
            value: '${deck.cardCount}',
            icon: Icons.style_outlined,
            color: AppColors.accent(context),
            surface: surface,
            border: border,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: l.stat_pending,
            value: '$dueCount',
            icon: Icons.schedule_outlined,
            color: dueCount > 0
                ? AppColors.badgeOrange(context)
                : AppColors.badgeGreen(context),
            surface: surface,
            border: border,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: l.stat_learned,
            value: '$learnedCount',
            icon: Icons.check_circle_outline,
            color: AppColors.badgeGreen(context),
            surface: surface,
            border: border,
          ),
        ),
      ],
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.surface,
    required this.border,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Study Now button ──────────────────────────────────────────────────────────

class _StudyNowButton extends StatelessWidget {
  const _StudyNowButton({required this.deckId, required this.cards});
  final int deckId;
  final List<FlashCard> cards;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dueCount = cards.where((c) => !c.dueDate.isAfter(now)).length;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: cards.isEmpty ? null : () => context.push('/study/$deckId'),
        icon: const Icon(Icons.play_arrow),
        label: Text(
          dueCount > 0
              ? AppLocalizations.of(context).study_now_due(dueCount)
              : AppLocalizations.of(context).study_now,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onDelete,
  });
  final FlashCard card;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDue = !card.dueDate.isAfter(now);
    final isLearned = card.repetitions >= 1 && card.dueDate.isAfter(now);

    final isWrong = card.lastReviewed != null && card.repetitions == 0;

    final statusColor = isDue
        ? AppColors.badgeOrange(context)
        : isLearned
            ? AppColors.badgeGreen(context)
            : isWrong
                ? AppColors.badgeRed(context)
                : AppColors.textMuted(context);

    final statusIcon = isDue
        ? Icons.schedule_outlined
        : isLearned
            ? Icons.check_circle_outline
            : isWrong
                ? Icons.cancel
                : Icons.radio_button_unchecked;

    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textMuted = AppColors.textMuted(context);

    return Dismissible(
      key: ValueKey(card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.badgeRed(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(statusIcon, size: 20, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                card.front,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCards extends StatelessWidget {
  const _EmptyCards();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 60,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: 14),
          Text(
            l.no_cards_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l.no_cards_body_ai,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/generate'),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l.generate_title),
          ),
        ],
      ),
    );
  }
}

// ── Card form bottom sheet (add / edit) ───────────────────────────────────────

class _CardFormSheet extends ConsumerStatefulWidget {
  const _CardFormSheet({
    required this.deckId,
    required this.onSaved,
    this.existingCard,
  });

  final int deckId;
  final FlashCard? existingCard;
  final VoidCallback onSaved;

  @override
  ConsumerState<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends ConsumerState<_CardFormSheet> {
  late final TextEditingController _frontCtrl;
  late final TextEditingController _backCtrl;
  bool _saving = false;

  bool get _isEditing => widget.existingCard != null;

  @override
  void initState() {
    super.initState();
    _frontCtrl = TextEditingController(text: widget.existingCard?.front ?? '');
    _backCtrl = TextEditingController(text: widget.existingCard?.back ?? '');
  }

  @override
  void dispose() {
    _frontCtrl.dispose();
    _backCtrl.dispose();
    super.dispose();
  }

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
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            _isEditing
                ? AppLocalizations.of(context).edit_card_title
                : AppLocalizations.of(context).new_card_title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _frontCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).front_label,
              hintText: AppLocalizations.of(context).front_hint,
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _backCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).back_label,
              hintText: AppLocalizations.of(context).back_hint,
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _isEditing
                    ? AppLocalizations.of(context).save_changes_btn
                    : AppLocalizations.of(context).save_card_btn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final front = _frontCtrl.text.trim();
    final back = _backCtrl.text.trim();
    if (front.isEmpty || back.isEmpty) return;
    setState(() => _saving = true);

    final service = ref.read(isarServiceProvider);
    if (_isEditing) {
      widget.existingCard!
        ..front = front
        ..back = back;
      await service.saveCard(widget.existingCard!);
    } else {
      final now = DateTime.now();
      final card = FlashCard()
        ..deckId = widget.deckId
        ..front = front
        ..back = back
        ..createdAt = now
        ..dueDate = now;
      await service.saveCard(card);
    }

    if (mounted) {
      widget.onSaved();
      Navigator.pop(context);
    }
  }
}

// ── Deck edit bottom sheet ────────────────────────────────────────────────────

const _kDeckColors = [
  _DeckColor(hex: '4A9EFF', label: 'Plava'),
  _DeckColor(hex: '43A047', label: 'Zelena'),
  _DeckColor(hex: '7B4FA0', label: 'Ljubičasta'),
  _DeckColor(hex: 'F57C00', label: 'Narančasta'),
  _DeckColor(hex: '00ACC1', label: 'Tirkizna'),
  _DeckColor(hex: 'E91E63', label: 'Roza'),
];

class _DeckColor {
  const _DeckColor({required this.hex, required this.label});
  final String hex;
  final String label;
}

class _DeckEditSheet extends ConsumerStatefulWidget {
  const _DeckEditSheet({required this.deck, required this.onSaved});
  final Deck deck;
  final VoidCallback onSaved;

  @override
  ConsumerState<_DeckEditSheet> createState() => _DeckEditSheetState();
}

class _DeckEditSheetState extends ConsumerState<_DeckEditSheet> {
  late final TextEditingController _nameCtrl;
  late String _selectedHex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.deck.name);
    _selectedHex = widget.deck.colorHex;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

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
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(AppLocalizations.of(context).edit_deck, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).name_label,
              counterText: '',
            ),
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).color_label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kDeckColors.map((opt) {
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(AppLocalizations.of(context).save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    widget.deck
      ..name = name
      ..colorHex = _selectedHex;
    await ref.read(isarServiceProvider).saveDeck(widget.deck);
    if (mounted) {
      widget.onSaved();
      Navigator.pop(context);
    }
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
