class CandleData {
  final DateTime date;
  final double high;
  final double low;
  final double open;
  final double close;
  final double volume;

  CandleData({
    required this.date,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.volume,
  });

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      date: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      open: (json['open'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': date.millisecondsSinceEpoch,
      'high': high,
      'low': low,
      'open': open,
      'close': close,
      'volume': volume,
    };
  }
}
