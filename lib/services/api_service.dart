import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/cryptocurrency.dart';
import '../models/api_source.dart';
import '../models/candle_data.dart';
import 'chart_cache.dart';

class ApiService {
  final http.Client _client;
  ApiSource currentSource = ApiSource.coingecko;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 3);

  ApiService() : _client = http.Client();

  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts == maxRetries) {
          rethrow;
        }
        print('Request failed, attempt $attempts of $maxRetries. Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }

  Future<List<Cryptocurrency>> fetchCryptoData() async {
    try {
      switch (currentSource) {
        case ApiSource.coinpaprika:
          return await _fetchFromCoinpaprika();
        case ApiSource.coincap:
          return await _fetchFromCoinCap();
        case ApiSource.coingecko:
          return await _fetchFromCoinGecko();
      }
    } catch (e) {
      print('Error fetching data from ${currentSource.displayName}: $e');
      return [];
    }
  }

  Future<List<Cryptocurrency>> _fetchFromCoinpaprika() async {
    return _retryRequest(() async {
      try {
        final response = await _client.get(Uri.parse('${ApiSource.coinpaprika.baseUrl}/tickers'), headers: {
          'Accept': 'application/json',
        });

        if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please try again later.');
        }

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

        throw Exception('Failed to load crypto data from Coinpaprika: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print('Error fetching data from Coinpaprika: $e');
        rethrow;
      }
    });
  }

  Future<List<Cryptocurrency>> _fetchFromCoinCap() async {
    return _retryRequest(() async {
      try {
        final response = await _client.get(Uri.parse('${ApiSource.coincap.baseUrl}/assets'), headers: {
          'Accept': 'application/json',
        });

        if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please try again later.');
        }

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

        throw Exception('Failed to load crypto data from CoinCap: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print('Error fetching data from CoinCap: $e');
        rethrow;
      }
    });
  }

  Future<List<Cryptocurrency>> _fetchFromCoinGecko() async {
    return _retryRequest(() async {
      try {
        final response = await _client.get(
          Uri.parse('${ApiSource.coingecko.baseUrl}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&sparkline=false'),
          headers: {
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please try again later.');
        }

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

        throw Exception('Failed to load crypto data from CoinGecko: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print('Error fetching data from CoinGecko: $e');
        rethrow;
      }
    });
  }

  int _getDaysFromInterval(String interval) {
    switch (interval) {
      case '1h':
        return 1;
      case '1d':
        return 1;
      case '1w':
        return 7;
      case '1m':
        return 30;
      default:
        return 1;
    }
  }

  Future<List<CandleData>> getCandleData(String id, {String interval = '1d'}) async {
    // Check cache first
    final cachedData = ChartCache.getCachedData(id, interval);
    if (cachedData != null) {
      print('Returning cached data for $id ($interval)');
      return cachedData;
    }

    return _retryRequest(() async {
      try {
        final days = _getDaysFromInterval(interval);
        final uri = Uri.parse('${ApiSource.coingecko.baseUrl}/coins/$id/ohlc?vs_currency=usd&days=$days');
        
        final response = await _client.get(uri, headers: {
          'Accept': 'application/json',
        });

        if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please try again later.');
        }

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          
          if (data.isEmpty) {
            throw Exception('No data available');
          }

          final candles = data.map((item) {
            if (item is! List || item.length < 5) {
              throw Exception('Invalid data format');
            }

            final timestamp = item[0] as int;
            final open = (item[1] as num).toDouble();
            final high = (item[2] as num).toDouble();
            final low = (item[3] as num).toDouble();
            final close = (item[4] as num).toDouble();

            // Basic validation
            if (high < low || open <= 0 || close <= 0) {
              print('Warning: Invalid candle data: $item');
              // Return a valid candle with the close price
              return CandleData(
                date: DateTime.fromMillisecondsSinceEpoch(timestamp),
                open: close,
                high: close,
                low: close,
                close: close,
                volume: 0,
              );
            }

            return CandleData(
              date: DateTime.fromMillisecondsSinceEpoch(timestamp),
              open: open,
              high: high,
              low: low,
              close: close,
              volume: 0,
            );
          }).toList();

          // Sort by date
          candles.sort((a, b) => a.date.compareTo(b.date));
          
          // Cache the data before returning
          ChartCache.cacheData(id, interval, candles);
          
          return candles;
        }

        throw Exception('Failed to fetch candle data: ${response.statusCode} - ${response.body}');
      } catch (e) {
        print('Error fetching candle data: $e');
        rethrow;
      }
    });
  }
}
