// Obizplan widget smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:obizplan/app/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ObizplanApp());
    expect(find.byType(ObizplanApp), findsOneWidget);
  });
}
