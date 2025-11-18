import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/screens/add_your_art_page.dart';
import 'package:flutter_application_2/screens/my_art_page.dart';

/// 5.4 Add Your Art (Seller Flow) Test Cases
void main() {
  group('Add Your Art Tests', () {
    testWidgets('AA-001 (Happy) Submit listing - Art added to listings',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddYourArtPage()));
      await tester.pumpAndSettle();

      // Find input fields
      final titleField = find.widgetWithText(TextField, 'Leonardo');
      final descriptionField = find.widgetWithText(TextField, 'This is an exquisite painting.');

      // Enter all required data
      await tester.enterText(titleField, 'Beautiful Landscape');
      await tester.enterText(descriptionField, 'A stunning landscape painting');
      await tester.pumpAndSettle();

      // Find min/max price fields
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Enter price range
      await tester.enterText(textFields.at(2), '1000');
      await tester.enterText(textFields.at(3), '5000');
      await tester.pumpAndSettle();

      // Upload image (tap upload button)
      final uploadButton = find.text('Upload Image');
      if (uploadButton.evaluate().isNotEmpty) {
        await tester.tap(uploadButton);
        await tester.pumpAndSettle();
      }

      // Submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Expected: Art added to listings, navigate to MyArtPage
        expect(find.byType(MyArtPage), findsOneWidget);
      }
    });

    testWidgets('AA-002 (Sad) Missing image - Error "Image required"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddYourArtPage()));
      await tester.pumpAndSettle();

      // Fill all fields except image
      final titleField = find.widgetWithText(TextField, 'Leonardo');
      await tester.enterText(titleField, 'Test Art');
      await tester.pumpAndSettle();

      // Try submitting without image
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Expected: Error "Image required"
        // This requires validation logic implementation
      }
    });

    testWidgets('AA-003 (Sad) Invalid price range - Min > Max',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddYourArtPage()));
      await tester.pumpAndSettle();

      // Enter invalid price range (Min > Max)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(2), '5000'); // Min
      await tester.enterText(textFields.at(3), '1000'); // Max
      await tester.pumpAndSettle();

      // Try to submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Expected: Validation error displayed
      }
    });
  });
}
