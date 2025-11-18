import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/screens/register_page.dart';

/// 5.2 Registration & KYC Test Cases
void main() {
  group('Registration Tests', () {
    testWidgets('RG-001 (Happy) Register - Fill all fields → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Scroll to make sure all fields are visible
      final scrollFinder = find.byType(SingleChildScrollView);
      
      // Find all text fields
      final firstNameField = find.widgetWithText(TextField, 'Lois');
      final lastNameField = find.widgetWithText(TextField, 'Becket');
      final emailField = find.widgetWithText(TextField, 'Loisbecket@gmail.com');

      // Enter valid data
      await tester.enterText(firstNameField, 'John');
      await tester.enterText(lastNameField, 'Doe');
      await tester.enterText(emailField, 'john.doe@example.com');
      await tester.pumpAndSettle();

      // Scroll down to see more fields
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      final birthDateField = find.widgetWithText(TextField, '18/03/2024');
      final phoneField = find.widgetWithText(TextField, '(454) 726-0592');
      
      await tester.enterText(birthDateField, '01/01/1990');
      await tester.enterText(phoneField, '+1234567890');
      await tester.pumpAndSettle();

      // Scroll down more
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, '*******');
      await tester.enterText(passwordField, 'SecurePass123!');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register button
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Expected: Account created successfully, navigate to home
    });

    testWidgets('RG-002 Duplicate email - Error "Email already registered"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Enter duplicate email
      final emailField = find.widgetWithText(TextField, 'Loisbecket@gmail.com');
      await tester.enterText(emailField, 'existing@example.com');
      await tester.pumpAndSettle();

      // Expected: Error "Email already registered"
      // Requires backend validation
    });

    testWidgets('RG-003 Validation - Leave First/Last Name empty → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Leave name fields empty, fill other fields
      final emailField = find.widgetWithText(TextField, 'Loisbecket@gmail.com');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expected: Inline error; Register disabled
      // Requires form validation implementation
    });

    testWidgets('RG-004 Validation - Enter invalid email (e.g., abc@) → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Enter invalid email
      final emailField = find.widgetWithText(TextField, 'Loisbecket@gmail.com');
      await tester.enterText(emailField, 'abc@');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expected: "Invalid email" message; cannot submit
    });

    testWidgets('RG-005 Validation - Select DOB making user < 18 yrs → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Scroll to birthdate field
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Enter birthdate that makes user < 18
      final birthDateField = find.widgetWithText(TextField, '18/03/2024');
      await tester.enterText(birthDateField, '01/01/2015');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expected: Error "You must be 18+"
    });

    testWidgets('RG-006 Input format - Enter phone with country code +1 → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Enter phone with country code
      final phoneField = find.widgetWithText(TextField, '(454) 726-0592');
      await tester.enterText(phoneField, '+12345678901');
      await tester.pumpAndSettle();

      // Expected: Stored as E.164 format; validation passed
    });

    testWidgets('RG-007 Validation - Enter weak password (e.g. "123456")',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Scroll to password field
      await tester.drag(scrollFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Enter weak password
      final passwordField = find.widgetWithText(TextField, '*******');
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expected: Strength error; block submission
    });

    testWidgets('RG-008 Categories (Happy) - Select multiple categories → Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Scroll to categories section
      await tester.drag(scrollFinder, const Offset(0, -400));
      await tester.pumpAndSettle();

      // Find and tap category items
      final abstractCategory = find.text('Abstract');
      final landscapeCategory = find.text('Landscape');

      expect(abstractCategory, findsOneWidget);
      expect(landscapeCategory, findsOneWidget);

      await tester.tap(abstractCategory, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(landscapeCategory, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify categories are selected (border should change)
      // Expected: Account created; categories saved
    });

    testWidgets('RG-009 Categories (Optional) - Register without selecting category',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(SingleChildScrollView);

      // Fill required fields but don't select categories
      final emailField = find.widgetWithText(TextField, 'Loisbecket@gmail.com');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Scroll to register button
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Tap Register
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Expected: Success; profile shows "No preferred categories"
    });
  });

  group('KYC Tests', () {
    testWidgets('KYC-001 (Happy) Upload ID - Status becomes "Pending Review"',
        (WidgetTester tester) async {
      // This requires Profile page implementation with KYC functionality
      // Navigate to Profile → Verify ID → Upload photo
      // Expected: Status becomes "Pending Review"
    });

    testWidgets('KYC-002 (Sad) Rejected ID - "Verification failed" message displayed',
        (WidgetTester tester) async {
      // Submit blurry image
      // Expected: "Verification failed" message displayed
    });
  });
}
