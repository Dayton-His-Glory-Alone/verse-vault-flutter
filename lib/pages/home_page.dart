import 'package:flutter/material.dart';
import 'dart:io'; // For local file storage
import 'dart:convert'; // For JSON handling
import 'package:intl/intl.dart'; // For date formatting

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _logFilePath = 'assets/data/completion_log.txt';
  List<Map<String, dynamic>> verses = [];

  @override
  void initState() {
    super.initState();
    _loadCompletionLog();
  }

  /// Load the completion log from a local file
  Future<void> _loadCompletionLog() async {
    try {
      final file = File(_logFilePath);
      if (file.existsSync()) {
        final content = await file.readAsString();
        final data = json.decode(content) as List<dynamic>;
        setState(() {
          verses = data.map((entry) {
            final completionDate = DateTime.parse(entry['completionDate']);
            final expirationDate = completionDate.add(Duration(days: 7));
            return {
              'verse': entry['verse'],
              'completionDate': completionDate,
              'expirationDate': expirationDate,
            };
          }).toList();
        });
      } else {
        print("Log file not found.");
      }
    } catch (e) {
      print('Error loading completion log: $e');
    }
  }

  /// Format a date for display
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Check if a verse is expired
  bool _isExpired(DateTime expirationDate) {
    return DateTime.now().isAfter(expirationDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verse Vault'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              Navigator.pushNamed(context, value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: '/about', child: Text('About')),
              PopupMenuItem(value: '/settings', child: Text('Settings')),
              PopupMenuItem(value: '/support', child: Text('Support Vault')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Completed Verses',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Image.asset('assets/gifs/mountains3.gif', height: 100),
          Expanded(
            child: ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                final expirationDate = verse['expirationDate'] as DateTime;
                final isExpired = _isExpired(expirationDate);
                return ListTile(
                  title: Text(verse['verse']),
                  subtitle: Text(
                    isExpired
                        ? 'Expired on ${_formatDate(expirationDate)}'
                        : 'Expires on ${_formatDate(expirationDate)}',
                  ),
                  trailing: isExpired
                      ? Icon(Icons.warning, color: Colors.red)
                      : Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
