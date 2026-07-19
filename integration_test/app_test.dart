import 'package:academic_planner_fe/main.dart' as app;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guest can launch the Android app and reach planner actions', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Term'), findsOneWidget);
    expect(find.text('Goal'), findsOneWidget);
    expect(find.text('Graph'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
