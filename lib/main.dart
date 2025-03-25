import 'package:automate/costumer/profile_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'costumer/register_screen.dart';
import 'mechanic/mechanic_registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'secrets/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use the generated FirebaseOptions
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Default home screen is the login screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/mechanic_register': (context) => const MechanicRegistrationScreen(),
        '/profile_screen': (context) =>
            const ProfileScreen(), // Corrected route path
      },
      debugShowCheckedModeBanner: false,
    );
  }
}