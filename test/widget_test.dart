import 'package:flutter_test/flutter_test.dart';
import 'package:cardblaze/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CardBlazeApp());
    expect(find.byType(CardBlazeApp), findsOneWidget);
  });
}
