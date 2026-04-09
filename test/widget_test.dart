// widget_test.dart
// Purpose: Smoke test verifying the Kapi app launches and renders the main title.

import 'package:flutter_test/flutter_test.dart';

import 'package:kapi/app.dart';

void main() {
  testWidgets('Kapi app launches and shows header title', (WidgetTester tester) async {
    await tester.pumpWidget(const KapiApp());
    await tester.pump();
    expect(find.text('khallaf Api test'), findsOneWidget);
  });
}
