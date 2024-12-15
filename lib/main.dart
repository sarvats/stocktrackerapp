import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(StockTrackerApp());
}

class StockTrackerApp extends StatefulWidget {
  @override
  _StockTrackerAppState createState() => _StockTrackerAppState();
}

class _StockTrackerAppState extends State<StockTrackerApp> {
  bool _isDarkMode = true;

  // Load the theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default to dark mode
    });
  }

  // Save the theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker App',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Toggle based on user preference
      home: AuthenticationWrapper(),
      // Pass theme preference setter to AuthenticationWrapper or SettingsPage
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null ? LoginPage() : HomePage();
  }
}
