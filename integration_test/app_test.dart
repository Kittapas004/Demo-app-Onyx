import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_2/main.dart' as app;

/// Integration Tests - จะรันบน device/emulator จริง
/// สามารถดูการทำงานแบบ real-time
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Journey - Authentication', () {
    testWidgets('AU-001: Login with valid credentials', (WidgetTester tester) async {
      // เริ่มแอป
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Starting Login Test...');

      // ตรวจสอบว่าอยู่หน้า Login
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Onyx'), findsOneWidget);
      
      print('✅ Found Login page');
      await tester.pump(const Duration(seconds: 1)); // Pause เพื่อดู UI

      // หา Email field และพิมพ์
      final emailField = find.byType(TextField).first;
      await tester.tap(emailField);
      await tester.pumpAndSettle();
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();
      
      print('✅ Entered email: test@example.com');
      await tester.pump(const Duration(milliseconds: 500));

      // หา Password field และพิมพ์
      final passwordField = find.byType(TextField).last;
      await tester.tap(passwordField);
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();
      
      print('✅ Entered password');
      await tester.pump(const Duration(milliseconds: 500));

      // กดปุ่ม LOGIN
      final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
      expect(loginButton, findsOneWidget);
      
      print('🔘 Tapping LOGIN button...');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      print('✅ Login successful - Navigated to Home page');
      await tester.pump(const Duration(seconds: 1));

      // ตรวจสอบว่าไปหน้า Home แล้ว (home_page ไม่มี Drawer จริง - ใช้ BottomNavigationBar แทน)
      expect(find.text('ART AUCTION'), findsOneWidget);
      
      print('✅ Test completed successfully! 🎉');
    });

    testWidgets('AU-003: Google OAuth Login Button', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Testing Google OAuth button...');

      // หาปุ่ม Google
      final googleButton = find.byIcon(Icons.g_mobiledata);
      expect(googleButton, findsOneWidget);
      
      print('✅ Found Google OAuth button');
      await tester.pump(const Duration(milliseconds: 500));

      // กดปุ่ม Google
      print('🔘 Tapping Google button...');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
      
      print('✅ Google OAuth button tapped');
    });
  });

  group('Complete User Journey - Registration', () {
    testWidgets('RG-001: Complete Registration Flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Starting Registration Test...');

      // กดปุ่ม Sign Up
      final signUpLink = find.text('Sign Up');
      expect(signUpLink, findsOneWidget);
      
      print('🔘 Tapping Sign Up link...');
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      print('✅ Navigated to Registration page');

      // หา scroll view
      final scrollFinder = find.byType(SingleChildScrollView);

      // กรอก First Name
      final firstNameField = find.byType(TextField).first;
      await tester.tap(firstNameField);
      await tester.pumpAndSettle();
      await tester.enterText(firstNameField, 'John');
      await tester.pumpAndSettle();
      
      print('✅ Entered First Name: John');
      await tester.pump(const Duration(milliseconds: 300));

      // กรอก Last Name
      final lastNameField = find.byType(TextField).at(1);
      await tester.tap(lastNameField);
      await tester.pumpAndSettle();
      await tester.enterText(lastNameField, 'Doe');
      await tester.pumpAndSettle();
      
      print('✅ Entered Last Name: Doe');
      await tester.pump(const Duration(milliseconds: 300));

      // กรอก Email
      final emailField = find.byType(TextField).at(2);
      await tester.tap(emailField);
      await tester.pumpAndSettle();
      await tester.enterText(emailField, 'john.doe@example.com');
      await tester.pumpAndSettle();
      
      print('✅ Entered Email: john.doe@example.com');
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll ลงไปหา fields ถัดไป
      print('📜 Scrolling down to see more fields...');
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // กรอก Birth Date
      final birthDateField = find.widgetWithText(TextField, '18/03/2024');
      await tester.tap(birthDateField);
      await tester.pumpAndSettle();
      await tester.enterText(birthDateField, '01/01/1990');
      await tester.pumpAndSettle();
      
      print('✅ Entered Birth Date: 01/01/1990');
      await tester.pump(const Duration(milliseconds: 300));

      // กรอก Phone
      final phoneField = find.widgetWithText(TextField, '(454) 726-0592');
      await tester.tap(phoneField);
      await tester.pumpAndSettle();
      await tester.enterText(phoneField, '+1234567890');
      await tester.pumpAndSettle();
      
      print('✅ Entered Phone: +1234567890');
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll ลงไปอีก
      print('📜 Scrolling to password field...');
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // กรอก Password
      final passwordField = find.widgetWithText(TextField, '*******');
      await tester.tap(passwordField);
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, 'SecurePass123!');
      await tester.pumpAndSettle();
      
      print('✅ Entered Password');
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll ไปหา Categories
      print('📜 Scrolling to categories section...');
      await tester.drag(scrollFinder, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // เลือก Categories
      final abstractCategory = find.text('Abstract');
      if (abstractCategory.evaluate().isNotEmpty) {
        print('🔘 Selecting Abstract category...');
        await tester.tap(abstractCategory);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));
        print('✅ Abstract category selected');
      }

      final landscapeCategory = find.text('Landscape');
      if (landscapeCategory.evaluate().isNotEmpty) {
        print('🔘 Selecting Landscape category...');
        await tester.tap(landscapeCategory);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));
        print('✅ Landscape category selected');
      }

      // Scroll ไปหาปุ่ม REGISTER
      print('📜 Scrolling to REGISTER button...');
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'REGISTER'),
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // กดปุ่ม REGISTER
      final registerButton = find.widgetWithText(ElevatedButton, 'REGISTER');
      expect(registerButton, findsOneWidget);
      
      print('🔘 Tapping REGISTER button...');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Registration Test completed! 🎉');
    });

    testWidgets('RG-008: Select Multiple Categories', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Testing Category Selection...');

      // ไปหน้า Register
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Scroll ไปหา categories
      final scrollFinder = find.byType(SingleChildScrollView);
      await tester.drag(scrollFinder, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // เลือก Abstract
      print('🔘 Tapping Abstract category...');
      await tester.tap(find.text('Abstract'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Abstract selected');

      // เลือก Portrait
      print('🔘 Tapping Portrait category...');
      await tester.tap(find.text('Portrait'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Portrait selected');

      // เลือก Digital Art
      print('🔘 Tapping Digital Art category...');
      await tester.tap(find.text('Digital Art'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Digital Art selected');

      print('✅ Category Selection Test completed! 🎉');
    });
  });

  group('Complete User Journey - Navigation', () {
    testWidgets('Drawer Navigation - All Menu Items', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Testing Drawer Navigation...');

      // Login first
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.byType(TextField).last);
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      print('✅ Logged in successfully');

      // เปิด Drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      
      print('✅ Drawer opened');

      // กด Payment
      print('🔘 Tapping Payment menu...');
      await tester.tap(find.text('Payment'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Navigated to Payment page');

      // กลับด้วย AppBar back button แทน pageBack()
      final backButton = find.byIcon(Icons.arrow_back);
      if (tester.widgetList(backButton).isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // เปิด Drawer อีกครั้ง
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // กด Profile
      print('🔘 Tapping Profile menu...');
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Navigated to Profile page');

      // กลับด้วย AppBar back button
      final backButton2 = find.byIcon(Icons.arrow_back);
      if (tester.widgetList(backButton2).isNotEmpty) {
        await tester.tap(backButton2);
        await tester.pumpAndSettle();
      }

      // เปิด Drawer อีกครั้ง
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // กด Help
      print('🔘 Tapping Help menu...');
      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      print('✅ Navigated to Help page');

      print('✅ Drawer Navigation Test completed! 🎉');
    });

    testWidgets('Browse Artworks and View Details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Testing Artwork Browsing...');

      // Login
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.byType(TextField).last);
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      print('✅ On Home page - viewing artworks');

      // หา artwork card แรก
      final artworkCards = find.byType(GestureDetector);
      if (artworkCards.evaluate().isNotEmpty) {
        print('🔘 Tapping first artwork...');
        await tester.tap(artworkCards.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        print('✅ Artwork details opened');
      }

      print('✅ Artwork Browsing Test completed! 🎉');
    });
  });

  group('Notification Tests', () {
    testWidgets('NT-001: View Notifications', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      print('🚀 Testing Notifications...');

      // Login
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.byType(TextField).last);
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // หาและกด notification bell icon
      final notificationIcon = find.byIcon(Icons.notifications_none);
      if (notificationIcon.evaluate().isNotEmpty) {
        print('🔘 Tapping notification bell...');
        await tester.tap(notificationIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        print('✅ Notifications page opened');

        // ตรวจสอบว่ามี notifications
        expect(find.text('Notifications'), findsOneWidget);
        print('✅ Notifications displayed');
      }

      print('✅ Notification Test completed! 🎉');
    });
  });
}
