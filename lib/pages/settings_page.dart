import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
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
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Theme'),
              subtitle: Text('Light / Dark Mode'),
              trailing: Switch(
                value: false,
                onChanged: (bool value) {
                  // Add functionality for theme change
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Notifications'),
              subtitle: Text('Enable daily reminders'),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  // Add functionality for notifications
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Reset Progress'),
              subtitle: Text('Clear all memorized verses'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Add functionality to reset progress
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
