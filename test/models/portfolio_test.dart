import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_portfolio_tracker/models/portfolio.dart';
import 'package:crypto_portfolio_tracker/models/cryptocurrency.dart';
import '../helpers/mock_data.dart';

void main() {
  group('Portfolio', () {
    test('should create instance with correct values', () {
      final crypto = MockData.getSampleCryptocurrency();
      final portfolio = Portfolio(
        name: 'Test Portfolio',
        cryptocurrencies: [crypto],
      );

      expect(portfolio.name, equals('Test Portfolio'));
      expect(portfolio.cryptocurrencies.length, equals(1));
      expect(portfolio.cryptocurrencies.first.name, equals('Bitcoin'));
    });

    test('should calculate total value correctly', () {
      final crypto1 = MockData.getSampleCryptocurrency(); // Value: 50000 (price) * 1 (amount)
      final crypto2 = Cryptocurrency(
        id: 'eth-ethereum',
        name: 'Ethereum',
        symbol: 'ETH',
        price: 3000.0,
        percentChange24h: 2.0,
        marketCap: 350000000000.0,
        volume24h: 20000000000.0,
        rank: 2,
        amount: 2.0, // Value: 3000 * 2 = 6000
      );

      final portfolio = Portfolio(
        name: 'Test Portfolio',
        cryptocurrencies: [crypto1, crypto2],
      );

      expect(portfolio.totalValue, equals(56000.0)); // 50000 + 6000
    });

    test('should serialize to JSON correctly', () {
      final crypto = MockData.getSampleCryptocurrency();
      final portfolio = Portfolio(
        name: 'Test Portfolio',
        cryptocurrencies: [crypto],
      );

      final json = portfolio.toJson();

      expect(json['name'], equals('Test Portfolio'));
      expect(json['cryptocurrencies'], isList);
      expect(json['cryptocurrencies'].length, equals(1));
      expect(json['cryptocurrencies'][0]['name'], equals('Bitcoin'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'name': 'Test Portfolio',
        'cryptocurrencies': [
          {
            'id': 'btc-bitcoin',
            'name': 'Bitcoin',
            'symbol': 'BTC',
            'price': 50000.0,
            'percentChange24h': 5.0,
            'marketCap': 1000000000000.0,
            'volume24h': 50000000000.0,
            'rank': 1,
            'amount': 1.0,
          }
        ]
      };

      final portfolio = Portfolio.fromJson(json);

      expect(portfolio.name, equals('Test Portfolio'));
      expect(portfolio.cryptocurrencies.length, equals(1));
      expect(portfolio.cryptocurrencies[0].name, equals('Bitcoin'));
      expect(portfolio.cryptocurrencies[0].amount, equals(1.0));
    });

    test('should create copy with updated values', () {
      final crypto = MockData.getSampleCryptocurrency();
      final portfolio = Portfolio(
        name: 'Test Portfolio',
        cryptocurrencies: [crypto],
      );

      final newCrypto = Cryptocurrency(
        id: 'eth-ethereum',
        name: 'Ethereum',
        symbol: 'ETH',
        price: 3000.0,
        percentChange24h: 2.0,
        marketCap: 350000000000.0,
        volume24h: 20000000000.0,
        rank: 2,
        amount: 1.0,
      );

      final updated = portfolio.copyWith(
        name: 'New Name',
        cryptocurrencies: [newCrypto],
      );

      expect(updated.name, equals('New Name'));
      expect(updated.cryptocurrencies.length, equals(1));
      expect(updated.cryptocurrencies[0].name, equals('Ethereum'));
      expect(portfolio.name, equals('Test Portfolio')); // Original unchanged
    });
  });
}
