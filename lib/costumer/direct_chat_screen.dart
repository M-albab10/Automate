import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _getChatId();
  }

  Future<void> _getChatId() async {
    if (_auth.currentUser == null) return;

    // Try to find existing chat between these two users
    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _auth.currentUser!.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      List<dynamic> participants = doc['participants'];
      if (participants.contains(widget.userId)) {
        setState(() {
          _chatId = doc.id;
        });
        return;
      }
    }

    // If no chat exists, create a new one
    if (_chatId == null) {
      final newChatRef = _firestore.collection('chats').doc();

      // Try to get current user's name - check both users and Mechanic collections
      String currentUserName = 'Me';
      try {
        // First check users collection
        DocumentSnapshot currentUserDoc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (currentUserDoc.exists) {
          Map<String, dynamic> data =
              currentUserDoc.data() as Map<String, dynamic>;
          currentUserName =
              data['fullName'] ?? data['displayName'] ?? data['name'] ?? 'Me';
        }
      } catch (e) {
        print('Error getting current user name: $e');
      }

      // Try to get mechanic's name if it wasn't passed correctly
      String otherUserName = widget.userName;
      if (otherUserName == 'Loading...' || otherUserName.isEmpty) {
        try {
          // First check Mechanic collection
          DocumentSnapshot mechanicDoc =
              await _firestore.collection('Mechanic').doc(widget.userId).get();

          if (mechanicDoc.exists) {
            Map<String, dynamic> data =
                mechanicDoc.data() as Map<String, dynamic>;
            otherUserName = data['fullName'] ??
                data['displayName'] ??
                data['name'] ??
                'Unknown Mechanic';
          } else {
            // Check users collection as fallback
            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(widget.userId).get();

            if (userDoc.exists) {
              Map<String, dynamic> data =
                  userDoc.data() as Map<String, dynamic>;
              otherUserName = data['fullName'] ??
                  data['displayName'] ??
                  data['name'] ??
                  'Unknown User';
            }
          }
        } catch (e) {
          print('Error getting other user name: $e');
        }
      }

      // Create the chat document
      await newChatRef.set({
        'participants': [_auth.currentUser!.uid, widget.userId],
        'participantNames': {
          _auth.currentUser!.uid: currentUserName,
          widget.userId: otherUserName
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _chatId = newChatRef.id;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _chatId == null ||
        _auth.currentUser == null) {
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Add message to messages subcollection
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': _auth.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the chat document with last message info
    await _firestore.collection('chats').doc(_chatId).update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
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
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.shade700,
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(_chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child:
                              Text('No messages yet. Start the conversation!'),
                        );
                      }

                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe =
                              message['senderId'] == _auth.currentUser?.uid;

                          return _buildMessageBubble({
                            'text': message['text'] ?? '',
                            'isMe': isMe,
                            'timestamp': message['timestamp'] as Timestamp?,
                          });
                        },
                      );
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
    Timestamp? timestamp = message['timestamp'];
    String timeText = '';

    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      timeText =
          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message['text'],
              style: const TextStyle(fontSize: 16),
            ),
            if (timeText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
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
              onSubmitted: (_) => _sendMessage(),
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
