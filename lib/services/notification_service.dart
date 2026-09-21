import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _channelId = 'cardblaze_daily';
  static const _notifId = 1;
  static const _prefEnabled = 'notifications_enabled';
  static const _prefHour = 'notifications_hour';
  static const _prefMinute = 'notifications_minute';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Use UTC — we convert local times to UTC manually before scheduling
    tz.setLocalLocation(tz.UTC);
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? false;
  }

  Future<(int, int)> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_prefHour) ?? 9, prefs.getInt(_prefMinute) ?? 0);
  }

  Future<void> setTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, hour);
    await prefs.setInt(_prefMinute, minute);
    if (prefs.getBool(_prefEnabled) ?? false) {
      await _scheduleDaily(hour, minute);
    }
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, value);
    if (value) {
      final h = prefs.getInt(_prefHour) ?? 9;
      final m = prefs.getInt(_prefMinute) ?? 0;
      await _scheduleDaily(h, m);
    } else {
      await _plugin.cancel(_notifId);
    }
  }

  Future<bool> requestPermission() async {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> _scheduleDaily(int hour, int minute) async {
    final nowLocal = DateTime.now();
    var scheduledLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
    if (!scheduledLocal.isAfter(nowLocal)) {
      scheduledLocal = scheduledLocal.add(const Duration(days: 1));
    }
    final scheduledUtc = scheduledLocal.toUtc();
    final scheduled = tz.TZDateTime.from(scheduledUtc, tz.UTC);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Daily reminder',
        channelDescription: 'Daily study reminder',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );
    try {
      await _plugin.zonedSchedule(
        _notifId,
        'CardBlaze',
        '📚 Vrijeme za učenje! Kartice čekaju.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Exact alarms not permitted — fall back to inexact
      await _plugin.zonedSchedule(
        _notifId,
        'CardBlaze',
        '📚 Vrijeme za učenje! Kartice čekaju.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}

final notificationService = NotificationService();
