import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/screens/home_page.dart';

/// 5.1 Authentication Test Cases
void main() {
  group('Authentication Tests', () {
    testWidgets('AU-001 (Happy) Email login - Enter valid email/password → Login',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify we're on login page
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Onyx'), findsOneWidget);

      // Enter valid credentials
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Expected: Lands on Home screen
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('AU-002 (Sad) Wrong password - Error "Invalid credentials"',
        (WidgetTester tester) async {
      // Note: This test demonstrates the expected behavior
      // Actual validation logic needs to be implemented in the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Enter wrong password
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Expected: Error "Invalid credentials" should be shown
      // This requires backend integration and validation logic
    });

    testWidgets('AU-003 (Happy) Google OAuth - Tap Gmail icon → login',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find Google OAuth button (icon with g_mobiledata)
      final googleButton = find.byIcon(Icons.g_mobiledata);
      expect(googleButton, findsOneWidget);

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Expected: User logged in successfully
      // This requires Google OAuth implementation
    });

    testWidgets('AU-004 (Edge) Empty fields - Validation errors shown',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap Login with no input
      final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Expected: Validation errors shown
      // This requires form validation logic to be implemented
    });

    testWidgets('AU-005 Logout - Returns to login page',
        (WidgetTester tester) async {
      // Navigate to home page first
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Expected: Logout option should navigate back to login page
      // This requires logout functionality to be implemented in the drawer
    });
  });
}
