import 'package:flutter/material.dart';
import '../models/candle_data.dart';
import '../services/api_service.dart';
import '../models/api_source.dart';
import '../utils/coin_gecko_ids.dart';
import 'candlestick_painter.dart';

class CryptoChart extends StatefulWidget {
  final String symbol;
  final String name;
  final ApiService apiService;

  const CryptoChart({
    Key? key,
    required this.symbol,
    required this.name,
    required this.apiService,
  }) : super(key: key);

  @override
  State<CryptoChart> createState() => _CryptoChartState();
}

class _CryptoChartState extends State<CryptoChart> {
  bool isLoading = true;
  String error = '';
  List<CandleData> candles = [];
  String currentInterval = '1d';
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      String symbolOrId = widget.symbol;
      if (widget.apiService.currentSource == ApiSource.coingecko) {
        symbolOrId = coinGeckoIds[widget.symbol] ?? widget.symbol.toLowerCase();
        if (!coinGeckoIds.containsKey(widget.symbol)) {
          print('Warning: No CoinGecko ID mapping found for ${widget.symbol}, using lowercase symbol');
        }
      }

      final response = await widget.apiService.getCandleData(
        symbolOrId,
        interval: currentInterval,
      );

      // Validate and filter the data
      final validCandles = response.where((data) => 
        data.high > 0 && 
        data.low > 0 && 
        data.open > 0 && 
        data.close > 0 &&
        data.high >= data.low
      ).toList();

      if (validCandles.isEmpty) {
        throw Exception('No valid price data available');
      }

      // Sort candles by date and calculate price range
      validCandles.sort((a, b) => a.date.compareTo(b.date));
      final prices = validCandles.expand((c) => [c.high, c.low]).toList();
      final min = prices.reduce((a, b) => a < b ? a : b);
      final max = prices.reduce((a, b) => a > b ? a : b);
      final padding = (max - min) * 0.1;

      setState(() {
        candles = validCandles;
        minPrice = min - padding;
        maxPrice = max + padding;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _intervalButton(String interval) {
    final isSelected = interval == currentInterval;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          if (interval != currentInterval) {
            setState(() {
              currentInterval = interval;
            });
            fetchData();
          }
        },
        child: Text(interval.toUpperCase(), style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (candles.isEmpty || minPrice == null || maxPrice == null) {
          return const Center(child: Text('No price data available'));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                _intervalButton('1h'),
                _intervalButton('1d'),
                _intervalButton('1w'),
                _intervalButton('1m'),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRect(
                  child: CustomPaint(
                    painter: CandlestickPainter(
                      candles: candles,
                      minPrice: minPrice!,
                      maxPrice: maxPrice!,
                      upColor: Colors.green.shade400,
                      downColor: Colors.red.shade400,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
