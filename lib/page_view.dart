// import 'package:flutter/material.dart';
// import 'costumer/profile_screen.dart';
// import 'bars/navbar.dart';
// import 'costumer/chat_screen.dart';
// import 'costumer/cars_screen.dart';
// import 'costumer/order_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   // List of screens
//   final List<Widget> _screens = [
//     const CarScreen(), // Replace with actual screen widgets
//     const OrdersScreen(),
//     const ChatScreen(),
//     const ProfileScreen(),
//   ];

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     _pageController.jumpToPage(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         physics:
//             const NeverScrollableScrollPhysics(), // Disable swipe to switch screens
//         children: _screens,
//         onPageChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: _currentIndex,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }
