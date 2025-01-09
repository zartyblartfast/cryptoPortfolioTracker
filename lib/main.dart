import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/cryptocurrency.dart';
import 'models/portfolio.dart';
import 'screens/crypto_detail_screen.dart';
import 'services/api_service.dart';

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

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({Key? key}) : super(key: key);

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final ApiService apiService = ApiService();
  List<Portfolio> portfolios = [];
  List<Cryptocurrency> cryptoList = [];
  List<Cryptocurrency> filteredCryptoList = [];
  int selectedPortfolioIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    portfolios = [Portfolio(name: 'Main Portfolio', cryptocurrencies: [])];
    loadPortfolios();
    fetchCryptoData();
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
      isLoading = true;
    });

    try {
      final cryptos = await apiService.fetchCryptoData();
      setState(() {
        cryptoList = cryptos;
        filteredCryptoList = List.from(cryptoList);
        isLoading = false;
      });
      updatePortfolioValues();
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void updatePortfolioValues() {
    for (var portfolio in portfolios) {
      for (var portfolioCrypto in portfolio.cryptocurrencies) {
        final currentData = cryptoList.firstWhere(
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crypto Portfolio Tracker'),
          bottom: TabBar(
            tabs: [
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
          children: [
            buildCryptocurrenciesTab(),
            buildPortfolioTab(),
          ],
        ),
      ),
    );
  }

  Widget buildCryptocurrenciesTab() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search cryptocurrencies',
              border: OutlineInputBorder(),
            ),
            onChanged: filterCryptoList,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCryptoList.length,
            itemBuilder: (context, index) {
              final crypto = filteredCryptoList[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CryptoDetailScreen(
                          crypto: crypto,
                          addToPortfolio: addToPortfolio,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => addToPortfolio(crypto),
                  child: ListTile(
                    title: Text(crypto.name),
                    subtitle: Text(crypto.symbol),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${crypto.price.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${crypto.percentChange24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: crypto.percentChange24h >= 0
                                ? Colors.green
                                : Colors.red,
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

  void moveCryptoToAnotherPortfolio(
      Cryptocurrency crypto, Portfolio sourcePortfolio) {
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
