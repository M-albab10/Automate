// import 'package:flutter/material.dart';
// import '../mechanic/mechanic_jobs_screen.dart'; 
// import '../mechanic/mechanic_chat_screen.dart';
// import '../mechanic/mechanic_profile_screen.dart';

// class MechanicBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const MechanicBottomNavBar({
//     required this.currentIndex,
//     required this.onTap,
//     super.key,
//   });

//   static final List<Map<String, dynamic>> _navigationItems = [
//     {
//       'screen': const MechanicJobsScreen(),
//       'icon': Icons.work,
//       'label': 'Jobs',
//       'activeColor': Colors.blue,
//     },
//     {
//       'screen': const MechanicChatScreen(),
//       'icon': Icons.chat_bubble_outline,
//       'label': 'Chat',
//       'activeColor': Colors.blue,
//     },
//     {
//       'screen': const MechanicProfileScreen(),
//       'icon': Icons.person,
//       'label': 'Profile',
//       'activeColor': Colors.blue,
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: (index) {
//         onTap(index);
//         _navigateToScreen(context, index);
//       },
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: Colors.white,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       items: _navigationItems
//           .map(
//             (item) => BottomNavigationBarItem(
//               icon: Icon(item['icon']),
//               label: item['label'],
//             ),
//           )
//           .toList(),
//     );
//   }

//   void _navigateToScreen(BuildContext context, int index) {
//     if (index == currentIndex) return;

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => _navigationItems[index]['screen']),
//     );
//   }
// }

// // Example usage in Mechanic Home Screen:
// class MechanicHomeScreen extends StatefulWidget {
//   const MechanicHomeScreen({super.key});

//   @override
//   State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
// }

// class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     const MechanicJobsScreen(),
//     const MechanicChatScreen(),
//     const MechanicProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../mechanic/mechanic_jobs_screen.dart'; 
import '../mechanic/mechanic_chat_screen.dart';
import '../mechanic/mechanic_profile_screen.dart';
import '../mechanic/mechanic_offers_screen.dart'; // Add this import

class MechanicBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MechanicBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  static final List<Map<String, dynamic>> _navigationItems = [
    {
      'screen': const MechanicJobsScreen(),
      'icon': Icons.work,
      'label': 'Jobs',
      'activeColor': Colors.blue,
    },
    {
      'screen': const MechanicOffersScreen(), // New Offers screen
      'icon': Icons.handshake_outlined,
      'label': 'My Offers',
      'activeColor': Colors.blue,
    },
    {
      'screen': const MechanicChatScreen(),
      'icon': Icons.chat_bubble_outline,
      'label': 'Chat',
      'activeColor': Colors.blue,
    },
    {
      'screen': const MechanicProfileScreen(),
      'icon': Icons.person,
      'label': 'Profile',
      'activeColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        _navigateToScreen(context, index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: _navigationItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item['icon']),
              label: item['label'],
            ),
          )
          .toList(),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (index == currentIndex) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _navigationItems[index]['screen']),
    );
  }
}