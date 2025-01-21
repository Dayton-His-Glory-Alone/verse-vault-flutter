import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final String _buyMeACoffeeUrl = "https://www.buymeacoffee.com/yourusername";

  Future<void> _launchURL() async {
    if (await canLaunch(_buyMeACoffeeUrl)) {
      await launch(_buyMeACoffeeUrl);
    } else {
      throw 'Could not launch $_buyMeACoffeeUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Verse Vault'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Thank you for using Verse Vault!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'If you’d like to support the app, consider buying me a coffee!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchURL,
              child: Text('Buy Me a Coffee'),
            ),
          ],
        ),
      ),
    );
  }
}
