import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'splash_screen.dart';
import 'pages/about_page.dart';
import 'pages/settings_page.dart';
import 'pages/support_page.dart';
import 'pages/verse_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to your Verse Vault...',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/settings': (context) => SettingsPage(),
        '/support': (context) => SupportPage(),
        '/verse': (context) => VersePage(),
      },
    );
  }
}
