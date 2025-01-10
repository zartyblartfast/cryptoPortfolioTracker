import 'package:flutter/material.dart';
import '../models/candle_data.dart';

class CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final double minPrice;
  final double maxPrice;
  final Color upColor;
  final Color downColor;
  static const int numPriceLabels = 5;
  static const int numTimeLabels = 5;

  CandlestickPainter({
    required this.candles,
    required this.minPrice,
    required this.maxPrice,
    this.upColor = Colors.green,
    this.downColor = Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || size.width == 0 || size.height == 0) return;

    // Add more padding for top axis
    final chartAreaWidth = size.width * 0.85; // More space for price labels
    final chartAreaHeight = size.height * 0.85; // More space for time labels
    final chartLeft = size.width * 0.15; // More space for price labels
    final chartTop = size.height * 0.1; // Space for top axis

    // Draw price axis labels and grid lines
    final priceRange = maxPrice - minPrice;
    if (priceRange <= 0) return;

    final priceStep = priceRange / (numPriceLabels - 1);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Draw horizontal grid lines and price labels
    for (var i = 0; i < numPriceLabels; i++) {
      final price = minPrice + (priceStep * i);
      final y = chartTop + chartAreaHeight - (i * chartAreaHeight / (numPriceLabels - 1));

      // Draw grid line
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 0.5,
      );

      // Draw price label
      textPainter.text = TextSpan(
        text: '\$${price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(2, y - textPainter.height / 2),
      );
    }

    // Draw time axis labels and vertical grid lines
    final timeStep = candles.length ~/ (numTimeLabels - 1);
    for (var i = 0; i < numTimeLabels; i++) {
      if (i * timeStep >= candles.length) break;
      
      final candleIndex = i * timeStep;
      final x = chartLeft + (candleIndex * chartAreaWidth / (candles.length - 1));
      final date = candles[candleIndex].date;

      // Draw grid line
      canvas.drawLine(
        Offset(x, chartTop),
        Offset(x, chartTop + chartAreaHeight),
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 0.5,
      );

      // Draw time label
      textPainter.text = TextSpan(
        text: '${date.month}/${date.day}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartTop + chartAreaHeight + 4),
      );
    }

    // Draw candlesticks
    final candleWidth = (chartAreaWidth / candles.length) * 0.8;
    final spacing = (chartAreaWidth / candles.length) * 0.2;

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = chartLeft + i * (candleWidth + spacing) + spacing / 2;

      // Convert prices to y-coordinates
      final high = chartTop + chartAreaHeight - ((candle.high - minPrice) / priceRange * chartAreaHeight);
      final low = chartTop + chartAreaHeight - ((candle.low - minPrice) / priceRange * chartAreaHeight);
      final open = chartTop + chartAreaHeight - ((candle.open - minPrice) / priceRange * chartAreaHeight);
      final close = chartTop + chartAreaHeight - ((candle.close - minPrice) / priceRange * chartAreaHeight);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = candle.close >= candle.open ? upColor : downColor;

      // Draw the wick
      canvas.drawLine(
        Offset(x + candleWidth / 2, high),
        Offset(x + candleWidth / 2, low),
        paint,
      );

      // Draw the body
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromPoints(
          Offset(x, open),
          Offset(x + candleWidth, close),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.minPrice != minPrice ||
        oldDelegate.maxPrice != maxPrice;
  }
}
