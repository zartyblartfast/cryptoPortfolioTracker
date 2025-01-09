import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cryptocurrency.dart';
import '../models/api_source.dart';

class ApiService {
  final http.Client client;
  ApiSource _currentSource;

  ApiService({
    http.Client? client,
    ApiSource initialSource = ApiSource.coinpaprika,
  })  : client = client ?? http.Client(),
        _currentSource = initialSource;

  ApiSource get currentSource => _currentSource;
  set currentSource(ApiSource source) {
    _currentSource = source;
  }

  Future<List<Cryptocurrency>> fetchCryptoData() async {
    try {
      switch (_currentSource) {
        case ApiSource.coinpaprika:
          return await _fetchFromCoinpaprika();
        case ApiSource.coincap:
          return await _fetchFromCoinCap();
        case ApiSource.coingecko:
          return await _fetchFromCoinGecko();
      }
    } catch (e) {
      print('Error fetching data from ${_currentSource.displayName}: $e');
      return [];
    }
  }

  Future<List<Cryptocurrency>> _fetchFromCoinpaprika() async {
    final response = await client.get(Uri.parse('${ApiSource.coinpaprika.baseUrl}/tickers'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) {
        return Cryptocurrency(
          id: data['id'],
          name: data['name'],
          symbol: data['symbol'],
          price: double.parse(data['quotes']['USD']['price'].toString()),
          percentChange24h: double.parse(data['quotes']['USD']['percent_change_24h'].toString()),
          marketCap: double.parse(data['quotes']['USD']['market_cap'].toString()),
          volume24h: double.parse(data['quotes']['USD']['volume_24h'].toString()),
          rank: data['rank'],
        );
      }).toList();
    }
    throw Exception('Failed to load crypto data from Coinpaprika');
  }

  Future<List<Cryptocurrency>> _fetchFromCoinCap() async {
    final response = await client.get(Uri.parse('${ApiSource.coincap.baseUrl}/assets'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((item) {
        return Cryptocurrency(
          id: item['id'],
          name: item['name'],
          symbol: item['symbol'],
          price: double.parse(item['priceUsd']),
          percentChange24h: double.parse(item['changePercent24Hr']),
          marketCap: double.parse(item['marketCapUsd']),
          volume24h: double.parse(item['volumeUsd24Hr']),
          rank: int.parse(item['rank']),
        );
      }).toList();
    }
    throw Exception('Failed to load crypto data from CoinCap');
  }

  Future<List<Cryptocurrency>> _fetchFromCoinGecko() async {
    final response = await client.get(
      Uri.parse('${ApiSource.coingecko.baseUrl}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&sparkline=false')
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return Cryptocurrency(
          id: item['id'],
          name: item['name'],
          symbol: item['symbol'].toUpperCase(),
          price: item['current_price'].toDouble(),
          percentChange24h: item['price_change_percentage_24h'] ?? 0.0,
          marketCap: item['market_cap'].toDouble(),
          volume24h: item['total_volume'].toDouble(),
          rank: item['market_cap_rank'] ?? 0,
        );
      }).toList();
    }
    throw Exception('Failed to load crypto data from CoinGecko');
  }
}
