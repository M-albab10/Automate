import 'package:automate/profile_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'mechanic_registration_screen.dart';
import 'profile_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/mechanic_register': (context) => MechanicRegistrationScreen(),
        'profile_screen':(context) =>const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
