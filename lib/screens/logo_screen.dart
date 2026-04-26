import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_screen.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Welcome Screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match the pure white background of the image
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            'assets/images/anna_logo.png',
            fit: BoxFit.contain, // This scales your image perfectly into the screen
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Please make sure logo.png is correctly placed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

