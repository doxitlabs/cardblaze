import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cardblaze/models/flash_card.dart';
import 'package:isar/isar.dart';

// UI localizes by [isNetwork]; [message] is a technical detail (English).
class GroqException implements Exception {
  final String message;
  final bool isNetwork;
  const GroqException(this.message, {this.isNetwork = false});
  @override
  String toString() => 'GroqException: $message';
}

// Free user's input exceeds the free character limit — UI localizes and
// displays the reason itself, since this service has no BuildContext.
class PremiumRequiredException implements Exception {
  const PremiumRequiredException();
  @override
  String toString() => 'PremiumRequiredException';
}

// Pro user's input exceeds the pro character limit — UI localizes the
// message itself using [maxChars], since this service has no BuildContext.
class TextTooLongException implements Exception {
  final int maxChars;
  const TextTooLongException(this.maxChars);
  @override
  String toString() => 'TextTooLongException: $maxChars';
}

class GroqService {
  static const _url = 'https://bjurrwlmnugmmavdyrfo.supabase.co/functions/v1/generate-cards';
  static const _anonKey = 'sb_publishable_0ibllJ0g4i7n5cfOM3nnsg_wZIFOfLW';
  static const _model = 'openai/gpt-oss-120b';

  // Formulas are rendered in-app by MathText (flutter_math_fork), which
  // expects LaTeX between $...$ (inline) or $$...$$ (standalone).
  static const _mathRules =
      'If a question or answer contains any mathematical, physical or chemical formula, equation, fraction, root, exponent, index or symbol, '
      r'write that part in LaTeX wrapped in single dollar signs, e.g. $\frac{a}{b}$, $x^{2}$, $\sqrt{2}$, $H_{2}O$, $\int_0^1 x\,dx$. '
      'Use dollar signs ONLY around math — never for currency or anything else. Keep normal words outside the dollar signs. '
      r'Inside JSON strings every LaTeX backslash MUST be doubled (write \\frac, \\sqrt, \\alpha).'
      '\n';

  static const _freeMaxChars = 2500;
  static const _proMaxChars = 5000;

  Future<List<FlashCard>> generateCards(
    String input,
    int count,
    String mode, {
    bool isPremium = false,
    String language = 'en',
  }) async {
    final maxChars = isPremium ? _proMaxChars : _freeMaxChars;
    if (input.length > maxChars) {
      if (!isPremium) {
        throw const PremiumRequiredException();
      }
      throw TextTooLongException(_proMaxChars);
    }

    final prompt = _buildPrompt(input, count, mode, language);
    final cards = await _callWithRetry(prompt);
    return cards;
  }

  String _buildPrompt(String input, int count, String mode, String language) {
    final langName = _languageName(language);
    final extraHr = language == 'hr'
        ? 'Pay special attention to Croatian grammar: correct noun cases (padeži), verb conjugation, and natural word order. Avoid direct translation from English. '
        : '';
    final langInstruction =
        'Write all questions and answers in $langName. Use correct $langName grammar, natural phrasing, and proper sentence structure — not a literal translation. $extraHr';
    const jsonRules = 'IMPORTANT: Return ONLY a valid JSON array. Do NOT use quotation marks or apostrophes inside the text values — rephrase to avoid them. No markdown, no code blocks, no extra text.\n'
        '$_mathRules';
    if (mode == 'text') {
      return '${langInstruction}Analyze the following text and generate exactly $count flashcards.\n'
          '$jsonRules'
          '[{"front": "question", "back": "answer"}, ...]\n'
          'Questions should be clear and specific.\n'
          'Answers should be short and precise (1-2 sentences).\n'
          'Text: $input';
    }
    return '${langInstruction}Generate as close to $count flashcards as the topic allows — stop only if the topic genuinely has no more distinct facts to cover.\n'
        'Topic: "$input"\n'
        'Every question and answer must be directly and specifically about "$input" — do NOT drift to broader or related topics.\n'
        '$jsonRules'
        '[{"front": "question", "back": "answer"}, ...]\n'
        'Cover specific facts, dates, names, causes and consequences related only to "$input".';
  }

  String _languageName(String code) {
    const map = {
      'hr': 'Croatian',
      'de': 'German',
      'fr': 'French',
      'it': 'Italian',
      'en': 'English',
    };
    return map[code] ?? 'English';
  }

  // Returns map: card index → list of 2 wrong answers
  Future<Map<int, List<String>>> generateDistractors(
    List<FlashCard> cards,
    String language,
  ) async {
    if (cards.isEmpty) return {};

    const batchSize = 8;
    final result = <int, List<String>>{};

    for (var start = 0; start < cards.length; start += batchSize) {
      final end = (start + batchSize).clamp(0, cards.length);
      final batch = cards.sublist(start, end);

      final items = batch
          .asMap()
          .entries
          .map((e) =>
              '{"i":${e.key},"q":${jsonEncode(e.value.front)},"a":${jsonEncode(e.value.back)}}')
          .join(',');

      final prompt =
          'You are generating quiz distractors.\n'
          'For EVERY card below, produce exactly 2 WRONG but plausible answer alternatives.\n'
          'CRITICAL: Write each wrong answer in the SAME language as that card\'s correct answer ("a" field) — detect the language automatically per card.\n'
          'Wrong answers must look realistic — vary numbers, dates, names, swap cause/effect, etc.\n'
          'NEVER repeat the correct answer. Keep wrong answers the same length/style as the correct answer.\n'
          r'If the correct answer contains LaTeX between $...$, write the wrong answers in the same LaTeX format (e.g. vary exponents, signs, coefficients). Double every backslash inside JSON strings.'
          '\n'
          'Return ONLY a valid JSON array with exactly ${batch.length} entries, no extra text:\n'
          '[{"i":0,"w":["wrong1","wrong2"]},{"i":1,"w":["wrong1","wrong2"]},...]\n'
          'Cards: [$items]';

      try {
        final http.Response response = await http
            .post(
              Uri.parse(_url),
              headers: {
                'Authorization': 'Bearer $_anonKey',
                'apikey': _anonKey,
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _model,
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
                'temperature': 0.8,
                'max_tokens': 2048,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            (data['choices'] as List)[0]['message']['content'] as String;
        final clean = _cleanJson(content);
        final list = jsonDecode(clean) as List;
        for (final item in list) {
          final m = item as Map<String, dynamic>;
          final localIdx = (m['i'] as num).toInt();
          final wrongs = (m['w'] as List).map((e) => e.toString()).toList();
          result[start + localIdx] = wrongs;
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  Future<List<FlashCard>> _callWithRetry(String prompt) async {
    try {
      return await _call(prompt);
    } on GroqException {
      rethrow;
    } catch (_) {
      // single retry
      return await _call(prompt);
    }
  }

  Future<List<FlashCard>> _call(String prompt) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': 'Bearer $_anonKey',
              'apikey': _anonKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 4096,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw GroqException('Network error: $e', isNetwork: true);
    }

    if (response.statusCode != 200) {
      throw GroqException('API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (data['choices'] as List)[0]['message']['content'] as String;

    return _parseCards(content);
  }

  List<FlashCard> _parseCards(String content) {
    dynamic parsed;
    try {
      final clean = _cleanJson(content);
      parsed = jsonDecode(clean);
    } catch (e) {
      throw GroqException('Invalid JSON response: $e');
    }

    List<dynamic> list;
    if (parsed is List) {
      list = parsed;
    } else if (parsed is Map<String, dynamic>) {
      final val = parsed.values.firstWhere(
        (v) => v is List,
        orElse: () => null,
      );
      if (val == null) throw const GroqException('Unexpected response format.');
      list = val as List;
    } else {
      throw const GroqException('Unexpected response format.');
    }

    final now = DateTime.now();
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return FlashCard()
        ..id = Isar.autoIncrement
        ..deckId = 0 // caller must set
        ..front = map['front']?.toString() ?? ''
        ..back = map['back']?.toString() ?? ''
        ..createdAt = now
        ..dueDate = now;
    }).toList();
  }

  String _cleanJson(String content) {
    return content
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        // Replace smart/curly quotes with straight quotes
        .replaceAll('“', '"').replaceAll('”', '"')
        .replaceAll('‘', "'").replaceAll('’', "'")
        // Replace Croatian/other typographic apostrophes
        .replaceAll('ʼ', "'").replaceAll('′', "'")
        .trim()
        .replaceAllMapped(_singleBackslash, _escapeLatexBackslash);
  }

  // A lone backslash (not part of an already-escaped \\) followed by letters.
  static final _singleBackslash = RegExp(r'(?<!\\)((?:\\\\)*)\\([a-zA-Z]+)');

  // Models often emit LaTeX with single backslashes inside JSON strings.
  // Then \frac, \times, \neq, \beta silently decode as form-feed / tab /
  // newline / backspace, and \sqrt, \alpha make jsonDecode throw. Double the
  // backslash for anything that looks like a LaTeX command, keeping real
  // JSON escapes (\n, \t, \uXXXX followed by a non-letter or sentence text).
  static String _escapeLatexBackslash(Match m) {
    final prefix = m.group(1)!;
    final word = m.group(2)!;
    final isJsonEscape = (word.length == 1 && 'bfnrt'.contains(word)) ||
        ('bfnrt'.contains(word[0]) && word[1].toUpperCase() == word[1]) ||
        (word == 'u' || word.startsWith('u') && RegExp(r'^u[0-9a-fA-F]{4}').hasMatch(word));
    return isJsonEscape ? m[0]! : '$prefix\\\\$word';
  }
}
