import '../models/candle_data.dart';

class ChartCache {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration cacheExpiry = Duration(minutes: 5);

  static String _getCacheKey(String id, String interval) => '$id-$interval';

  static void cacheData(String id, String interval, List<CandleData> data) {
    final key = _getCacheKey(id, interval);
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  static List<CandleData>? getCachedData(String id, String interval) {
    final key = _getCacheKey(id, interval);
    final entry = _cache[key];
    
    if (entry == null) return null;

    // Check if cache has expired
    if (DateTime.now().difference(entry.timestamp) > cacheExpiry) {
      _cache.remove(key);
      return null;
    }

    return entry.data;
  }

  static void clearCache() {
    _cache.clear();
  }
}

class CacheEntry {
  final List<CandleData> data;
  final DateTime timestamp;

  CacheEntry({
    required this.data,
    required this.timestamp,
  });
}
