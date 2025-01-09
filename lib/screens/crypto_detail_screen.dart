import 'package:flutter/material.dart';
import '../models/cryptocurrency.dart';

class CryptoDetailScreen extends StatelessWidget {
  final Cryptocurrency crypto;
  final Function(Cryptocurrency) addToPortfolio;

  const CryptoDetailScreen({
    Key? key,
    required this.crypto,
    required this.addToPortfolio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crypto.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symbol: ${crypto.symbol}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Price: \$${crypto.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('24h Change: ${crypto.percentChange24h.toStringAsFixed(2)}%', 
              style: TextStyle(
                color: crypto.percentChange24h >= 0 ? Colors.green : Colors.red,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text('Market Cap: \$${crypto.marketCap.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('24h Volume: \$${crypto.volume24h.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Rank: ${crypto.rank}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => addToPortfolio(crypto),
              child: Text('Add to Portfolio'),
            ),
            // TODO: Add historical price chart here
          ],
        ),
      ),
    );
  }
}
