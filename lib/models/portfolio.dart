import 'cryptocurrency.dart';

class Portfolio {
  final String id;
  String name;
  List<Cryptocurrency> cryptocurrencies;

  Portfolio({
    String? id,
    required this.name,
    required this.cryptocurrencies,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get totalValue {
    return cryptocurrencies.fold(0, (sum, item) => sum + item.value);
  }

  // Serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'],
      cryptocurrencies: (json['cryptocurrencies'] as List<dynamic>).map((item) => Cryptocurrency(
        id: item['id'],
        name: item['name'],
        symbol: item['symbol'],
        price: item['price'].toDouble(),
        percentChange24h: item['percentChange24h'].toDouble(),
        marketCap: item['marketCap'].toDouble(),
        volume24h: item['volume24h'].toDouble(),
        rank: item['rank'],
        amount: item['amount'].toDouble(),
      )).toList(),
    );
  }

  // Utility methods
  Portfolio copyWith({
    String? name,
    List<Cryptocurrency>? cryptocurrencies,
  }) {
    return Portfolio(
      id: id,
      name: name ?? this.name,
      cryptocurrencies: cryptocurrencies ?? this.cryptocurrencies,
    );
  }
}
