import 'package:flutter/material.dart';

class WatchlistPage extends StatelessWidget {
  final List<dynamic> watchlist;

  WatchlistPage({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: watchlist.isEmpty
          ? Center(child: Text('No stocks in the watchlist yet.'))
          : ListView.builder(
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final stock = watchlist[index];
                return ListTile(
                  leading: Icon(Icons.star, color: Colors.yellow),
                  title: Text(stock['description'] ?? 'N/A'),
                  subtitle: Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                );
              },
            ),
    );
  }
}
