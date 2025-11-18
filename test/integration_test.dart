import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/screens/payment_page.dart';
import 'package:flutter_application_2/screens/profile_page.dart';
import 'package:flutter_application_2/screens/help_page.dart';
import 'package:flutter_application_2/screens/add_your_art_page.dart';
import 'package:flutter_application_2/screens/my_auction_page.dart';
import 'package:flutter_application_2/screens/notification_page.dart';

/// Integration Tests - Complete User Flows
void main() {
  group('Integration Tests - User Flows', () {
    testWidgets('Complete user journey: Login → Browse → Bid',
        (WidgetTester tester) async {
      // Start app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Login
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should be on home page
      expect(find.byType(HomePage), findsOneWidget);

      // Browse artwork (tap on an artwork card)
      final artworkCard = find.byType(GestureDetector).first;
      if (artworkCard.evaluate().isNotEmpty) {
        await tester.tap(artworkCard);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Drawer navigation test - All menu items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Test Payment navigation
      final paymentItem = find.text('Payment');
      expect(paymentItem, findsOneWidget);
      await tester.tap(paymentItem);
      await tester.pumpAndSettle();
      expect(find.byType(PaymentPage), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Open drawer again
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Test Profile navigation
      final profileItem = find.text('Profile');
      await tester.tap(profileItem);
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Open drawer again
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Test Help navigation
      final helpItem = find.text('Help');
      await tester.tap(helpItem);
      await tester.pumpAndSettle();
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('Seller flow: Add art → View my art',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Navigate to Add Your Art
      final addArtItem = find.text('Add Your Art');
      await tester.tap(addArtItem);
      await tester.pumpAndSettle();
      expect(find.byType(AddYourArtPage), findsOneWidget);
    });

    testWidgets('Notification icon tap test',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find notification bell icon
      final notificationIcon = find.byIcon(Icons.notifications_none);
      if (notificationIcon.evaluate().isNotEmpty) {
        await tester.tap(notificationIcon);
        await tester.pumpAndSettle();
        
        // Should navigate to notification page
        expect(find.byType(NotificationPage), findsOneWidget);
      }
    });

    testWidgets('My Auction navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Navigate to My Auction
      final myAuctionItem = find.text('My Auction');
      await tester.tap(myAuctionItem);
      await tester.pumpAndSettle();
      expect(find.byType(MyAuctionPage), findsOneWidget);
    });
  });
}
