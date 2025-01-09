import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio.dart';

class StorageService {
  static const String _portfoliosKey = 'portfolios';

  Future<void> savePortfolios(List<Portfolio> portfolios) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfoliosJson = portfolios.map((portfolio) => portfolio.toJson()).toList();
      await prefs.setString(_portfoliosKey, jsonEncode(portfoliosJson));
    } catch (e) {
      print('Error saving portfolios: $e');
      rethrow;
    }
  }

  Future<List<Portfolio>> loadPortfolios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfoliosJson = prefs.getString(_portfoliosKey);
      if (portfoliosJson != null) {
        final List<dynamic> decoded = jsonDecode(portfoliosJson);
        return decoded.map((json) => Portfolio.fromJson(json)).toList();
      }
      return [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
    } catch (e) {
      print('Error loading portfolios: $e');
      return [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
    }
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
