import 'package:flutter/material.dart';
import 'dart:io'; // For local file storage
import 'dart:convert'; // For JSON handling

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _verseController = TextEditingController();
  final String _filePath = 'assets/data/verses.json';
  List<Map<String, dynamic>> verses = [];

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    try {
      final file = File(_filePath);
      if (file.existsSync()) {
        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        setState(() {
          verses = data.entries
              .map((entry) => {
                    'verse': entry.key,
                    'text': entry.value,
                    'dateMemorized': '',
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error loading verses: $e');
    }
  }

  Future<void> _saveVerse(String verse) async {
    setState(() {
      verses.add({'verse': verse, 'text': '', 'dateMemorized': ''});
    });
  }

  Future<void> _deleteVerse(int index) async {
    setState(() {
      verses.removeAt(index);
    });
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
            'Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Image.asset('assets/gifs/mountains3.gif', height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _verseController,
              decoration: InputDecoration(
                labelText: 'Add a Verse',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _saveVerse(value);
                  _verseController.clear();
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                return ListTile(
                  title: Text(verse['verse']),
                  subtitle: Text(verse['dateMemorized'].isEmpty
                      ? 'Expires: TBD'
                      : 'Expires: ${verse['dateMemorized']}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/verse',
                      arguments: verse['verse'],
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteVerse(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
