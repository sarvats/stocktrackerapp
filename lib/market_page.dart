import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    const String apiKey = 'ctdlb1hr01qng9get1lgctdlb1hr01qng9get1m0';
    final Uri url =
        Uri.parse('https://finnhub.io/api/v1/stock/symbol?exchange=US&token=$apiKey');

    try {
      print('Fetching stock data from API...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('Stocks fetched successfully. Total stocks: ${decodedResponse.length}');

        setState(() {
          stocks = decodedResponse;
          filteredStocks = stocks; // Initialize filtered list
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

  Future<void> saveToFirestore(dynamic stock) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchlist')
            .add({
          'symbol': stock['symbol'],
          'description': stock['description'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Stock added to Firestore: ${stock['symbol']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${stock['description']} added to watchlist')),
        );
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
      showError('Failed to save stock to watchlist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Market',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                prefixIcon: Icon(Icons.search, 
                  color: Theme.of(context).colorScheme.primary),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (value) => filterStocks(value),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStocks.length,
                    itemBuilder: (context, index) {
                      final stock = filteredStocks[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsPage(
                                  symbol: stock['symbol'],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stock['description'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        stock['symbol'] ?? 'N/A',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: () {
                                    saveToFirestore(stock);
                                    widget.onAddToWatchlist(stock);
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Add'),
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
    );
  }
}
