import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
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
              onChanged: (value) {
                // Handle search logic
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with the number of fetched stocks
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.trending_up, color: Colors.green),
                    title: Text('Stock ${index + 1}'), // Replace with stock name
                    subtitle: Text('Price: \$100.00 | Change: +2%'), // Replace with real data
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Add to watchlist logic
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
