import 'package:flutter_test/flutter_test.dart';
import 'package:aura_app/main.dart'; // Make sure this points to your main.dart

void main() {
  testWidgets('HomeScreen displays title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuraApp()); // Changed from MyApp to AuraApp

    // Verify that our main title is present.
    expect(find.text('How would you like to express yourself?'), findsOneWidget);

    // Verify that our buttons are present.
    expect(find.text('Paint a Feeling'), findsOneWidget);
    expect(find.text('Talk it Out'), findsOneWidget);
    expect(find.text('View Your Journal'), findsOneWidget);
  });
}