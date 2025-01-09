enum ApiSource {
  coinpaprika,
  coincap,
  coingecko;

  String get displayName {
    switch (this) {
      case ApiSource.coinpaprika:
        return 'Coinpaprika';
      case ApiSource.coincap:
        return 'CoinCap';
      case ApiSource.coingecko:
        return 'CoinGecko';
    }
  }

  String get baseUrl {
    switch (this) {
      case ApiSource.coinpaprika:
        return 'https://api.coinpaprika.com/v1';
      case ApiSource.coincap:
        return 'https://api.coincap.io/v2';
      case ApiSource.coingecko:
        return 'https://api.coingecko.com/api/v3';
    }
  }
}
