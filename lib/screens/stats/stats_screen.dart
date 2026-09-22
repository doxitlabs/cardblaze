import 'dart:convert';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardblaze/models/study_session.dart';
import 'package:cardblaze/providers/premium_providers.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/theme/app_theme.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class StatsData {
  final int streakDays;
  final int cardsThisWeek;
  final double accuracyPercent;
  final int totalCards;
  final int activeDecks;
  final List<double> cardsPerDay; // 7 values, index 0 = 6 days ago, 6 = today
  final List<StudySession> weekSessions;

  const StatsData({
    required this.streakDays,
    required this.cardsThisWeek,
    required this.accuracyPercent,
    required this.totalCards,
    required this.activeDecks,
    required this.cardsPerDay,
    required this.weekSessions,
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────

final statsProvider = FutureProvider<StatsData>((ref) async {
  final isar = ref.read(isarServiceProvider);
  final sessions = await isar.getRecentSessions(30);
  final decks = await isar.getAllDecks();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Streak — walk back from today; break on first day with no session
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final day = today.subtract(Duration(days: i));
    final hasSession = sessions.any((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d == day;
    });
    if (hasSession) {
      streak++;
    } else if (i == 0) {
      // today has no session yet — don't break streak, check yesterday
      continue;
    } else {
      break;
    }
  }

  // Week window
  final weekStart = today.subtract(const Duration(days: 6));
  final weekSessions =
      sessions.where((s) => !s.date.isBefore(weekStart)).toList();

  final cardsThisWeek =
      weekSessions.fold<int>(0, (sum, s) => sum + s.cardsStudied);

  final totalCorrect = weekSessions.fold<int>(0, (sum, s) => sum + s.correctCount);
  final accuracyPercent = cardsThisWeek > 0
      ? (totalCorrect / cardsThisWeek * 100)
      : 0.0;

  // Cards per day for last 7 days
  final cardsPerDay = List<double>.generate(7, (i) {
    final day = weekStart.add(Duration(days: i));
    return weekSessions
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          return d == day;
        })
        .fold<int>(0, (sum, s) => sum + s.cardsStudied)
        .toDouble();
  });

  // Total cards across all decks
  final totalCards = decks.fold<int>(0, (sum, d) => sum + d.cardCount);

  return StatsData(
    streakDays: streak,
    cardsThisWeek: cardsThisWeek,
    accuracyPercent: accuracyPercent,
    totalCards: totalCards,
    activeDecks: decks.length,
    cardsPerDay: cardsPerDay,
    weekSessions: weekSessions,
  );
});

// Cached AI recap — stored in SharedPreferences with week key
final aiRecapProvider = FutureProvider.family<String?, (StatsData, String)>((ref, args) async {
  final stats = args.$1;
  final locale = args.$2;
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  // Week key: YYYY-Www-locale
  final weekKey = 'ai_recap_${now.year}_${_isoWeek(now)}_$locale';

  final cached = prefs.getString(weekKey);
  if (cached != null) return cached;

  final statsJson = {
    'streak_days': stats.streakDays,
    'cards_this_week': stats.cardsThisWeek,
    'accuracy_percent': stats.accuracyPercent.toStringAsFixed(1),
    'total_cards': stats.totalCards,
    'active_decks': stats.activeDecks,
  };

  const url = 'https://bjurrwlmnugmmavdyrfo.supabase.co/functions/v1/generate-cards';
  const anonKey = 'sb_publishable_0ibllJ0g4i7n5cfOM3nnsg_wZIFOfLW';
  const model = 'openai/gpt-oss-120b';

  final langName = _languageName(locale);
  final prompt =
      'Analyze these weekly flashcard learning statistics and write a personalized 2-3 sentence weekly summary. '
      'Be specific and concrete about the data — do not invent praise that is not warranted. '
      'At the end give one concrete suggestion for next week. '
      'Write in second person (You...). Write in $langName. '
      'IMPORTANT: This app calls a flashcard collection a "deck" (do not translate this word — keep it as "deck" even in $langName, e.g. Croatian uses "deck"/"deckovi", not "špil"/"špilovi"). '
      'Statistics: ${jsonEncode(statsJson)}.';

  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $anonKey',
            'apikey': anonKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.7,
            'max_tokens': 256,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text =
          (data['choices'] as List)[0]['message']['content'] as String;
      await prefs.setString(weekKey, text.trim());
      return text.trim();
    }
  } catch (_) {
    // Network failure — return null, UI shows retry option
  }
  return null;
});

String _languageName(String locale) {
  switch (locale) {
    case 'hr': return 'Croatian';
    case 'de': return 'German';
    case 'fr': return 'French';
    case 'it': return 'Italian';
    default:   return 'English';
  }
}

int _isoWeek(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final days = date.difference(startOfYear).inDays;
  return ((days + startOfYear.weekday - 1) / 7).ceil() + 1;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: GradientTitle(AppLocalizations.of(context).stats_title),
        centerTitle: false,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Greška: $e')),
        data: (stats) {
          final isPremium = isPremiumAsync.valueOrNull ?? false;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StreakCard(streakDays: stats.streakDays),
              const SizedBox(height: 16),
              _MetricsGrid(stats: stats),
              const SizedBox(height: 16),
              _WeeklyBarChart(cardsPerDay: stats.cardsPerDay),
              const SizedBox(height: 16),
              _AiRecapCard(stats: stats, isPremium: isPremium),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakDays});
  final int streakDays;

  String _motivation(AppLocalizations l) {
    if (streakDays == 0) return l.streak_motivation_0;
    if (streakDays < 3) return l.streak_motivation_low;
    if (streakDays < 7) return l.streak_motivation_mid;
    if (streakDays < 30) return l.streak_motivation_high;
    return l.streak_motivation_legend(streakDays);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.streak_days(streakDays),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _motivation(l),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2x2 metrics grid ──────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      _MetricItem(
        label: l.cards_this_week,
        value: '${stats.cardsThisWeek}',
        icon: Icons.style,
      ),
      _MetricItem(
        label: l.accuracy,
        value: '${stats.accuracyPercent.toStringAsFixed(1)}%',
        icon: Icons.check_circle_outline,
      ),
      _MetricItem(
        label: l.total_cards,
        value: '${stats.totalCards}',
        icon: Icons.layers,
      ),
      _MetricItem(
        label: l.active_decks,
        value: '${stats.activeDecks}',
        icon: Icons.folder_copy_outlined,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items,
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: cs.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bar chart ─────────────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.cardsPerDay});
  final List<double> cardsPerDay;

  static const _days = ['Po', 'Ut', 'Sr', 'Če', 'Pe', 'Su', 'Ne'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    // Labels: last 7 days in order
    final labels = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _days[day.weekday - 1];
    });

    final maxY = cardsPerDay.reduce((a, b) => a > b ? a : b);
    final chartMax = (maxY < 10 ? 10 : (maxY * 1.2)).ceilToDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              AppLocalizations.of(context).cards_this_week,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: cs.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final isToday = i == 6;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: cardsPerDay[i],
                        color: isToday ? cs.primary : cs.primary.withValues(alpha: 0.45),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Weekly Recap ───────────────────────────────────────────────────────────

class _AiRecapCard extends ConsumerWidget {
  const _AiRecapCard({required this.stats, required this.isPremium});
  final StatsData stats;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).ai_weekly_recap,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isPremium)
                  _PremiumRecapContent(stats: stats)
                else
                  const _FreeRecapBlur(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumRecapContent extends ConsumerWidget {
  const _PremiumRecapContent({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final recapAsync = ref.watch(aiRecapProvider((stats, locale)));

    return recapAsync.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        ),
      ),
      error: (_, __) => const Text(
        'Recap nije dostupan trenutno.',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      data: (text) {
        if (text == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nema dovoljno podataka za recap ovog tjedna.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _RefreshRecapButton(stats: stats),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _RefreshRecapButton(stats: stats),
          ],
        );
      },
    );
  }
}

class _RefreshRecapButton extends ConsumerWidget {
  const _RefreshRecapButton({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        final weekKey = 'ai_recap_${now.year}_${_isoWeek(now)}_$locale';
        await prefs.remove(weekKey);
        ref.invalidate(aiRecapProvider((stats, locale)));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.refresh, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).refresh,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FreeRecapBlur extends StatelessWidget {
  const _FreeRecapBlur();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Placeholder text to blur
        const Text(
          'Ovaj tjedan si napravio odličan napredak! '
          'Tvoja točnost je porasla i streak se nastavlja. '
          'Preporučujem da fokusiraš na teže kartice.',
          style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
        ),
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Upgrade prompt overlay
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).upgrade_ai_recap,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  // Navigator handles premium upsell screen
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white60),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                ),
                child: Text(AppLocalizations.of(context).view_pro_btn),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
