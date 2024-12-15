import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'theme_notifier.dart'; 
import 'package:shared_preferences/shared_preferences.dart';



class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true; 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load the saved preferences for notifications
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  // Save the notification preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _savePreferences(); // Save the updated preference
  }

  // Sign out the user
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _manageAccount() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Update Password'),
                onTap: _updatePassword,
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Account'),
                onTap: _deleteAccount,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updatePassword() async {
    Navigator.pop(context);
    final user = _auth.currentUser;

    if (user != null) {
      final newPasswordController = TextEditingController();
      final currentPasswordController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);
                    await user.updatePassword(newPasswordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update password: $e')),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteAccount() async {
    Navigator.pop(context);
    final user = _auth.currentUser;

    if (user != null) {
      final passwordController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please enter your password to confirm account deletion.'),
                SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: passwordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);
                    await user.delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Account deleted successfully')),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); 

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text(themeNotifier.isDarkMode ? 'Enabled' : 'Disabled'),
                    value: themeNotifier.isDarkMode,
                    onChanged: (value) {
                      themeNotifier.toggleTheme(); 
                    },
                    secondary: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  SwitchListTile(
                    title: Text('Notifications'),
                    subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    secondary: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.manage_accounts),
                    title: Text('Manage Account'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: _manageAccount,
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
