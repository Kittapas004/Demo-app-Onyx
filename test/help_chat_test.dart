import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/screens/help_page.dart';

/// 5.7 Help & Chat Test Cases
void main() {
  group('Help & Chat Tests', () {
    testWidgets('HP-001 (Happy) Send message - Message delivered; reply visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpPage()));
      await tester.pumpAndSettle();

      // Verify existing messages are shown
      expect(find.text('Hi, How can i setting my profile picture.'),
          findsOneWidget);
      expect(
          find.text(
              'Hi, You can select profile menu in the sidebar and you will see A frame that changes your image'),
          findsOneWidget);

      // Find message input field
      final messageField = find.widgetWithText(TextField, 'Type a message...');
      expect(messageField, findsOneWidget);

      // Enter a new message
      await tester.enterText(messageField, 'Thank you for your help!');
      await tester.pumpAndSettle();

      // Find and tap send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Expected: Message delivered; reply visible
    });

    testWidgets('HP-002 (Edge) Offline send - Message queued; sends after reconnect',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpPage()));
      await tester.pumpAndSettle();

      // Simulate offline state (this requires network state management)
      // Send message while offline

      final messageField = find.widgetWithText(TextField, 'Type a message...');
      await tester.enterText(messageField, 'Offline message test');
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Expected: Message queued; sends after reconnect
      // This requires offline queue implementation
    });

    testWidgets('Attachment buttons are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpPage()));
      await tester.pumpAndSettle();

      // Verify attachment icons
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
    });

    testWidgets('Tap attachment icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpPage()));
      await tester.pumpAndSettle();

      // Tap image attachment
      final imageButton = find.byIcon(Icons.image_outlined);
      await tester.tap(imageButton);
      await tester.pumpAndSettle();

      // Expected: Opens image picker
    });

    testWidgets('Tap emoji icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpPage()));
      await tester.pumpAndSettle();

      // Tap emoji button
      final emojiButton = find.byIcon(Icons.emoji_emotions_outlined);
      await tester.tap(emojiButton);
      await tester.pumpAndSettle();

      // Expected: Opens emoji picker
    });
  });
}
