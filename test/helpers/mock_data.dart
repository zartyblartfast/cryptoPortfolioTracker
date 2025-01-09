import 'package:crypto_portfolio_tracker/models/cryptocurrency.dart';

class MockData {
  static Map<String, dynamic> getCryptoJson() {
    return {
      'id': 'btc-bitcoin',
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'quotes': {
        'USD': {
          'price': 50000.0,
          'percent_change_24h': 5.0,
          'market_cap': 1000000000000.0,
          'volume_24h': 50000000000.0,
        }
      },
      'rank': 1,
    };
  }

  static Cryptocurrency getSampleCryptocurrency() {
    return Cryptocurrency(
      id: 'btc-bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 50000.0,
      percentChange24h: 5.0,
      marketCap: 1000000000000.0,
      volume24h: 50000000000.0,
      rank: 1,
      amount: 1.0,
    );
  }
}
