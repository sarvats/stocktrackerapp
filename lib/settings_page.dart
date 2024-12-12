import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
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
                // Placeholder for sign-out logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign Out clicked')),
                );
              },
              child: Text('Sign Out', style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}