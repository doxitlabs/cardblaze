import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:cardblaze/services/isar_service.dart';

class WidgetService {
  static const _providerName = 'CardBlazeWidgetProvider';

  final IsarService _isar;

  WidgetService(this._isar);

  Future<void> updateWidget() async {
    try {
      // Use watchTotalDueCount's first value via getDueCards across all decks
      final dueCount = await _isar.getTotalDueCount();

      await HomeWidget.saveWidgetData<int>('due_count', dueCount);
      await HomeWidget.updateWidget(androidName: _providerName);
    } catch (_) {
      // widget update is non-critical
    }
  }
}

final widgetServiceProvider = Provider<WidgetService>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return WidgetService(isar);
});
