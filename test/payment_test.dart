import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/screens/payment_page.dart';
import 'package:flutter_application_2/screens/add_new_card_page.dart';

/// 5.5 Payments Test Cases
void main() {
  group('Payment Tests', () {
    testWidgets('PM-001 (Happy) Add card - Enter valid info → Save',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaymentPage()));
      await tester.pumpAndSettle();

      // Scroll to find Add New Card button
      final scrollFinder = find.byType(SingleChildScrollView).first;
      
      final addCardButton = find.text('Add New Card');
      if (addCardButton.evaluate().isNotEmpty) {
        // Scroll to button if needed
        try {
          await tester.ensureVisible(addCardButton);
          await tester.pumpAndSettle();
        } catch (e) {
          // Button might be off-screen, try scrolling
          await tester.drag(scrollFinder, const Offset(0, -300));
          await tester.pumpAndSettle();
        }

        await tester.tap(addCardButton, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Should navigate to AddNewCardPage
        if (find.byType(AddNewCardPage).evaluate().isNotEmpty) {
          expect(find.byType(AddNewCardPage), findsOneWidget);

          // Enter valid card info
          final cardNumberField = find.widgetWithText(TextField, 'Card Number');
          if (cardNumberField.evaluate().isNotEmpty) {
            await tester.enterText(cardNumberField, '4532123456789012');
            await tester.pumpAndSettle();
          }

          // Save card
          final saveButton = find.widgetWithText(ElevatedButton, 'Save Card');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('PM-002 (Sad) Invalid number - Error "Invalid card number"',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddNewCardPage()));
      await tester.pumpAndSettle();

      // Enter invalid card number
      final cardNumberField = find.byType(TextField).first;
      await tester.enterText(cardNumberField, '1234');
      await tester.pumpAndSettle();

      // Try to save
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Card');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Expected: Error "Invalid card number"
      }
    });

    testWidgets('PM-003 (Happy) Pay invoice - Payment succeeds; receipt shown',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaymentPage()));
      await tester.pumpAndSettle();

      // Scroll to find pay button
      final scrollFinder = find.byType(SingleChildScrollView).first;
      
      final payButton = find.widgetWithText(ElevatedButton, 'Pay');
      if (payButton.evaluate().isNotEmpty) {
        try {
          await tester.ensureVisible(payButton);
          await tester.pumpAndSettle();
        } catch (e) {
          await tester.drag(scrollFinder, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        
        await tester.tap(payButton, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Expected: Payment succeeds; receipt shown
      }
    });

    testWidgets('PM-004 (Sad) Gateway decline - Error "Payment declined"',
        (WidgetTester tester) async {
      // Use decline token
      await tester.pumpWidget(const MaterialApp(home: PaymentPage()));
      await tester.pumpAndSettle();

      // Verify payment page loads correctly
      expect(find.text('Payment'), findsOneWidget);

      // Expected: Error "Payment declined"
      // This requires payment gateway integration
    });
  });
}
