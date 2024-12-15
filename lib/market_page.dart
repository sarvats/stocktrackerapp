import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          stocks = json.decode(response.body);
          filteredStocks = stocks; // Initialize filtered list
          isLoading = false;
        });
      } else {
        showError('Failed to fetch stock data. Please try again.');
      }
    } catch (e) {
      showError('An error occurred: $e');
    }
  }

  void showError(String message) {
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
    setState(() {
      filteredStocks = stocks
          .where((stock) =>
              (stock['description'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (stock['symbol'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
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
                        return ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text(stock['description'] ?? 'N/A'),
                          subtitle: Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              widget.onAddToWatchlist(stock); // Use the callback from HomePage
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
