import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("🎉 Welcome to the App!", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
