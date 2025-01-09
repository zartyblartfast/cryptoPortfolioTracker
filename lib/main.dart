import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/cryptocurrency.dart';
import 'screens/crypto_detail_screen.dart';

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

class Portfolio {
  String name;
  List<Cryptocurrency> cryptocurrencies;

  Portfolio({required this.name, required this.cryptocurrencies});

  double get totalValue {
    return cryptocurrencies.fold(0, (sum, item) => sum + item.value);
  }
}

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({Key? key}) : super(key: key);

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  List<Cryptocurrency> cryptoList = [];
  List<Cryptocurrency> filteredCryptoList = [];
  List<Portfolio> portfolios = [];
  int selectedPortfolioIndex = 0;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPortfolios().then((_) {
      fetchCryptoData();
      setState(() {}); // Trigger a rebuild after loading portfolios
    });
  }

  Future<void> savePortfolios() async {
    print('Saving portfolios...'); // Debug print
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodedPortfolios = portfolios.map((portfolio) {
      return {
        'name': portfolio.name,
        'cryptocurrencies': portfolio.cryptocurrencies.map((crypto) => {
          'id': crypto.id,
          'name': crypto.name,
          'symbol': crypto.symbol,
          'price': crypto.price,
          'percentChange24h': crypto.percentChange24h,
          'marketCap': crypto.marketCap,
          'volume24h': crypto.volume24h,
          'rank': crypto.rank,
          'amount': crypto.amount,
        }).toList(),
      };
    }).toList();
    final encodedData = json.encode(encodedPortfolios);
    final success = await prefs.setString('portfolios', encodedData);
    print('Portfolios saved: $encodedData');  // Debug print
    print('Save operation success: $success'); // Debug print
    
    // Verify that the data was saved correctly
    final savedData = prefs.getString('portfolios');
    print('Verification - Saved data: $savedData');
    
    // Print all keys in SharedPreferences
    print('All keys in SharedPreferences: ${prefs.getKeys()}');

    // Check if the data was actually saved
    await checkSharedPreferences();
  }

  Future<void> loadPortfolios() async {
    print('Loading portfolios...'); // Debug print
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('portfolios');
    print('Loaded portfolios data: $encodedData');  // Debug print
    print('All keys in SharedPreferences: ${prefs.getKeys()}'); // Debug print
    if (encodedData != null && encodedData.isNotEmpty) {
      try {
        final List<dynamic> decodedData = json.decode(encodedData);
        setState(() {
          portfolios = decodedData.map((portfolioData) {
            return Portfolio(
              name: portfolioData['name'],
              cryptocurrencies: (portfolioData['cryptocurrencies'] as List<dynamic>).map((item) => Cryptocurrency(
                id: item['id'],
                name: item['name'],
                symbol: item['symbol'],
                price: item['price'].toDouble(),
                percentChange24h: item['percentChange24h'].toDouble(),
                marketCap: item['marketCap'].toDouble(),
                volume24h: item['volume24h'].toDouble(),
                rank: item['rank'],
                amount: item['amount'].toDouble(),
              )).toList(),
            );
          }).toList();
        });
      } catch (e) {
        print('Error decoding portfolio data: $e');  // Debug print
      }
    } else {
      print('No saved portfolio data found'); // Debug print
    }
    if (portfolios.isEmpty) {
      portfolios.add(Portfolio(name: 'Main Portfolio', cryptocurrencies: []));
      print('Added default portfolio'); // Debug print
    }
    print('Portfolios after loading: $portfolios');  // Debug print
  }

  Future<void> clearSharedPreferences() async {
    print('Clearing SharedPreferences...'); // Debug print
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared'); // Debug print
    await checkSharedPreferences();
  }

  Future<void> checkSharedPreferences() async {
    print('Checking SharedPreferences...'); // Debug print
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('portfolios');
    print('Current portfolios data in SharedPreferences: $encodedData');
    print('All keys in SharedPreferences: ${prefs.getKeys()}');
  }

  Future<void> fetchCryptoData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://api.coinpaprika.com/v1/tickers'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          cryptoList = jsonData.map((data) => Cryptocurrency.fromJson(data)).toList();
          filteredCryptoList = List.from(cryptoList);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load crypto data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching crypto data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  void updatePortfolioValues() {
    setState(() {
      for (var portfolio in portfolios) {
        for (var portfolioCrypto in portfolio.cryptocurrencies) {
          final updatedCrypto = cryptoList.firstWhere(
            (crypto) => crypto.id == portfolioCrypto.id,
            orElse: () => portfolioCrypto,
          );
          portfolioCrypto.price = updatedCrypto.price;
          portfolioCrypto.percentChange24h = updatedCrypto.percentChange24h;
          portfolioCrypto.marketCap = updatedCrypto.marketCap;
          portfolioCrypto.volume24h = updatedCrypto.volume24h;
          portfolioCrypto.rank = updatedCrypto.rank;
        }
      }
    });
    savePortfolios();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto Portfolio Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cryptocurrencies'),
              Tab(text: 'Portfolio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildCryptocurrenciesTab(),
            buildPortfolioTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            fetchCryptoData();
            updatePortfolioValues();
          },
          child: Icon(Icons.refresh),
          tooltip: 'Refresh Data',
        ),
      ),
    );
  }

  Widget buildCryptocurrenciesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Enter a cryptocurrency name or symbol',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: filterCryptoList,
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('24h %', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Market Cap', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Volume (24h)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCryptoList.length,
                        itemBuilder: (context, index) {
                          final crypto = filteredCryptoList[index];
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CryptoDetailScreen(
                                  crypto: crypto,
                                  addToPortfolio: addToPortfolio,
                                ),
                              ),
                            ),
                            onLongPress: () => addToPortfolio(crypto),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(crypto.name)),
                                  Expanded(child: Text(crypto.symbol)),
                                  Expanded(child: Text('\$${crypto.price.toStringAsFixed(2)}')),
                                  Expanded(
                                    child: Text(
                                      '${crypto.percentChange24h.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: crypto.percentChange24h >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Text('\$${(crypto.marketCap / 1e9).toStringAsFixed(2)}B')),
                                  Expanded(child: Text('\$${(crypto.volume24h / 1e6).toStringAsFixed(2)}M')),
                                  Expanded(child: Text('${crypto.rank}')),
                                ],
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
                    portfolios.add(Portfolio(name: newPortfolioName, cryptocurrencies: []));
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
                    tooltip: 'Rename Portfolio',
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: createNewPortfolio,
                    tooltip: 'New Portfolio',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deletePortfolio(currentPortfolio),
                    tooltip: 'Delete Portfolio',
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Portfolio Value: \$${currentPortfolio.totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: currentPortfolio.cryptocurrencies.length,
            itemBuilder: (context, index) {
              final crypto = currentPortfolio.cryptocurrencies[index];
              return Dismissible(
                key: Key(crypto.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  removeFromPortfolio(crypto, currentPortfolio);
                },
                child: ListTile(
                  title: Text(crypto.name),
                  subtitle: Text('Amount: ${crypto.amount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${crypto.value.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.move_to_inbox),
                        onPressed: () => moveCryptoToAnotherPortfolio(crypto, currentPortfolio),
                        tooltip: 'Move to Another Portfolio',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  savePortfolios();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Portfolios saved manually')),
                  );
                },
                child: Text('Save Portfolios'),
              ),
              ElevatedButton(
                onPressed: () {
                  clearSharedPreferences();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('SharedPreferences cleared')),
                  );
                },
                child: Text('Clear SharedPreferences'),
              ),
            ],
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
            controller: TextEditingController(text: newName),
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
    if (portfolios.length > 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Portfolio'),
            content: Text('Are you sure you want to delete "${portfolio.name}"?'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete the only portfolio')),
      );
    }
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int targetPortfolioIndex = portfolios.indexOf(sourcePortfolio);
        return AlertDialog(
          title: Text('Move ${crypto.name} to Another Portfolio'),
          content: DropdownButton<int>(
            value: targetPortfolioIndex,
            items: portfolios.asMap().entries.where((entry) => entry.value != sourcePortfolio).map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value.name),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                targetPortfolioIndex = newValue;
              }
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
              child: Text('Move'),
              onPressed: () {
                setState(() {
                  sourcePortfolio.cryptocurrencies.remove(crypto);
                  portfolios[targetPortfolioIndex].cryptocurrencies.add(crypto);
                });
                savePortfolios();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${crypto.name} moved to ${portfolios[targetPortfolioIndex].name}')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void filterCryptoList(String query) {
    setState(() {
      filteredCryptoList = cryptoList
          .where((crypto) =>
              crypto.name.toLowerCase().contains(query.toLowerCase()) ||
              crypto.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
