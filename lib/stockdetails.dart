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

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStockPrice() {
    final priceChange = (stockQuote['c'] ?? 0.0) - (stockQuote['pc'] ?? 0.0);
    final priceChangePercentage = (priceChange / (stockQuote['pc'] ?? 1)) * 100;
    final isPositive = priceChange >= 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '\$${stockQuote['c']?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)} (${priceChangePercentage.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationBox(String label, int? value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.symbol,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (companyProfile.isNotEmpty) ...[
                        _buildInfoCard(
                          'Company Profile',
                          [
                            if (companyProfile['logo'] != null)
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.network(
                                    companyProfile['logo'],
                                    height: 60,
                                  ),
                                ),
                              ),
                            SizedBox(height: 16),
                            Text(
                              companyProfile['name'] ?? 'Unknown Company',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow('Industry', companyProfile['finnhubIndustry']),
                            _buildInfoRow('Country', companyProfile['country']),
                            _buildInfoRow('Market Cap', '\$${companyProfile['marketCapitalization']}'),
                            _buildInfoRow('PE Ratio', '${companyProfile['peRatio']}'),
                          ],
                        ),
                      ],
                      if (stockQuote.isNotEmpty) _buildStockPrice(),
                      if (recommendationData.isNotEmpty)
                        _buildInfoCard(
                          'Analyst Recommendations',
                          [
                            Row(
                              children: [
                                _buildRecommendationBox('Strong Buy', recommendationData['strongBuy']),
                                SizedBox(width: 8),
                                _buildRecommendationBox('Buy', recommendationData['buy']),
                                SizedBox(width: 8),
                                _buildRecommendationBox('Hold', recommendationData['hold']),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                _buildRecommendationBox('Sell', recommendationData['sell']),
                                SizedBox(width: 8),
                                _buildRecommendationBox('Strong Sell', recommendationData['strongSell']),
                                SizedBox(width: 8),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}