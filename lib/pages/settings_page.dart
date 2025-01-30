import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verse_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  SettingsPage({required this.onThemeChanged, required this.isDarkMode});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedTranslation = 'ESV';
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggleDarkMode(bool value) async {
    setState(() {
      isDarkMode = value;
    });

    widget.onThemeChanged(value);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
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
                value: isDarkMode,
                onChanged: _toggleDarkMode,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Notifications'),
              subtitle: Text('Enable daily reminders'),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {},
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Translation'),
              subtitle: Text('Change Bible Translation'),
              trailing: DropdownButton<String>(
                value: selectedTranslation,
                items: <String>['KJV', 'ESV'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTranslation = newValue!;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VersePage(selectedTranslation: selectedTranslation),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Reset Progress'),
              subtitle: Text('Clear all memorized verses'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
