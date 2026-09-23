import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/services/groq_service.dart';
import 'package:cardblaze/widgets/upgrade_dialog.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/services/rate_limit_service.dart';
import 'package:cardblaze/services/pdf_service.dart';
import 'package:cardblaze/services/premium_service.dart';
import 'package:cardblaze/widgets/math_text.dart';
import 'package:cardblaze/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final _groqServiceProvider = Provider<GroqService>((_) => GroqService());
final _pdfServiceProvider = Provider<PdfService>((_) => PdfService());

// True while the Generate tab has AI-generated cards in preview that have
// not been saved yet — read by ScaffoldWithNav to warn before navigating away.
final aiGenerateHasUnsavedCardsProvider = StateProvider<bool>((_) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

enum _InputMode { text, topic, pdf }

class AiGenerateScreen extends ConsumerStatefulWidget {
  const AiGenerateScreen({super.key});

  @override
  ConsumerState<AiGenerateScreen> createState() => _AiGenerateScreenState();
}

class _AiGenerateScreenState extends ConsumerState<AiGenerateScreen> {
  _InputMode _mode = _InputMode.topic;

  final _inputCtrl = TextEditingController();

  int _cardCount = 15;
  bool _isLoading = false;

  int? _selectedDeckId;
  String? _pickedFileName;

  List<FlashCard> _preview = [];
  // parallel controllers for editable preview cards
  List<TextEditingController> _frontCtrl = [];
  List<TextEditingController> _backCtrl = [];

  @override
  void dispose() {
    _inputCtrl.dispose();
    for (final c in _frontCtrl) {
      c.dispose();
    }
    for (final c in _backCtrl) {
      c.dispose();
    }
    ref.read(aiGenerateHasUnsavedCardsProvider.notifier).state = false;
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  void _setPreview(List<FlashCard> cards) {
    for (final c in _frontCtrl) {
      c.dispose();
    }
    for (final c in _backCtrl) {
      c.dispose();
    }
    _frontCtrl = cards.map((c) => TextEditingController(text: c.front)).toList();
    _backCtrl = cards.map((c) => TextEditingController(text: c.back)).toList();
    _preview = cards;
  }

  String _modeLabel(_InputMode m, AppLocalizations l) {
    switch (m) {
      case _InputMode.text:
        return l.text_mode;
      case _InputMode.topic:
        return l.topic_mode;
      case _InputMode.pdf:
        return l.pdf_mode;
    }
  }

  // ── generate ───────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    final input = _inputCtrl.text.trim();
    final l = AppLocalizations.of(context);
    if (input.isEmpty) {
      _showError(l.error_enter_text);
      return;
    }
    if (_selectedDeckId == null) {
      _showError(l.error_select_deck);
      return;
    }
    final isPremium = await ref.read(premiumStatusProvider.future);

    // Rate limit: free users max 5 generations/day
    if (!isPremium) {
      final allowed = await rateLimitService.consume();
      if (!allowed && mounted) {
        final used = await rateLimitService.usedToday();
        _showError('Dnevni limit od ${rateLimitService.dailyLimit} generiranja dostignut ($used/${rateLimitService.dailyLimit}). Nadogradi na Pro za neograničeno generiranje.');
        return;
      }
    }

    // Card count limit: free 15 total per deck, pro 100 total per deck —
    // minus cards the deck already has.
    final existingCards = await ref.read(cardsForDeckProvider(_selectedDeckId!).future);
    final limit = isPremium ? PremiumLimits.maxCardsPerDeckPro : PremiumLimits.maxCardsPerDeck;
    final remainingCapacity = (limit - existingCards.length).clamp(0, limit);
    if (remainingCapacity <= 0) {
      if (!mounted) return;
      if (isPremium) {
        _showError(AppLocalizations.of(context).ai_deck_limit_reached(limit));
      } else {
        await showUpgradeDialog(context);
      }
      return;
    }
    final requestedCount = _cardCount > remainingCapacity ? remainingCapacity : _cardCount;

    if (!mounted) return;
    final language = Localizations.localeOf(context).languageCode;
    setState(() {
      _isLoading = true;
      _preview = [];
    });

    try {
      final groq = ref.read(_groqServiceProvider);
      final mode = _mode == _InputMode.topic ? 'topic' : 'text';
      final cards = await groq.generateCards(
        input,
        requestedCount,
        mode,
        isPremium: isPremium,
        language: language,
      );
      setState(() => _setPreview(cards));
      ref.read(aiGenerateHasUnsavedCardsProvider.notifier).state = cards.isNotEmpty;
    } on PremiumRequiredException catch (_) {
      if (mounted) {
        _showError(AppLocalizations.of(context).error_text_too_long_free);
        // Wait for the snackbar to fully disappear before the modal opens.
        await Future.delayed(_errorSnackDuration);
        if (mounted) await showUpgradeDialog(context);
      }
    } on TextTooLongException catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).error_text_too_long_pro(e.maxChars));
    } on GroqException catch (e) {
      _showError(e.message);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).error_generic('$e'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── document import ───────────────────────────────────────────────────────

  Future<void> _pickDocument() async {
    try {
      final text = await ref.read(_pdfServiceProvider).pickAndExtract();
      if (text == null || !mounted) return; // user cancelled the picker
      setState(() {
        _inputCtrl.text = text;
        _pickedFileName = AppLocalizations.of(context).ai_document_loaded;
      });
    } on FileNotFoundException catch (e) {
      _showError(e.message);
    } on PdfExtractionException catch (e) {
      _showError(e.message);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).error_generic('$e'));
    }
  }

  // ── save ───────────────────────────────────────────────────────────────────

  Future<void> _saveAll() async {
    if (_preview.isEmpty) return;

    final isar = ref.read(isarServiceProvider);
    int deckId;

    deckId = _selectedDeckId!;

    final now = DateTime.now();
    for (int i = 0; i < _preview.length; i++) {
      final card = FlashCard()
        ..id = Isar.autoIncrement
        ..deckId = deckId
        ..front = _frontCtrl[i].text.trim()
        ..back = _backCtrl[i].text.trim()
        ..createdAt = now
        ..dueDate = now;
      await isar.saveCard(card);
    }

    ref.read(decksRefreshProvider.notifier).state++;
    ref.read(cardsRefreshProvider.notifier).state++;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cards_saved(_preview.length)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _preview = [];
        _inputCtrl.clear();
      });
      ref.read(aiGenerateHasUnsavedCardsProvider.notifier).state = false;
    }
  }

  // ── dialogs ────────────────────────────────────────────────────────────────

  static const _errorSnackDuration = Duration(seconds: 3);

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.badgeRed(context),
        behavior: SnackBarBehavior.floating,
        duration: _errorSnackDuration,
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: GradientTitle(AppLocalizations.of(context).generate_title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSegmentControl(cs),
          const SizedBox(height: 20),
          _buildInputField(),
          const SizedBox(height: 20),
          _buildDeckSelector(cs),
          const SizedBox(height: 20),
          _buildCardCountRow(cs),
          const SizedBox(height: 24),
          _buildGenerateButton(cs),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            _buildLoadingState(cs),
          ],
          if (_preview.isNotEmpty) ...[
            const SizedBox(height: 28),
            _buildPreviewSection(cs),
          ],
        ],
      ),
    );
  }

  // ── segment control ────────────────────────────────────────────────────────

  Widget _buildSegmentControl(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: _InputMode.values.map((m) {
          final selected = _mode == m;
          final isPdf = m == _InputMode.pdf;
          final l = AppLocalizations.of(context);
          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (isPdf) {
                  if (!await checkPremium(context, ref)) return;
                }
                setState(() {
                  _mode = m;
                  _preview = [];
                  _inputCtrl.clear();
                  _pickedFileName = null;
                });
                ref.read(aiGenerateHasUnsavedCardsProvider.notifier).state = false;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _modeLabel(m, l),
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary(context),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    if (isPdf) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: selected ? Colors.white70 : AppColors.purple(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── input field ────────────────────────────────────────────────────────────

  Widget _buildInputField() {
    if (_mode == _InputMode.pdf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _pickDocument,
            icon: const Icon(Icons.upload_file),
            label: Text(_pickedFileName ?? AppLocalizations.of(context).pdf_mode),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          if (_pickedFileName != null) ...[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).ai_chars_loaded(_inputCtrl.text.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      );
    }

    final isText = _mode == _InputMode.text;
    return TextField(
      controller: _inputCtrl,
      maxLines: isText ? 8 : 1,
      minLines: isText ? 5 : 1,
      decoration: InputDecoration(
        hintText: isText
            ? AppLocalizations.of(context).text_paste_hint
            : AppLocalizations.of(context).topic_hint,
        alignLabelWithHint: isText,
      ),
    );
  }

  // ── deck selector ──────────────────────────────────────────────────────────

  Widget _buildDeckSelector(ColorScheme cs) {
    final decksAsync = ref.watch(allDecksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).select_deck,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        decksAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Greška pri učitavanju deckova'),
          data: (decks) {
            final items = decks.map(
              (d) => DropdownMenuItem<int>(
                value: d.id,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _hexColor(d.colorHex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(d.name),
                  ],
                ),
              ),
            ).toList();

            return InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.layers_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              child: DropdownButton<int>(
                value: _selectedDeckId,
                hint: Text(AppLocalizations.of(context).select_deck),
                items: items,
                onChanged: (v) => setState(() => _selectedDeckId = v),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: AppColors.surface(context),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── card count row ─────────────────────────────────────────────────────────

  Widget _buildCardCountRow(ColorScheme cs) {
    final isPremiumAsync = ref.watch(premiumStatusProvider);
    final isPremium = isPremiumAsync.value ?? false;
    final limit = isPremium ? PremiumLimits.maxCardsPerDeckPro : PremiumLimits.maxCardsPerDeck;

    int? maxAllowed;
    if (_selectedDeckId != null) {
      final existingAsync = ref.watch(cardsForDeckProvider(_selectedDeckId!));
      final existingCount = existingAsync.value?.length;
      if (existingCount != null) {
        maxAllowed = (limit - existingCount).clamp(0, limit);
      }
    }
    // Unknown yet (deck not selected or still loading) — fall back to the
    // free-tier ceiling so the stepper never overshoots before we know better.
    maxAllowed ??= limit;

    final minAllowed = maxAllowed <= 0 ? 0 : (maxAllowed < 5 ? 1 : 5);
    if (_cardCount > maxAllowed || _cardCount < minAllowed) {
      final clamped = maxAllowed <= 0 ? 0 : _cardCount.clamp(minAllowed, maxAllowed);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _cardCount != clamped) setState(() => _cardCount = clamped);
      });
    }

    return Row(
      children: [
        Text(
          AppLocalizations.of(context).card_count,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        _CountButton(
          icon: Icons.remove,
          onTap: _cardCount > minAllowed
              ? () => setState(() => _cardCount--)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_cardCount',
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        _CountButton(
          icon: Icons.add,
          onTap: _cardCount < maxAllowed
              ? () => setState(() => _cardCount++)
              : null,
        ),
      ],
    );
  }

  // ── generate button ────────────────────────────────────────────────────────

  Widget _buildGenerateButton(ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _generate,
        icon: const Icon(Icons.auto_awesome),
        label: Text(AppLocalizations.of(context).generate_btn),
      ),
    );
  }

  // ── loading state ──────────────────────────────────────────────────────────

  Widget _buildLoadingState(ColorScheme cs) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        Text(
          'AI generira kartice...',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── preview section ────────────────────────────────────────────────────────

  Widget _buildPreviewSection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pregled (${_preview.length} kartica)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _saveAll,
              icon: const Icon(Icons.save_alt),
              label: Text(AppLocalizations.of(context).save),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_preview.length, (i) => _buildPreviewTile(i, cs)),
      ],
    );
  }

  Widget _buildPreviewTile(int i, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color: cs.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: MathText(
          _frontCtrl[i].text,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          const Divider(height: 16),
          _EditableField(
            label: AppLocalizations.of(context).front,
            controller: _frontCtrl[i],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _EditableField(
            label: AppLocalizations.of(context).back,
            controller: _backCtrl[i],
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ── util ───────────────────────────────────────────────────────────────────

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CountButton extends StatelessWidget {
  const _CountButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surface(context)
              : AppColors.surface2(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.textPrimary(context)
              : AppColors.textMuted(context),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        MathPreview(controller: controller),
      ],
    );
  }
}
