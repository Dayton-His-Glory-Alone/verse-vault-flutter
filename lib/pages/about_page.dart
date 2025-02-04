import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Verse Vault'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why Verse Vault?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "My wife and I were trying to memorize Romans 8 together on a tradition called Monday Memory. We had a good start but had trouble refreshing on the verses we already learned. I wanted Monday Memory to be both fun and helpful. So, I set out to create a Scripture memory app that made learning Scripture like a game. It has been a great way to engage my wife and I in Scripture and I hope it does the same for you.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Why Memorize Scripture?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Memorizing Scripture is a powerful tool for spiritual growth. It helps us:\n\n"
                "• Resist temptation\n"
                "• Encourage others\n"
                "• Enrich our walk with God",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
