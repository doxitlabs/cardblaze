import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cardblaze/models/flash_card.dart';
import 'package:isar/isar.dart';

class GroqException implements Exception {
  final String message;
  const GroqException(this.message);
  @override
  String toString() => 'GroqException: $message';
}

class PremiumRequiredException implements Exception {
  final String message;
  const PremiumRequiredException(this.message);
  @override
  String toString() => 'PremiumRequiredException: $message';
}

class GroqService {
  static const _url = 'https://bjurrwlmnugmmavdyrfo.supabase.co/functions/v1/generate-cards';
  static const _anonKey = 'sb_publishable_0ibllJ0g4i7n5cfOM3nnsg_wZIFOfLW';
  static const _model = 'openai/gpt-oss-120b';

  static const _freeMaxChars = 500;
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
        throw const PremiumRequiredException(
          'Tekst je predugačak. Nadogradi na Pro za do 5000 znakova.',
        );
      }
      throw GroqException('Tekst premašuje limit od $_proMaxChars znakova.');
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
    const jsonRules = 'IMPORTANT: Return ONLY a valid JSON array. Do NOT use quotation marks or apostrophes inside the text values — rephrase to avoid them. No markdown, no code blocks, no extra text.\n';
    if (mode == 'text') {
      return '${langInstruction}Analyze the following text and generate exactly $count flashcards.\n'
          '${jsonRules}'
          '[{"front": "question", "back": "answer"}, ...]\n'
          'Questions should be clear and specific.\n'
          'Answers should be short and precise (1-2 sentences).\n'
          'Text: $input';
    }
    return '${langInstruction}Generate UP TO $count flashcards STRICTLY about this specific topic: "$input"\n'
        'Generate as many as the topic allows — do not invent or repeat content just to reach $count.\n'
        'Every question and answer must be directly and specifically about "$input" — do NOT drift to broader or related topics.\n'
        '${jsonRules}'
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
      throw GroqException('Mrežna greška: $e');
    }

    if (response.statusCode != 200) {
      throw GroqException('API greška ${response.statusCode}: ${response.body}');
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
      throw GroqException('Neispravni JSON odgovor: $e');
    }

    List<dynamic> list;
    if (parsed is List) {
      list = parsed;
    } else if (parsed is Map<String, dynamic>) {
      final val = parsed.values.firstWhere(
        (v) => v is List,
        orElse: () => null,
      );
      if (val == null) throw const GroqException('Neočekivani format odgovora.');
      list = val as List;
    } else {
      throw const GroqException('Neočekivani format odgovora.');
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
        .trim();
  }
}
