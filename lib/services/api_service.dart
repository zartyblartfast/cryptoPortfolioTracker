import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cryptocurrency.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Cryptocurrency>> fetchCryptoData() async {
    try {
      final response = await client.get(
        Uri.parse('https://api.coincap.io/v2/assets'),
      );

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
      throw Exception('Failed to load crypto data');
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}
