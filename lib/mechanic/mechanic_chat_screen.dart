import 'package:flutter/material.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/mechanic_navbar.dart';
import '../costumer/direct_chat_screen.dart';

class MechanicChatScreen extends StatefulWidget {
  const MechanicChatScreen({super.key});

  @override
  State<MechanicChatScreen> createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  int _currentIndex = 1; // Chat is index 1 in mechanic navigation

  final List<Map<String, String>> chats = [
    {
      'name': 'Mohammed Customer',
      'message': 'When can you check my car?',
      'date': '10/10/2024',
      'image': 'assets/images/user1.png'
    },
    {
      'name': 'Sara Customer',
      'message': 'Thanks for the quick service',
      'date': '10/10/2024',
      'image': 'assets/images/user2.png'
    },
    {
      'name': 'Khalid Customer',
      'message': 'How much for the repair?',
      'date': '10/09/2024',
      'image': 'assets/images/user3.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(
        pageName: 'Mechanic Chat',
        color: Color.fromARGB(255, 208, 63, 2),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
      bottomNavigationBar: MechanicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Customers',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: chats.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(chat['image']!),
            ),
            title: Text(
              chat['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      chat['message']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Text(
              chat['date']!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectChatScreen(
                    userName: chat['name'] ?? 'Unknown',
                    userId: chat['name'] ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
