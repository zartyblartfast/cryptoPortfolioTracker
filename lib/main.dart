import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/cryptocurrency.dart';
import 'models/portfolio.dart';
import 'models/api_source.dart';
import 'screens/crypto_detail_screen.dart';
import 'services/api_service.dart';
import 'widgets/crypto_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CryptoPortfolioApp());
}

class CryptoPortfolioApp extends StatelessWidget {
  const CryptoPortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Portfolio Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: const CryptoListScreen(),
    );
  }
}

/// CryptoListScreen is a critical component that implements the main cryptocurrency list view.
/// 
/// CRITICAL FEATURES - DO NOT MODIFY WITHOUT EXPLICIT REQUEST:
/// 1. Column layout showing all cryptocurrency data
/// 2. Long-press to add functionality
/// 3. Navigation to detail view
/// 4. Search functionality
class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({Key? key}) : super(key: key);

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Cryptocurrency> _cryptoList = [];
  List<Cryptocurrency> _filteredList = [];
  List<Portfolio> portfolios = [];
  Portfolio? _selectedPortfolio;
  bool _isLoading = true;
  String _searchTerm = '';
  int selectedPortfolioIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    portfolios = [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
    loadPortfolios();
    fetchCryptoData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index == 0) { // Cryptocurrencies tab
      filterCryptoList(_searchTerm);
    }
  }

  Future<void> savePortfolios() async {
    final prefs = await SharedPreferences.getInstance();
    final portfoliosJson = portfolios.map((portfolio) => portfolio.toJson()).toList();
    final success = await prefs.setString('portfolios', jsonEncode(portfoliosJson));
    print('Saving portfolios...');
    print('Portfolios saved: ${jsonEncode(portfoliosJson)}');
    print('Save operation success: $success');
    
    // Verification
    print('Verification - Saved data: ${jsonEncode(portfoliosJson)}');
    print('All keys in SharedPreferences: ${prefs.getKeys()}');
    
    // Check the data was actually saved
    checkSharedPreferences();
  }

  Future<void> loadPortfolios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfoliosJson = prefs.getString('portfolios');
      if (portfoliosJson != null) {
        final List<dynamic> decoded = jsonDecode(portfoliosJson);
        setState(() {
          portfolios = decoded.map((json) => Portfolio.fromJson(json)).toList();
        });
      } else {
        setState(() {
          portfolios = [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
        });
      }
    } catch (e) {
      print('Error loading portfolios: $e');
      setState(() {
        portfolios = [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
      });
    }
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared');
    checkSharedPreferences();
  }

  Future<void> checkSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('Checking SharedPreferences...');
    final portfoliosJson = prefs.getString('portfolios');
    print('Current portfolios data in SharedPreferences:');
    print(portfoliosJson);
    print('All keys in SharedPreferences: ${prefs.getKeys()}');
  }

  Future<void> fetchCryptoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cryptos = await _apiService.fetchCryptoData();
      setState(() {
        _cryptoList = cryptos;
        _filteredList = List.from(_cryptoList);
        _isLoading = false;
      });
      updatePortfolioValues();
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  void updatePortfolioValues() {
    for (var portfolio in portfolios) {
      for (var portfolioCrypto in portfolio.cryptocurrencies) {
        final currentData = _cryptoList.firstWhere(
          (c) => c.id == portfolioCrypto.id,
          orElse: () => portfolioCrypto,
        );
        portfolioCrypto.price = currentData.price;
        portfolioCrypto.percentChange24h = currentData.percentChange24h;
        portfolioCrypto.marketCap = currentData.marketCap;
        portfolioCrypto.volume24h = currentData.volume24h;
        portfolioCrypto.rank = currentData.rank;
      }
    }
  }

  void filterCryptoList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = List.from(_cryptoList);
      } else {
        _filteredList = _cryptoList
            .where((crypto) =>
                crypto.name.toLowerCase().contains(query.toLowerCase()) ||
                crypto.symbol.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto Portfolio Tracker'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Cryptocurrencies'),
              Tab(text: 'Portfolio'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchCryptoData,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildCryptocurrenciesTab(),
            buildPortfolioTab(),
          ],
        ),
      ),
    );
  }

  /// Builds the cryptocurrency list view with all required columns and interactions.
  /// 
  /// CRITICAL IMPLEMENTATION NOTES:
  /// 1. Maintains column layout with specific flex values
  /// 2. Preserves long-press and tap interactions
  /// 3. Keeps all data formatting (currency, percentages, B/M suffixes)
  Widget buildCryptocurrenciesTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search cryptocurrencies',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                    filterCryptoList(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<ApiSource>(
                value: _apiService.currentSource,
                items: ApiSource.values.map((source) {
                  return DropdownMenuItem<ApiSource>(
                    value: source,
                    child: Text(source.displayName),
                  );
                }).toList(),
                onChanged: (ApiSource? newSource) {
                  if (newSource != null) {
                    setState(() {
                      _apiService.currentSource = newSource;
                    });
                    fetchCryptoData();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '24h %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Market Cap',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Volume (24h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    final crypto = _filteredList[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          _showCryptoDetails(crypto);
                        },
                        onLongPress: () => addToPortfolio(crypto),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crypto.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(crypto.symbol),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '\$${crypto.price.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${crypto.percentChange24h.toStringAsFixed(2)}%',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: crypto.percentChange24h >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '\$${(crypto.marketCap / 1000000000).toStringAsFixed(2)}B',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '\$${(crypto.volume24h / 1000000).toStringAsFixed(2)}M',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void createNewPortfolio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPortfolioName = '';
        return AlertDialog(
          title: Text('Create New Portfolio'),
          content: TextField(
            decoration: InputDecoration(hintText: "Enter portfolio name"),
            onChanged: (value) {
              newPortfolioName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (newPortfolioName.isNotEmpty) {
                  setState(() {
                    portfolios.add(Portfolio(
                      name: newPortfolioName,
                      cryptocurrencies: [],
                    ));
                    selectedPortfolioIndex = portfolios.length - 1;
                  });
                  savePortfolios();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPortfolioTab() {
    if (portfolios.isEmpty) {
      return Center(child: Text('No portfolios available'));
    }

    final currentPortfolio = portfolios[selectedPortfolioIndex];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<int>(
                value: selectedPortfolioIndex,
                items: portfolios.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value.name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPortfolioIndex = newValue;
                    });
                  }
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => renamePortfolio(currentPortfolio),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deletePortfolio(currentPortfolio),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: createNewPortfolio,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Value: \$${currentPortfolio.totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: currentPortfolio.cryptocurrencies.length,
            itemBuilder: (context, index) {
              final crypto = currentPortfolio.cryptocurrencies[index];
              return Card(
                child: ListTile(
                  title: Text(crypto.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${crypto.amount}'),
                      Text('Value: \$${crypto.value.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.swap_horiz),
                        onPressed: () => moveCryptoToAnotherPortfolio(
                          crypto,
                          currentPortfolio,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            removeFromPortfolio(crypto, currentPortfolio),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void renamePortfolio(Portfolio portfolio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = portfolio.name;
        return AlertDialog(
          title: Text('Rename Portfolio'),
          content: TextField(
            decoration: InputDecoration(hintText: "Enter new name"),
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: portfolio.name),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rename'),
              onPressed: () {
                if (newName.isNotEmpty) {
                  setState(() {
                    portfolio.name = newName;
                  });
                  savePortfolios();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void deletePortfolio(Portfolio portfolio) {
    if (portfolios.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete the last portfolio')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Portfolio'),
          content:
              Text('Are you sure you want to delete ${portfolio.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  portfolios.remove(portfolio);
                  if (selectedPortfolioIndex >= portfolios.length) {
                    selectedPortfolioIndex = portfolios.length - 1;
                  }
                });
                savePortfolios();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeFromPortfolio(Cryptocurrency crypto, Portfolio portfolio) {
    setState(() {
      portfolio.cryptocurrencies.remove(crypto);
    });
    savePortfolios();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${crypto.name} removed from portfolio')),
    );
  }

  void moveCryptoToAnotherPortfolio(Cryptocurrency crypto, Portfolio sourcePortfolio) {
    if (portfolios.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create another portfolio first to move cryptocurrencies')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedPortfolioId = portfolios
            .where((p) => p.id != sourcePortfolio.id)
            .first
            .id;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Move ${crypto.name} to Another Portfolio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedPortfolioId,
                    items: portfolios
                        .where((p) => p.id != sourcePortfolio.id)
                        .map((portfolio) {
                          return DropdownMenuItem<String>(
                            value: portfolio.id,
                            child: Text(portfolio.name),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPortfolioId = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Move'),
                  onPressed: () {
                    if (selectedPortfolioId != null) {
                      final targetPortfolio = portfolios.firstWhere(
                        (p) => p.id == selectedPortfolioId
                      );
                      setState(() {
                        sourcePortfolio.cryptocurrencies.remove(crypto);
                        targetPortfolio.cryptocurrencies.add(crypto);
                      });
                      savePortfolios();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${crypto.name} moved to ${targetPortfolio.name}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCryptoDetails(Cryptocurrency crypto) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${crypto.name} (${crypto.symbol.toUpperCase()})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Chart
              Expanded(
                child: CryptoChart(
                  symbol: crypto.symbol,
                  name: crypto.name,
                  apiService: _apiService,
                ),
              ),
              const SizedBox(height: 8),
              // Price and 24h change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price: \$${crypto.price.toStringAsFixed(2)}'),
                  Text(
                    '24h: ${crypto.percentChange24h >= 0 ? '+' : ''}${crypto.percentChange24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: crypto.percentChange24h >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Market cap and volume
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Market Cap: \$${_formatLargeNumber(crypto.marketCap)}'),
                  Text('Volume (24h): \$${_formatLargeNumber(crypto.volume24h)}'),
                ],
              ),
              const SizedBox(height: 8),
              // Add to portfolio button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _addCryptoToPortfolio(crypto),
                    child: const Text('Add to Portfolio'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCryptoToPortfolio(Cryptocurrency crypto) {
    if (_selectedPortfolio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a portfolio first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double amount = 0;
        return AlertDialog(
          title: Text('Add ${crypto.name} to Portfolio'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
            onChanged: (value) {
              amount = double.tryParse(value) ?? 0;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (amount > 0) {
                  setState(() {
                    crypto.amount = amount;
                    if (!_selectedPortfolio!.cryptocurrencies.any((c) => c.id == crypto.id)) {
                      _selectedPortfolio!.cryptocurrencies.add(crypto);
                    }
                  });
                  savePortfolios();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close the details dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${crypto.name} added to portfolio')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _removeCryptoFromPortfolio(Cryptocurrency crypto) {
    if (_selectedPortfolio == null) return;

    setState(() {
      _selectedPortfolio!.cryptocurrencies.removeWhere((c) => c.id == crypto.id);
    });
    savePortfolios();
    Navigator.of(context).pop(); // Close the details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${crypto.name} removed from portfolio')),
    );
  }

  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }

  void addToPortfolio(Cryptocurrency crypto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String amount = '';
        int targetPortfolioIndex = selectedPortfolioIndex;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add ${crypto.name} to Portfolio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: targetPortfolioIndex,
                    items: portfolios.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value.name),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          targetPortfolioIndex = newValue;
                        });
                      }
                    },
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Enter amount"),
                    onChanged: (value) {
                      amount = value;
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (amount.isNotEmpty) {
                      setState(() {
                        portfolios[targetPortfolioIndex].cryptocurrencies.add(
                          crypto.copyWith(amount: double.parse(amount))
                        );
                      });
                      savePortfolios();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${crypto.name} added to ${portfolios[targetPortfolioIndex].name}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
