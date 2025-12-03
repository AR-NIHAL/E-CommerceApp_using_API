import 'package:flutter/material.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF101010), // solid background
      body: Center(
        child: Icon(
          Icons.shopping_bag, // or Image.asset('assets/logo.png')
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}
