// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_portfolio_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:crypto_portfolio_tracker/services/api_service.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'widget_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() async {
    // Initialize SharedPreferences
    SharedPreferences.setMockInitialValues({});
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);

    // Mock the HTTP response
    when(mockClient.get(Uri.parse('https://api.coincap.io/v2/assets')))
        .thenAnswer((_) async => http.Response(
              '{"data": []}',
              200,
            ));
  });

  testWidgets('App should render with correct title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CryptoPortfolioApp());
    
    // Wait for the first frame
    await tester.pump();

    // Verify that the app title is displayed
    expect(find.text('Crypto Portfolio Tracker'), findsOneWidget);

    // Verify that we have two tabs
    expect(find.text('Cryptocurrencies'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
  });

  testWidgets('Search field should be present after loading', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CryptoPortfolioApp());
    
    // Wait for loading to complete
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify that the search field is present
    expect(find.byType(TextField), findsOneWidget);
  });
}
