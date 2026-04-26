import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/data_seeder.dart';
import 'screens/logo_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Run seeding in background
    DataSeeder.seedDataIfNeeded().catchError((e) => print('Background seeding error: $e'));
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SchoolAge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B3346)), // Matches the dark blue theme
        useMaterial3: true,
      ),
      home: const LogoScreen(),
    );
  }
}
