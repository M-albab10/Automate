import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:automate/bars/app_bar.dart';
import '../bars/navbar.dart';
import 'widgets/chat_list.dart'; // Import the updated ChatList widget

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: const AppBarWidget(pageName: 'Chat'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Chat list with search filtering
          Expanded(
            child: ChatList(
              currentUserId: currentUserId,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}
