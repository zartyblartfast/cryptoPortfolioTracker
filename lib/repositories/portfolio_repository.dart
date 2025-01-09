import '../models/portfolio.dart';
import '../models/cryptocurrency.dart';
import '../services/storage_service.dart';

class PortfolioRepository {
  final StorageService _storageService;

  PortfolioRepository(this._storageService);

  Future<List<Portfolio>> getPortfolios() async {
    return await _storageService.loadPortfolios();
  }

  Future<void> savePortfolios(List<Portfolio> portfolios) async {
    await _storageService.savePortfolios(portfolios);
  }

  Future<void> addCryptoToPortfolio(Portfolio portfolio, Cryptocurrency crypto, double amount) async {
    final updatedCrypto = crypto.copyWith(amount: amount);
    portfolio.cryptocurrencies.add(updatedCrypto);
    final portfolios = await getPortfolios();
    final index = portfolios.indexWhere((p) => p.name == portfolio.name);
    if (index != -1) {
      portfolios[index] = portfolio;
      await savePortfolios(portfolios);
    }
  }

  Future<void> removeCryptoFromPortfolio(Portfolio portfolio, Cryptocurrency crypto) async {
    portfolio.cryptocurrencies.removeWhere((c) => c.id == crypto.id);
    final portfolios = await getPortfolios();
    final index = portfolios.indexWhere((p) => p.name == portfolio.name);
    if (index != -1) {
      portfolios[index] = portfolio;
      await savePortfolios(portfolios);
    }
  }
}
