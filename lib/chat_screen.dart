import 'package:automate/app_bar.dart';
import 'package:flutter/material.dart';
import 'navbar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {
        'name': 'Ahmad Ali Khan',
        'message': 'We agreed ?',
        'date': '10/10/2024',
        'image': 'assets/images/user1.png'
      },
      {
        'name': 'Abdullah Alqahtani',
        'message': 'انا باجيب القطع معايك',
        'date': '10/10/2024',
        'image': 'assets/images/user2.png'
      },
      {
        'name': 'Hamad Allaebon',
        'message': 'بدون القطع كم ؟',
        'date': '10/09/2024',
        'image': 'assets/images/user3.png'
      },
    ];

    return Scaffold(
      appBar: const AppBarWidget(pageName: 'Chat'),
      body: Column(
        children: [
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
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(chat['image']!),
                  ),
                  title: Text(
                    chat['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.blue),
                      const SizedBox(width: 5),
                      Expanded(child: Text(chat['message']!)),
                    ],
                  ),
                  trailing: Text(chat['date']!),
                  onTap: () {
                    // Action to open chat
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation tap
        },
      ),
    );
  }
}
