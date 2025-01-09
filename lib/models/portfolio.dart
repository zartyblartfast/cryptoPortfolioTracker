import 'cryptocurrency.dart';

class Portfolio {
  String name;
  List<Cryptocurrency> cryptocurrencies;

  Portfolio({
    required this.name,
    required this.cryptocurrencies,
  });

  double get totalValue {
    return cryptocurrencies.fold(0, (sum, item) => sum + item.value);
  }

  // Serialization methods
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cryptocurrencies': cryptocurrencies.map((crypto) => {
        'id': crypto.id,
        'name': crypto.name,
        'symbol': crypto.symbol,
        'price': crypto.price,
        'percentChange24h': crypto.percentChange24h,
        'marketCap': crypto.marketCap,
        'volume24h': crypto.volume24h,
        'rank': crypto.rank,
        'amount': crypto.amount,
      }).toList(),
    };
  }

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      name: json['name'] as String,
      cryptocurrencies: (json['cryptocurrencies'] as List)
          .map((cryptoJson) => Cryptocurrency(
                id: cryptoJson['id'] as String,
                name: cryptoJson['name'] as String,
                symbol: cryptoJson['symbol'] as String,
                price: cryptoJson['price'] as double,
                percentChange24h: cryptoJson['percentChange24h'] as double,
                marketCap: cryptoJson['marketCap'] as double,
                volume24h: cryptoJson['volume24h'] as double,
                rank: cryptoJson['rank'] as int,
                amount: cryptoJson['amount'] as double,
              ))
          .toList(),
    );
  }

  // Utility methods
  Portfolio copyWith({
    String? name,
    List<Cryptocurrency>? cryptocurrencies,
  }) {
    return Portfolio(
      name: name ?? this.name,
      cryptocurrencies: cryptocurrencies ?? this.cryptocurrencies,
    );
  }
}
