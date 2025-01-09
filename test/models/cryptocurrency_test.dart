import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_portfolio_tracker/models/cryptocurrency.dart';
import '../helpers/mock_data.dart';

void main() {
  group('Cryptocurrency', () {
    test('should create instance with correct values', () {
      final crypto = MockData.getSampleCryptocurrency();
      
      expect(crypto.id, equals('btc-bitcoin'));
      expect(crypto.name, equals('Bitcoin'));
      expect(crypto.symbol, equals('BTC'));
      expect(crypto.price, equals(50000.0));
      expect(crypto.percentChange24h, equals(5.0));
      expect(crypto.marketCap, equals(1000000000000.0));
      expect(crypto.volume24h, equals(50000000000.0));
      expect(crypto.rank, equals(1));
      expect(crypto.amount, equals(1.0));
    });

    test('should create from JSON correctly', () {
      final json = MockData.getCryptoJson();
      final crypto = Cryptocurrency.fromJson(json);
      
      expect(crypto.id, equals('btc-bitcoin'));
      expect(crypto.name, equals('Bitcoin'));
      expect(crypto.symbol, equals('BTC'));
      expect(crypto.price, equals(50000.0));
      expect(crypto.percentChange24h, equals(5.0));
      expect(crypto.marketCap, equals(1000000000000.0));
      expect(crypto.volume24h, equals(50000000000.0));
      expect(crypto.rank, equals(1));
      expect(crypto.amount, equals(0.0)); // Default amount
    });

    test('should calculate value correctly', () {
      final crypto = MockData.getSampleCryptocurrency();
      expect(crypto.value, equals(50000.0)); // price * amount = 50000 * 1
    });

    test('should create copy with updated values', () {
      final crypto = MockData.getSampleCryptocurrency();
      final updated = crypto.copyWith(
        amount: 2.0,
        price: 60000.0,
      );
      
      expect(updated.amount, equals(2.0));
      expect(updated.price, equals(60000.0));
      expect(updated.id, equals(crypto.id)); // Should keep original values
      expect(updated.name, equals(crypto.name));
    });
  });
}
