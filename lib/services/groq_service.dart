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
  static const apiKey = 'gsk_ТВOJ_KLJUČ_ОВДЕ';
  static const _apiKey = apiKey;
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  static const _freeMaxChars = 500;
  static const _proMaxChars = 5000;

  Future<List<FlashCard>> generateCards(
    String input,
    int count,
    String mode, {
    bool isPremium = false,
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

    final prompt = _buildPrompt(input, count, mode);
    final cards = await _callWithRetry(prompt);
    return cards;
  }

  String _buildPrompt(String input, int count, String mode) {
    if (mode == 'text') {
      return 'Analiziraj sljedeći tekst i generiraj točno $count flashkartica.\n'
          'Vrati SAMO JSON array bez ikakvog dodatnog teksta:\n'
          '[{"front": "pitanje", "back": "odgovor"}, ...]\n'
          'Pitanja trebaju biti jasna i specifična.\n'
          'Odgovori trebaju biti kratki i precizni (1-2 rečenice).\n'
          'Tekst: $input';
    }
    return 'Generiraj točno $count flashkartica za temu: $input\n'
        'Vrati SAMO JSON array bez ikakvog dodatnog teksta:\n'
        '[{"front": "pitanje", "back": "odgovor"}, ...]\n'
        'Pokri ključne koncepte, definicije i važne činjenice.';
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
              'Authorization': 'Bearer $_apiKey',
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
      // strip potential markdown fences
      final clean = content
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
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
}
