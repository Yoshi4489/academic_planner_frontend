import 'package:academic_planner_fe/features/auth/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign in form reports missing credentials', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignInScreen())),
    );

    expect(find.text('Sign In'), findsNWidgets(2));
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Email cannot be empty'), findsOneWidget);
    expect(find.text('Password cannot be empty'), findsOneWidget);
  });

  testWidgets('sign in form rejects an invalid email', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignInScreen())),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your email'),
      'not-an-email',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
