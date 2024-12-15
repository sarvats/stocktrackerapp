import 'package:flutter/material.dart';
import 'market_page.dart';
import 'watchlist_page.dart';
import 'newsfeed_page.dart';
import 'settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> watchlist = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  Future<void> _fetchWatchlist() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('watchlists').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            watchlist = List.from(doc.data()?['stocks'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
    }
  }

  Future<void> _updateWatchlist() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('watchlists').doc(user.uid).set({
          'stocks': watchlist,
        });
      }
    } catch (e) {
      print('Error updating watchlist: $e');
    }
  }

  void _addToWatchlist(dynamic stock) {
    if (!watchlist.any((item) => item['symbol'] == stock['symbol'])) {
      setState(() {
        watchlist.add(stock);
      });
      _updateWatchlist();
    }
  }

  void _removeFromWatchlist(int index) {
    setState(() {
      watchlist.removeAt(index);
    });
    _updateWatchlist();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MarketPage(onAddToWatchlist: _addToWatchlist),
      WatchlistPage(
        watchlist: watchlist,
        onRemoveStock: _removeFromWatchlist,
      ),
      NewsfeedPage(),
      SettingsPage(),
    ];

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