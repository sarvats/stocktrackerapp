import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load the saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default to dark mode
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  // Save the theme and notification preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _savePreferences(); // Save the updated preference
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _savePreferences(); // Save the updated preference
  }

  // Sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // After signing out, redirect to login or home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Adjust to your login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text(_isDarkMode ? 'Enabled' : 'Disabled'),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            Divider(height: 32),
            TextButton(
              onPressed: () {
                // Placeholder for account management logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Manage Account clicked')),
                );
              },
              child: Text('Manage Account', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                _signOut(); // Sign out logic
              },
              child: Text('Sign Out', style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
