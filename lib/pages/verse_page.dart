import 'package:flutter/material.dart';

class VersePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String verse = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text(verse)),
      body: Center(
        child: Text(
          verse,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
