import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/models/study_session.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/services/sm2_service.dart';
import 'package:cardblaze/services/widget_service.dart';
import 'package:cardblaze/theme/app_theme.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key, required this.deckId});
  final String deckId;

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  List<FlashCard> _cards = [];
  int _index = 0;
  bool _showBack = false;
  bool _loading = true;

  int _correctCount = 0;   // rating >= 1
  int _incorrectCount = 0; // rating == 0

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _flipAnim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final id = int.tryParse(widget.deckId) ?? 0;
    var due = await ref.read(isarServiceProvider).getDueCards(id);
    due.shuffle(Random());
    setState(() {
      _cards = due;
      _loading = false;
    });
  }

  Future<void> _rate(int rating) async {
    if (_index >= _cards.length) return;

    final card = sm2Service.applyRating(_cards[_index], rating);
    await ref.read(isarServiceProvider).saveCard(card);

    if (rating == 0) {
      _incorrectCount++;
    } else {
      _correctCount++;
    }

    if (_index + 1 >= _cards.length) {
      await _finishSession();
      if (mounted) _showResults();
      return;
    }

    setState(() {
      _index++;
      _showBack = false;
    });
    _flipCtrl.reset();
  }

  Future<void> _finishSession() async {
    final id = int.tryParse(widget.deckId) ?? 0;
    final session = StudySession()
      ..deckId = id
      ..date = DateTime.now()
      ..cardsStudied = _cards.length
      ..correctCount = _correctCount
      ..incorrectCount = _incorrectCount;
    await ref.read(isarServiceProvider).saveSession(session);
    ref.invalidate(cardsRefreshProvider);
    await ref.read(widgetServiceProvider).updateWidget();
  }

  void _showResults() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        total: _cards.length,
        correct: _correctCount,
        incorrect: _incorrectCount,
        onDone: () => context.pop(),
      ),
    );
  }

  void _reveal() {
    if (_showBack) return;
    setState(() => _showBack = true);
    _flipCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final deckId = int.tryParse(widget.deckId) ?? 0;
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final deckName = deckAsync.valueOrNull?.name ?? '';

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.pageBg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.pageBg(context),
        appBar: AppBar(
          title: Text(deckName),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                'Nema kartica za danas!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sve kartice su up-to-date.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Natrag'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _cards[_index];
    final progress = (_index) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.pageBg(context),
      appBar: AppBar(
        title: Text(deckName),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Progress counter
              Text(
                '${_index + 1} od ${_cards.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 20),
              // Flashcard with flip
              Expanded(
                child: GestureDetector(
                  onTap: _reveal,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (_, __) {
                      final angle = _flipAnim.value;
                      // past 90° → show back face
                      final showingBack = angle > pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: showingBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _CardFace(
                                  text: card.back,
                                  label: 'ODGOVOR',
                                  labelColor: AppColors.accent(context),
                                ),
                              )
                            : _CardFace(
                                text: card.front,
                                label: 'PITANJE',
                                labelColor: AppColors.textMuted(context),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Reveal button (hidden when back is shown)
              AnimatedOpacity(
                opacity: _showBack ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: _showBack,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _reveal,
                      child: const Text('Otkrij odgovor'),
                    ),
                  ),
                ),
              ),
              // Rating buttons (visible only when back shown)
              AnimatedOpacity(
                opacity: _showBack ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showBack,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        _RatingButton(
                          label: 'Teško',
                          emoji: '😓',
                          color: AppColors.badgeRed(context),
                          onTap: () => _rate(0),
                        ),
                        const SizedBox(width: 12),
                        _RatingButton(
                          label: 'Ok',
                          emoji: '😐',
                          color: AppColors.badgeOrange(context),
                          onTap: () => _rate(1),
                        ),
                        const SizedBox(width: 12),
                        _RatingButton(
                          label: 'Lako',
                          emoji: '😊',
                          color: AppColors.badgeGreen(context),
                          onTap: () => _rate(2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card face ─────────────────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.text,
    required this.label,
    required this.labelColor,
  });

  final String text;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating button ─────────────────────────────────────────────────────────────

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result dialog ─────────────────────────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.onDone,
  });

  final int total;
  final int correct;
  final int incorrect;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct / total * 100).round();
    return AlertDialog(
      title: const Text('Sesija završena! 🎉'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$pct%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.accent(context),
                ),
          ),
          const SizedBox(height: 16),
          _StatRow(label: 'Ukupno kartica', value: '$total'),
          _StatRow(
            label: 'Točno',
            value: '$correct',
            color: AppColors.badgeGreen(context),
          ),
          _StatRow(
            label: 'Teško',
            value: '$incorrect',
            color: AppColors.badgeRed(context),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onDone,
          child: const Text('Završi'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color ?? AppColors.textPrimary(context),
                ),
          ),
        ],
      ),
    );
  }
}
