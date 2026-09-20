import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:cardblaze/models/deck.dart';
import 'package:cardblaze/models/flash_card.dart';
import 'package:cardblaze/providers/deck_providers.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/services/groq_service.dart';
import 'package:cardblaze/widgets/upgrade_dialog.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final _groqServiceProvider = Provider<GroqService>((_) => GroqService());

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
  final _newDeckNameCtrl = TextEditingController();

  int _cardCount = 15;
  bool _isLoading = false;

  // deck selection: null = none yet, -1 = "Novi deck"
  int? _selectedDeckId;
  String _newDeckColor = '#4A9EFF';

  List<FlashCard> _preview = [];
  // parallel controllers for editable preview cards
  List<TextEditingController> _frontCtrl = [];
  List<TextEditingController> _backCtrl = [];

  static const _colorOptions = [
    '#4A9EFF',
    '#6B4FA0',
    '#2E7D32',
    '#E65100',
    '#C62828',
    '#1565C0',
    '#FF8F00',
    '#00838F',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _newDeckNameCtrl.dispose();
    for (final c in _frontCtrl) {
      c.dispose();
    }
    for (final c in _backCtrl) {
      c.dispose();
    }
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

  String _modeLabel(_InputMode m) {
    switch (m) {
      case _InputMode.text:
        return 'Tekst';
      case _InputMode.topic:
        return 'Tema';
      case _InputMode.pdf:
        return 'PDF';
    }
  }

  // ── generate ───────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) {
      _showError('Unesi tekst ili temu.');
      return;
    }
    if (_selectedDeckId == null) {
      _showError('Odaberi deck ili kreiraj novi.');
      return;
    }
    if (_selectedDeckId == -1 && _newDeckNameCtrl.text.trim().isEmpty) {
      _showError('Unesi naziv novog decka.');
      return;
    }

    final isPremium = await ref.read(premiumStatusProvider.future);

    setState(() {
      _isLoading = true;
      _preview = [];
    });

    try {
      final groq = ref.read(_groqServiceProvider);
      final mode = _mode == _InputMode.text ? 'text' : 'topic';
      final cards = await groq.generateCards(
        input,
        _cardCount,
        mode,
        isPremium: isPremium,
      );
      setState(() => _setPreview(cards));
    } on PremiumRequiredException catch (_) {
      if (mounted) await showUpgradeDialog(context);
    } on GroqException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Greška: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── save ───────────────────────────────────────────────────────────────────

  Future<void> _saveAll() async {
    if (_preview.isEmpty) return;

    final isar = ref.read(isarServiceProvider);
    int deckId;

    if (_selectedDeckId == -1) {
      final deck = Deck()
        ..name = _newDeckNameCtrl.text.trim()
        ..colorHex = _newDeckColor
        ..createdAt = DateTime.now();
      await isar.saveDeck(deck);
      deckId = deck.id;
    } else {
      deckId = _selectedDeckId!;
    }

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

    ref.invalidate(decksRefreshProvider);
    ref.invalidate(cardsRefreshProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_preview.length} kartica spremljeno!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _preview = [];
        _inputCtrl.clear();
      });
    }
  }

  // ── dialogs ────────────────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.badgeRed(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI generiranje')),
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
                });
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
                      _modeLabel(m),
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
      return OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.upload_file),
        label: const Text('Odaberi PDF s uređaja'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      );
    }

    final isText = _mode == _InputMode.text;
    return TextField(
      controller: _inputCtrl,
      maxLines: isText ? 8 : 1,
      minLines: isText ? 5 : 1,
      decoration: InputDecoration(
        hintText: isText
            ? 'Paste tekst odavde...'
            : 'npr. Fotosinteza, Rimsko pravo...',
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
          'Deck',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        decksAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Greška pri učitavanju deckova'),
          data: (decks) {
            final items = [
              ...decks.map(
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
              ),
              const DropdownMenuItem<int>(
                value: -1,
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 8),
                    Text('Novi deck'),
                  ],
                ),
              ),
            ];

            return InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.layers_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              child: DropdownButton<int>(
                value: _selectedDeckId,
                hint: const Text('Odaberi deck...'),
                items: items,
                onChanged: (v) => setState(() => _selectedDeckId = v),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: AppColors.surface(context),
              ),
            );
          },
        ),
        if (_selectedDeckId == -1) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _newDeckNameCtrl,
            decoration: const InputDecoration(
              hintText: 'Naziv novog decka...',
              prefixIcon: Icon(Icons.drive_file_rename_outline),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Boja decka',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          _buildColorPicker(),
        ],
      ],
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      children: _colorOptions.map((hex) {
        final selected = _newDeckColor == hex;
        return GestureDetector(
          onTap: () => setState(() => _newDeckColor = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hexColor(hex),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.textPrimary(context)
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: _hexColor(hex).withValues(alpha: 0.5), blurRadius: 6)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── card count row ─────────────────────────────────────────────────────────

  Widget _buildCardCountRow(ColorScheme cs) {
    return Row(
      children: [
        Text(
          'Broj kartica',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        _CountButton(
          icon: Icons.remove,
          onTap: _cardCount > 5
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
          onTap: _cardCount < 30
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
        label: const Text('Generiraj kartice'),
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
              label: const Text('Spremi sve u deck'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_preview.length, (i) => _buildPreviewTile(i, cs)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveAll,
            icon: const Icon(Icons.save_alt),
            label: Text('Spremi sve (${_preview.length})'),
          ),
        ),
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
        title: Text(
          _frontCtrl[i].text,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          const Divider(height: 16),
          _EditableField(
            label: 'Pitanje',
            controller: _frontCtrl[i],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _EditableField(
            label: 'Odgovor',
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
      ],
    );
  }
}
