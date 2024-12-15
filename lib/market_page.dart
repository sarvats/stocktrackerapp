import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'stockdetails.dart'; 

class MarketPage extends StatefulWidget {
  final Function(dynamic stock) onAddToWatchlist;

  MarketPage({required this.onAddToWatchlist});

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<dynamic> stocks = [];
  List<dynamic> filteredStocks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    const String apiKey = 'ctdlb1hr01qng9get1lgctdlb1hr01qng9get1m0';
    final Uri url = Uri.parse('https://finnhub.io/api/v1/stock/symbol?exchange=US&token=$apiKey');

    try {
      print('Fetching stock data from API...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('Stocks fetched successfully. Total stocks: ${decodedResponse.length}');

        setState(() {
          stocks = decodedResponse;
          filteredStocks = stocks;
          isLoading = false;
        });
      } else {
        print('Failed to fetch stock data. HTTP Status: ${response.statusCode}');
        showError('Failed to fetch stock data. Please try again.');
      }
    } catch (e) {
      print('An error occurred while fetching stocks: $e');
      showError('An error occurred: $e');
    }
  }

  void showError(String message) {
    print('Showing error: $message');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void filterStocks(String query) {
    print('Filtering stocks for query: $query');
    setState(() {
      filteredStocks = stocks
          .where((stock) =>
              (stock['description'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (stock['symbol'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
      print('Filtered stocks count: ${filteredStocks.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for stocks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterStocks(value),
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredStocks.length,
                      itemBuilder: (context, index) {
                        final stock = filteredStocks[index];
                        print('Displaying stock: ${stock['description'] ?? 'N/A'} (${stock['symbol'] ?? 'N/A'})');
                        return ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text(stock['description'] ?? 'N/A'),
                          subtitle: Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                          onTap: () {
                            print('Navigating to StockDetailsPage for symbol: ${stock['symbol']}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsPage(
                                  symbol: stock['symbol'],
                                ),
                              ),
                            );
                          },
                          trailing: ElevatedButton(
                            onPressed: () {
                              print('Adding stock to watchlist: ${stock['symbol']}');
                              widget.onAddToWatchlist(stock);
                            },
                            child: Text('Add'),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
