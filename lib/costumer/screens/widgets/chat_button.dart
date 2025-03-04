import 'package:flutter/material.dart';
import '../../direct_chat_screen.dart';

class ChatButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String mechanicName;
  final String mechanicId;

  const ChatButton({
    Key? key,
    this.onPressed,
    required this.mechanicName,
    required this.mechanicId,
  }) : super(key: key);

  void _navigateToChat(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DirectChatScreen(
            userName: mechanicName,
            userId: mechanicId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToChat(context),
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text(
          'Chat with Mechanic',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
