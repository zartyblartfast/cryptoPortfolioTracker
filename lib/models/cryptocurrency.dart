import 'package:flutter/foundation.dart';

class Cryptocurrency {
  final String id;
  final String name;
  final String symbol;
  double price;
  double percentChange24h;
  double marketCap;
  double volume24h;
  int rank;
  double amount;

  Cryptocurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.percentChange24h,
    required this.marketCap,
    required this.volume24h,
    required this.rank,
    this.amount = 0,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    final quotes = json['quotes']['USD'];
    return Cryptocurrency(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      price: quotes['price'] ?? 0.0,
      percentChange24h: quotes['percent_change_24h'] ?? 0.0,
      marketCap: quotes['market_cap'] ?? 0.0,
      volume24h: quotes['volume_24h'] ?? 0.0,
      rank: json['rank'] ?? 0,
    );
  }

  double get value => price * amount;

  Cryptocurrency copyWith({
    double? amount,
    double? price,
    double? percentChange24h,
    double? marketCap,
    double? volume24h,
    int? rank,
  }) {
    return Cryptocurrency(
      id: id,
      name: name,
      symbol: symbol,
      price: price ?? this.price,
      percentChange24h: percentChange24h ?? this.percentChange24h,
      marketCap: marketCap ?? this.marketCap,
      volume24h: volume24h ?? this.volume24h,
      rank: rank ?? this.rank,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cryptocurrency &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
