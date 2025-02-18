import 'package:automate/costumer/profile_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'costumer/register_screen.dart';
import 'mechanic/mechanic_registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // void _navigateToRegister(BuildContext context) {
  //   Navigator.pushNamed(context, '/register');
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/mechanic_register': (context) => const MechanicRegistrationScreen(),
        'profile_screen': (context) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
