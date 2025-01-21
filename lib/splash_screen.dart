import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/my_splash_screen.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
