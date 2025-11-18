import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'authentication_test.dart' as auth_tests;
import 'registration_test.dart' as registration_tests;
import 'auction_bidding_test.dart' as auction_tests;
import 'add_art_test.dart' as add_art_tests;
import 'payment_test.dart' as payment_tests;
import 'notification_test.dart' as notification_tests;
import 'help_chat_test.dart' as help_tests;
import 'integration_test.dart' as integration_tests;

/// Main Test Runner
/// Run all tests with: flutter test test/test_runner.dart
void main() {
  group('5.1 Authentication Tests', () {
    auth_tests.main();
  });

  group('5.2 Registration & KYC Tests', () {
    registration_tests.main();
  });

  group('5.3 Auction & Bidding Tests', () {
    auction_tests.main();
  });

  group('5.4 Add Your Art Tests', () {
    add_art_tests.main();
  });

  group('5.5 Payment Tests', () {
    payment_tests.main();
  });

  group('5.6 Notification Tests', () {
    notification_tests.main();
  });

  group('5.7 Help & Chat Tests', () {
    help_tests.main();
  });

  group('Integration Tests', () {
    integration_tests.main();
  });
}
