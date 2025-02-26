import 'package:flutter/material.dart';

class DirectChatScreen extends StatefulWidget {
  final String userName;
  final String userId; // Unique user ID for chat
  // final String userImage; // Profile image URL or asset path

  const DirectChatScreen({Key? key, required this.userName, required this.userId
      // required this.userImage,
      })
      : super(key: key);

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages =
      []; // Temporary local storage for messages

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
          'timestamp': DateTime.now(),
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue background
        elevation: 1,
        iconTheme:
            const IconThemeData(color: Colors.white), // White back button
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              // backgroundImage: AssetImage(widget.userImage), // Profile picture
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message['text'],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
