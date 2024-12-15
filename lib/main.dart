import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login_page.dart';
import 'theme_notifier.dart'; 
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: StockTrackerApp(),
    ),
  );
}

class StockTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); 

    return MaterialApp(
      title: 'Stock Tracker App',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Dynamic theme
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null ? LoginPage() : HomePage();
  }
}
