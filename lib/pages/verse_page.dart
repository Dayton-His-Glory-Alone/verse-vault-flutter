import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VersePage extends StatelessWidget {
  const VersePage({Key? key}) : super(key: key);

  Future<String?> _loadVerse(String verseReference) async {
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString('assets/data/verses.json');
      final Map<String, dynamic> verses = json.decode(jsonString);

      // Return the verse text for the reference
      return verses[verseReference] as String?;
    } catch (e) {
      // Handle errors (e.g., missing file or invalid reference)
      debugPrint('Error loading verse: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String verseReference = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text(verseReference)),
      body: FutureBuilder<String?>(
        future: _loadVerse(verseReference),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                'Verse not found.',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else {
            return Center(
              child: Text(
                snapshot.data!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            );
          }
        },
      ),
    );
  }
}
