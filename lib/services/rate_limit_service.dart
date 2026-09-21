import 'package:shared_preferences/shared_preferences.dart';

class RateLimitService {
  static const _keyCount = 'ai_gen_count';
  static const _keyDate = 'ai_gen_date';
  static const _freeLimit = 5;

  Future<int> usedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyDate) ?? '';
    final today = _today();
    if (stored != today) return 0;
    return prefs.getInt(_keyCount) ?? 0;
  }

  // Returns true if allowed, false if limit exceeded.
  Future<bool> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final stored = prefs.getString(_keyDate) ?? '';
    int count = (stored == today) ? (prefs.getInt(_keyCount) ?? 0) : 0;
    if (count >= _freeLimit) return false;
    await prefs.setString(_keyDate, today);
    await prefs.setInt(_keyCount, count + 1);
    return true;
  }

  int get dailyLimit => _freeLimit;

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}

final rateLimitService = RateLimitService();
