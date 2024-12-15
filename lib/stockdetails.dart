import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockDetailsPage extends StatefulWidget {
  final String symbol;

  const StockDetailsPage({Key? key, required this.symbol}) : super(key: key);

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  Map<String, dynamic> companyProfile = {};
  Map<String, dynamic> stockQuote = {};
  Map<String, dynamic> recommendationData = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchStockDetails();
  }

  Future<void> fetchStockDetails() async {
    const String apiKey = 'ctdlb1hr01qng9get1lgctdlb1hr01qng9get1m0';
    final profileUrl = Uri.parse(
        'https://finnhub.io/api/v1/stock/profile2?symbol=${widget.symbol}&token=$apiKey');
    final quoteUrl = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=$apiKey');
    final recommendationUrl = Uri.parse(
        'https://finnhub.io/api/v1/stock/recommendation?symbol=${widget.symbol}&token=$apiKey');

    try {
      final profileResponse = await http.get(profileUrl);
      final quoteResponse = await http.get(quoteUrl);
      final recommendationResponse = await http.get(recommendationUrl);

      if (profileResponse.statusCode == 200 &&
          quoteResponse.statusCode == 200 &&
          recommendationResponse.statusCode == 200) {
        setState(() {
          companyProfile = json.decode(profileResponse.body);
          stockQuote = json.decode(quoteResponse.body);
          final recommendations = json.decode(recommendationResponse.body);
          if (recommendations.isNotEmpty) {
            recommendationData = recommendations.first; // Latest data
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch stock data. Try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Widget buildRecommendationSection() {
    if (recommendationData.isEmpty) {
      return Center(
        child: Text(
          'No recommendation data available.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyst Recommendation Trends',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRecommendationBox('Strong Buy', recommendationData['strongBuy']),
            _buildRecommendationBox('Buy', recommendationData['buy']),
            _buildRecommendationBox('Hold', recommendationData['hold']),
            _buildRecommendationBox('Sell', recommendationData['sell']),
            _buildRecommendationBox('Strong Sell', recommendationData['strongSell']),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationBox(String label, int? value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Text(
          value?.toString() ?? 'N/A',
          style: TextStyle(fontSize: 16.0, color: Colors.blue),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (companyProfile.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyProfile['name'] ?? 'Unknown Company',
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Industry: ${companyProfile['finnhubIndustry'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Country: ${companyProfile['country'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      if (stockQuote.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Price: \$${stockQuote['c']?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'High: \$${stockQuote['h']?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Low: \$${stockQuote['l']?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Previous Close: \$${stockQuote['pc']?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      const SizedBox(height: 16.0),
                      buildRecommendationSection(),
                    ],
                  ),
                ),
    );
  }
}
