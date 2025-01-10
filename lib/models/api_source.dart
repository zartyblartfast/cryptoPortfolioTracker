enum ApiSource {
  coinpaprika(
    displayName: 'Coinpaprika',
    baseUrl: 'https://api.coinpaprika.com/v1',
  ),
  coincap(
    displayName: 'CoinCap',
    baseUrl: 'https://api.coincap.io/v2',
  ),
  coingecko(
    displayName: 'CoinGecko',
    baseUrl: 'https://api.coingecko.com/api/v3',
  );

  final String displayName;
  final String baseUrl;

  const ApiSource({
    required this.displayName,
    required this.baseUrl,
  });
}
