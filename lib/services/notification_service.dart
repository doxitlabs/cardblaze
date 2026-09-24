import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cardblaze/l10n/app_localizations.dart';
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

  // Re-schedules the reminder so its text follows a changed app language.
  Future<void> refreshIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefEnabled) ?? false)) return;
    await _scheduleDaily(prefs.getInt(_prefHour) ?? 9, prefs.getInt(_prefMinute) ?? 0);
  }

  // Scheduling runs without a BuildContext — resolve strings for the app
  // language the same way LocaleNotifier does (saved choice, default 'en').
  Future<AppLocalizations> _appLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale') ?? 'en';
    try {
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
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
    final l = await _appLocalizations();
    final notifBody = l.notif_reminder_body;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l.notif_channel_name,
        channelDescription: l.notif_channel_desc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(notifBody),
      ),
    );
    // Inexact on purpose: exact alarms need USE_EXACT_ALARM/SCHEDULE_EXACT_ALARM,
    // which Play only allows for alarm/calendar apps. A daily study reminder
    // firing a few minutes late is fine.
    await _plugin.zonedSchedule(
      _notifId,
      'CardBlaze',
      notifBody,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

final notificationService = NotificationService();
