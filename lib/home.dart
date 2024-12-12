import 'package:flutter/material.dart';
import 'market_page.dart';
import 'watchlist_page.dart';
import 'newsfeed_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> watchlist = []; // Watchlist shared across pages

  static List<Widget> _buildPages(List<dynamic> watchlist) {
    return <Widget>[
      MarketPage(
        onAddToWatchlist: (stock) => watchlist.add(stock),
      ),
      WatchlistPage(watchlist: watchlist),
      NewsfeedPage(),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(watchlist);

    return Scaffold(
      appBar: AppBar(title: Text('Stock Tracker')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Newsfeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: _onItemTapped,
      ),
    );
  }
}
