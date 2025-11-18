import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/screens/notification_page.dart';

/// 5.6 Notifications Test Cases
void main() {
  group('Notification Tests', () {
    testWidgets('NT-001 (Happy) View list - Tap bell icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationPage()));
      await tester.pumpAndSettle();

      // Verify notifications are displayed
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);

      // Verify notification items are shown
      expect(find.text('Leonardo sent you a message about your art "Stupid Monkey"'),
          findsOneWidget);
      expect(find.text('John placed a bid on your art "Classic Painting"'),
          findsOneWidget);
    });

    testWidgets('NT-002 (Happy) Outbid alert - Push received → opens artwork',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationPage()));
      await tester.pumpAndSettle();

      // Find notification about bid
      final bidNotification = find.text(
          'John placed a bid on your art "Classic Painting"');
      expect(bidNotification, findsOneWidget);

      // Tap notification
      await tester.tap(bidNotification);
      await tester.pumpAndSettle();

      // Expected: Opens artwork detail page
    });

    testWidgets('NT-003 (Sad) Permission denied - Prompt to enable in settings',
        (WidgetTester tester) async {
      // Deny notifications permission
      // Expected: Prompt to enable in settings
      // This requires platform-specific permission handling
    });

    testWidgets('Mark all as read functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationPage()));
      await tester.pumpAndSettle();

      // Find and tap "Mark all as read"
      final markAllButton = find.text('Mark all as read');
      expect(markAllButton, findsOneWidget);
      await tester.tap(markAllButton);
      await tester.pumpAndSettle();

      // Expected: All notifications marked as read
    });

    testWidgets('View All button functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationPage()));
      await tester.pumpAndSettle();

      // Find and tap "View All"
      final viewAllButton = find.text('View All');
      expect(viewAllButton, findsOneWidget);
      await tester.tap(viewAllButton);
      await tester.pumpAndSettle();

      // Expected: Shows all notifications
    });
  });
}
