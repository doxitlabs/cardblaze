import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/models/study_session.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/services/groq_service.dart';
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

class _StudyScreenState extends ConsumerState<StudyScreen> {
  List<FlashCard> _dueCards = [];
  List<FlashCard> _allCards = [];
  int _index = 0;
  bool _loading = true;

  List<String> _options = [];
  String? _selectedOption;
  Map<int, List<String>> _distractors = {};

  int _correctCount = 0;
  int _incorrectCount = 0;

  final _groq = GroqService();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final id = int.tryParse(widget.deckId) ?? 0;
    final isar = ref.read(isarServiceProvider);
    var all = await isar.getCardsForDeck(id);
    all.shuffle(Random());
    setState(() {
      _dueCards = all;
      _allCards = all;
      _loading = false;
    });
    if (all.isNotEmpty) {
      _buildOptions();
      // Generate AI distractors in background
      final lang = _locale();
      _groq.generateDistractors(all, lang).then((distractors) {
        if (!mounted) return;
        setState(() => _distractors = distractors);
        // Rebuild options for current card if not yet answered
        if (_selectedOption == null) _buildOptions();
      });
    }
  }

  String _locale() {
    try {
      return Localizations.localeOf(context).languageCode;
    } catch (_) {
      return 'en';
    }
  }

  void _buildOptions() {
    if (_index >= _dueCards.length) return;
    final card = _dueCards[_index];
    final correct = card.back;

    // Prefer AI distractors; fall back to other cards' backs
    List<String> distractors = _distractors[_index] ?? [];
    if (distractors.isEmpty) {
      final others = _allCards
          .where((c) => c.id != card.id && c.back.trim() != correct.trim())
          .map((c) => c.back)
          .toList()
        ..shuffle(Random());
      distractors = others.take(2).toList();
    }

    final opts = [correct, ...distractors.take(2)]..shuffle(Random());

    setState(() {
      _options = opts;
      _selectedOption = null;
    });
  }

  Future<void> _onOptionTap(String option) async {
    if (_selectedOption != null) return;

    final card = _dueCards[_index];
    final correct = option == card.back;

    setState(() {
      _selectedOption = option;
    });

    if (correct) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }

    final rated = sm2Service.applyRating(card, correct ? 2 : 0);
    await ref.read(isarServiceProvider).saveCard(rated);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_index + 1 >= _dueCards.length) {
      await _finishSession();
      if (mounted) _showResults();
      return;
    }

    setState(() => _index++);
    _buildOptions();
  }

  Future<void> _finishSession() async {
    final id = int.tryParse(widget.deckId) ?? 0;
    final session = StudySession()
      ..deckId = id
      ..date = DateTime.now()
      ..cardsStudied = _dueCards.length
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
      builder: (ctx) => _ResultDialog(
        total: _dueCards.length,
        correct: _correctCount,
        incorrect: _incorrectCount,
        onDone: () => context.pop(),
        l: AppLocalizations.of(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final deckId = int.tryParse(widget.deckId) ?? 0;
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final deckName = deckAsync.valueOrNull?.name ?? '';

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.pageBg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_dueCards.isEmpty) {
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
              Text(l.no_cards_today, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l.all_cards_current, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l.back_btn),
              ),
            ],
          ),
        ),
      );
    }

    final card = _dueCards[_index];
    final progress = _index / _dueCards.length;

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
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                '${_index + 1} / ${_dueCards.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 20),
              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  children: [
                    Text(
                      l.question_label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      card.front,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Answer options
              Expanded(
                child: ListView(
                  children: _options
                      .map((opt) => _OptionTile(
                            text: opt,
                            correctAnswer: card.back,
                            selectedOption: _selectedOption,
                            onTap: () => _onOptionTap(opt),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Answer option tile ────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.correctAnswer,
    required this.selectedOption,
    required this.onTap,
  });

  final String text;
  final String correctAnswer;
  final String? selectedOption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answered = selectedOption != null;
    final isCorrect = text == correctAnswer;
    final isSelected = selectedOption == text;
    final isWrong = isSelected && !isCorrect;

    Color bgColor;
    Color borderColor;
    Widget? trailing;

    if (answered) {
      if (isCorrect) {
        bgColor = AppColors.badgeGreen(context).withValues(alpha: isSelected ? 0.18 : 0.08);
        borderColor = AppColors.badgeGreen(context).withValues(alpha: isSelected ? 1.0 : 0.5);
        trailing = Icon(Icons.check_circle, color: AppColors.badgeGreen(context), size: 20);
      } else if (isWrong) {
        bgColor = AppColors.badgeRed(context).withValues(alpha: 0.15);
        borderColor = AppColors.badgeRed(context);
        trailing = Icon(Icons.cancel, color: AppColors.badgeRed(context), size: 20);
      } else {
        bgColor = AppColors.surface(context);
        borderColor = AppColors.border(context).withValues(alpha: 0.4);
        trailing = null;
      }
    } else {
      bgColor = AppColors.surface(context);
      borderColor = AppColors.border(context);
      trailing = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: answered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: answered && !isCorrect && !isWrong
                            ? AppColors.textMuted(context)
                            : null,
                      ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
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
    required this.l,
  });

  final int total;
  final int correct;
  final int incorrect;
  final VoidCallback onDone;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct / total * 100).round();
    return AlertDialog(
      title: Text(l.session_complete),
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
          _StatRow(label: l.total_cards, value: '$total'),
          _StatRow(
            label: l.session_correct,
            value: '$correct',
            color: AppColors.badgeGreen(context),
          ),
          _StatRow(
            label: l.session_incorrect,
            value: '$incorrect',
            color: AppColors.badgeRed(context),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onDone,
          child: Text(l.finish_btn),
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
