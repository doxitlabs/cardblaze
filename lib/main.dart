import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cardblaze/app.dart';
import 'package:cardblaze/services/isar_service.dart';
import 'package:cardblaze/services/premium_service.dart';
import 'package:cardblaze/services/notification_service.dart';
import 'package:cardblaze/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final isarService = IsarService();
  await isarService.init();

  await PremiumService.init();

  await notificationService.init();

  // Update home screen widget with today's due count
  await WidgetService(isarService).updateWidget();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const CardBlazeApp(),
    ),
  );
}
