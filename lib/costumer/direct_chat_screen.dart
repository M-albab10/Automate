// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class DirectChatScreen extends StatefulWidget {
//   final String userName;
//   final String userId; // Unique user ID for chat
//   // final String userImage; // Profile image URL or asset path

//   const DirectChatScreen({Key? key, required this.userName, required this.userId
//       // required this.userImage,
//       })
//       : super(key: key);

//   @override
//   State<DirectChatScreen> createState() => _DirectChatScreenState();
// }

// class _DirectChatScreenState extends State<DirectChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _chatId;

//   @override
//   void initState() {
//     super.initState();
//     _getChatId();
//   }

//   Future<void> _getChatId() async {
//     if (_auth.currentUser == null) return;

//     // Try to find existing chat between these two users
//     final querySnapshot = await _firestore
//         .collection('chats')
//         .where('participants', arrayContains: _auth.currentUser!.uid)
//         .get();

//     for (var doc in querySnapshot.docs) {
//       List<dynamic> participants = doc['participants'];
//       if (participants.contains(widget.userId)) {
//         setState(() {
//           _chatId = doc.id;
//         });
//         return;
//       }
//     }

//     // If no chat exists, create a new one
//     if (_chatId == null) {
//       final newChatRef = _firestore.collection('chats').doc();

//       // Try to get current user's name - check both users and Mechanic collections
//       String currentUserName = 'Me';
//       try {
//         // First check users collection
//         DocumentSnapshot currentUserDoc = await _firestore
//             .collection('users')
//             .doc(_auth.currentUser!.uid)
//             .get();

//         if (currentUserDoc.exists) {
//           Map<String, dynamic> data =
//               currentUserDoc.data() as Map<String, dynamic>;
//           currentUserName =
//               data['fullName'] ?? data['displayName'] ?? data['name'] ?? 'Me';
//         }
//       } catch (e) {
//         print('Error getting current user name: $e');
//       }

//       // Try to get mechanic's name if it wasn't passed correctly
//       String otherUserName = widget.userName;
//       if (otherUserName == 'Loading...' || otherUserName.isEmpty) {
//         try {
//           // First check Mechanic collection
//           DocumentSnapshot mechanicDoc =
//               await _firestore.collection('Mechanic').doc(widget.userId).get();

//           if (mechanicDoc.exists) {
//             Map<String, dynamic> data =
//                 mechanicDoc.data() as Map<String, dynamic>;
//             otherUserName = data['fullName'] ??
//                 data['displayName'] ??
//                 data['name'] ??
//                 'Unknown Mechanic';
//           } else {
//             // Check users collection as fallback
//             DocumentSnapshot userDoc =
//                 await _firestore.collection('users').doc(widget.userId).get();

//             if (userDoc.exists) {
//               Map<String, dynamic> data =
//                   userDoc.data() as Map<String, dynamic>;
//               otherUserName = data['fullName'] ??
//                   data['displayName'] ??
//                   data['name'] ??
//                   'Unknown User';
//             }
//           }
//         } catch (e) {
//           print('Error getting other user name: $e');
//         }
//       }

//       // Create the chat document
//       await newChatRef.set({
//         'participants': [_auth.currentUser!.uid, widget.userId],
//         'participantNames': {
//           _auth.currentUser!.uid: currentUserName,
//           widget.userId: otherUserName
//         },
//         'lastMessage': '',
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       setState(() {
//         _chatId = newChatRef.id;
//       });
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty ||
//         _chatId == null ||
//         _auth.currentUser == null) {
//       return;
//     }

//     final messageText = _messageController.text.trim();
//     _messageController.clear();

//     // Add message to messages subcollection
//     await _firestore
//         .collection('chats')
//         .doc(_chatId)
//         .collection('messages')
//         .add({
//       'text': messageText,
//       'senderId': _auth.currentUser!.uid,
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     // Update the chat document with last message info
//     await _firestore.collection('chats').doc(_chatId).update({
//       'lastMessage': messageText,
//       'lastMessageTime': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue, // Blue background
//         elevation: 1,
//         iconTheme:
//             const IconThemeData(color: Colors.white), // White back button
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.blue.shade700,
//               child: Text(
//                 widget.userName.isNotEmpty
//                     ? widget.userName[0].toUpperCase()
//                     : '?',
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               widget.userName,
//               style: const TextStyle(
//                 color: Colors.white, // White text
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _chatId == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('chats')
//                         .doc(_chatId)
//                         .collection('messages')
//                         .orderBy('timestamp', descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(
//                           child:
//                               Text('No messages yet. Start the conversation!'),
//                         );
//                       }

//                       final messages = snapshot.data!.docs;
//                       return ListView.builder(
//                         reverse: true,
//                         padding: const EdgeInsets.all(10),
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           final message =
//                               messages[index].data() as Map<String, dynamic>;
//                           final isMe =
//                               message['senderId'] == _auth.currentUser?.uid;

//                           return _buildMessageBubble({
//                             'text': message['text'] ?? '',
//                             'isMe': isMe,
//                             'timestamp': message['timestamp'] as Timestamp?,
//                           });
//                         },
//                       );
//                     },
//                   ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> message) {
//     bool isMe = message['isMe'];
//     Timestamp? timestamp = message['timestamp'];
//     String timeText = '';

//     if (timestamp != null) {
//       final dateTime = timestamp.toDate();
//       timeText =
//           '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     }

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue[300] : Colors.grey[300],
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               message['text'],
//               style: const TextStyle(fontSize: 16),
//             ),
//             if (timeText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   timeText,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: Colors.grey.shade300)),
//         color: Colors.white,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: "Type a message...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 10),
//           IconButton(
//             icon: const Icon(Icons.send, color: Colors.blue),
//             onPressed: _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }
// }

//seconf change

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import '../bars/app_bar.dart';

// class DirectChatScreen extends StatefulWidget {
//   final String userName;
//   final String userId;
//   final bool isMechanic;

//   const DirectChatScreen({
//     Key? key,
//     required this.userName,
//     required this.userId,
//     this.isMechanic = false,
//   }) : super(key: key);

//   @override
//   State<DirectChatScreen> createState() => _DirectChatScreenState();
// }

// class _DirectChatScreenState extends State<DirectChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isSending = false;
//   String? _currentUserId;
//   String? _conversationId;

//   @override
//   void initState() {
//     super.initState();
//     _currentUserId = _auth.currentUser?.uid;
//     _setupConversation();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Create a unique conversation ID from two user IDs
//   String _getConversationId(String userId1, String userId2) {
//     List<String> ids = [userId1, userId2]..sort();
//     return "${ids[0]}_${ids[1]}";
//   }

//   void _setupConversation() async {
//     if (_currentUserId == null) return;
    
//     // Generate conversation ID
//     _conversationId = _getConversationId(_currentUserId!, widget.userId);
    
//     // Mark messages as read when opening chat
//     _markMessagesAsRead();
//   }

//   void _markMessagesAsRead() async {
//     if (_conversationId == null || _currentUserId == null) return;
    
//     try {
//       // Get unread messages sent by the other user
//       final unreadMessages = await _firestore
//           .collection('conversations')
//           .doc(_conversationId)
//           .collection('messages')
//           .where('senderId', isEqualTo: widget.userId)
//           .where('isRead', isEqualTo: false)
//           .get();
      
//       // Create a batch write
//       final batch = _firestore.batch();
      
//       // Update each message
//       for (var doc in unreadMessages.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
      
//       // Reset unread count in conversation metadata
//       if (unreadMessages.docs.isNotEmpty) {
//         batch.update(
//           _firestore.collection('conversations').doc(_conversationId),
//           {'unreadCount': 0}
//         );
//       }
      
//       await batch.commit();
//     } catch (e) {
//       print('Error marking messages as read: $e');
//     }
//   }

//   void _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isEmpty || _currentUserId == null || _conversationId == null) return;
    
//     setState(() {
//       _isSending = true;
//     });

//     try {
//       // Create a reference for the new message
//       final messageRef = _firestore
//           .collection('conversations')
//           .doc(_conversationId)
//           .collection('messages')
//           .doc();
      
//       // Message data
//       final messageData = {
//         'message': message,
//         'senderId': _currentUserId,
//         'receiverId': widget.userId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       };
      
//       // Update conversation metadata
//       await _firestore.collection('conversations').doc(_conversationId).set({
//         'participants': [_currentUserId, widget.userId],
//         'lastMessage': message,
//         'lastMessageTimestamp': FieldValue.serverTimestamp(),
//         'lastMessageSenderId': _currentUserId,
//         'unreadCount': FieldValue.increment(1),
//       }, SetOptions(merge: true));
      
//       // Add the message
//       await messageRef.set(messageData);
      
//       // Clear input
//       _messageController.clear();
      
//       // Scroll to bottom
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSending = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appBarColor = widget.isMechanic
//         ? const Color.fromARGB(255, 208, 63, 2)
//         : Colors.blue;
        
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBarWidget(
//         pageName: widget.userName,
//         color: appBarColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _buildMessageList(),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     if (_conversationId == null || _currentUserId == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('conversations')
//           .doc(_conversationId)
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final messages = snapshot.data?.docs ?? [];

//         if (messages.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 70,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No messages yet',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start the conversation!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           controller: _scrollController,
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             final message = messages[index].data() as Map<String, dynamic>;
//             final isFromMe = message['senderId'] == _currentUserId;
//             final messageText = message['message'] as String;
//             final timestamp = message['timestamp'] as Timestamp?;
//             final messageTime = timestamp?.toDate() ?? DateTime.now();
            
//             // Check if we should show date header
//             final showDate = index == messages.length - 1 || 
//                 _shouldShowDateHeader(
//                   messages[index], 
//                   messages[index + 1]
//                 );
            
//             return Column(
//               children: [
//                 if (showDate) 
//                   _buildDateHeader(messageTime),
//                 _buildMessageBubble(
//                   messageText, 
//                   isFromMe, 
//                   messageTime
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildDateHeader(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(today.year, today.month, today.day - 1);
//     final messageDate = DateTime(date.year, date.month, date.day);
    
//     String dateText;
//     if (messageDate == today) {
//       dateText = 'Today';
//     } else if (messageDate == yesterday) {
//       dateText = 'Yesterday';
//     } else if (now.difference(date).inDays < 7) {
//       dateText = DateFormat('EEEE').format(date); // e.g., Monday
//     } else {
//       dateText = DateFormat('MMMM d, y').format(date); // e.g., January 1, 2023
//     }
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             dateText,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[800],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool _shouldShowDateHeader(DocumentSnapshot current, DocumentSnapshot next) {
//     final currentData = current.data() as Map<String, dynamic>;
//     final nextData = next.data() as Map<String, dynamic>;
    
//     final currentTimestamp = currentData['timestamp'] as Timestamp?;
//     final nextTimestamp = nextData['timestamp'] as Timestamp?;
    
//     if (currentTimestamp == null || nextTimestamp == null) return true;
    
//     final currentDate = currentTimestamp.toDate();
//     final nextDate = nextTimestamp.toDate();
    
//     return currentDate.year != nextDate.year ||
//            currentDate.month != nextDate.month ||
//            currentDate.day != nextDate.day;
//   }

//   Widget _buildMessageBubble(String message, bool isFromMe, DateTime time) {
//     final bubbleColor = isFromMe
//         ? (widget.isMechanic 
//             ? const Color.fromARGB(255, 208, 63, 2) 
//             : Colors.blue[600])
//         : Colors.white;
    
//     final textColor = isFromMe ? Colors.white : Colors.black87;
//     final timeColor = isFromMe 
//         ? Colors.white.withAlpha(179) 
//         : Colors.grey[600];
    
//     final bubbleAlignment = isFromMe 
//         ? Alignment.centerRight 
//         : Alignment.centerLeft;
    
//     final bubbleMargin = EdgeInsets.only(
//       top: 4,
//       bottom: 4,
//       left: isFromMe ? 80 : 0,
//       right: isFromMe ? 0 : 80,
//     );
    
//     final bubbleRadius = BorderRadius.only(
//       topLeft: const Radius.circular(16),
//       topRight: const Radius.circular(16),
//       bottomLeft: Radius.circular(isFromMe ? 16 : 4),
//       bottomRight: Radius.circular(isFromMe ? 4 : 16),
//     );
    
//     return Align(
//       alignment: bubbleAlignment,
//       child: Container(
//         margin: bubbleMargin,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: bubbleColor,
//           borderRadius: bubbleRadius,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withAlpha(25),
//               blurRadius: 3,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               message,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               DateFormat('h:mm a').format(time),
//               style: TextStyle(
//                 color: timeColor,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     final sendButtonColor = widget.isMechanic
//         ? const Color.fromARGB(255, 208, 63, 2)
//         : Colors.blue;
        
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: TextField(
//                   controller: _messageController,
//                   decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   maxLines: 3,
//                   minLines: 1,
//                   textCapitalization: TextCapitalization.sentences,
//                   textInputAction: TextInputAction.send,
//                   onSubmitted: (_) => _sendMessage(),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             _isSending
//                 ? SizedBox(
//                     width: 48,
//                     height: 48,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(sendButtonColor),
//                       ),
//                     ),
//                   )
//                 : InkWell(
//                     onTap: _sendMessage,
//                     borderRadius: BorderRadius.circular(24),
//                     child: Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: sendButtonColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//3rd change

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import '../bars/app_bar.dart';

// class DirectChatScreen extends StatefulWidget {
//   final String userName;
//   final String userId;
//   final bool isMechanic;

//   const DirectChatScreen({
//     Key? key,
//     required this.userName,
//     required this.userId,
//     this.isMechanic = false,
//   }) : super(key: key);

//   @override
//   State<DirectChatScreen> createState() => _DirectChatScreenState();
// }

// class _DirectChatScreenState extends State<DirectChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isSending = false;
//   String? _currentUserId;
//   String? _conversationId;

//   @override
//   void initState() {
//     super.initState();
//     _currentUserId = _auth.currentUser?.uid;
//     _setupConversation();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Create a unique conversation ID from two user IDs
//   String _getConversationId(String userId1, String userId2) {
//     List<String> ids = [userId1, userId2]..sort();
//     return "${ids[0]}_${ids[1]}";
//   }

//   void _setupConversation() async {
//     if (_currentUserId == null) return;
    
//     // Generate conversation ID
//     _conversationId = _getConversationId(_currentUserId!, widget.userId);
    
//     // Mark messages as read when opening chat
//     _markMessagesAsRead();
//   }

//   void _markMessagesAsRead() async {
//     if (_conversationId == null || _currentUserId == null) return;
    
//     try {
//       // Get unread messages sent by the other user
//       final unreadMessages = await _firestore
//           .collection('chats')
//           .doc(_conversationId)
//           .collection('messages')
//           .where('senderId', isEqualTo: widget.userId)
//           .where('isRead', isEqualTo: false)
//           .get();
      
//       // Create a batch write
//       final batch = _firestore.batch();
      
//       // Update each message
//       for (var doc in unreadMessages.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
      
//       // Reset unread count in conversation metadata
//       if (unreadMessages.docs.isNotEmpty) {
//         batch.update(
//           _firestore.collection('chats').doc(_conversationId),
//           {'unreadCount': 0}
//         );
//       }
      
//       await batch.commit();
//     } catch (e) {
//       print('Error marking messages as read: $e');
//     }
//   }

//   void _sendMessage() async {
//     final message = _messageController.text.trim();
//     if (message.isEmpty || _currentUserId == null || _conversationId == null) return;
    
//     setState(() {
//       _isSending = true;
//     });

//     try {
//       // Create a reference for the new message
//       final messageRef = _firestore
//           .collection('chats')
//           .doc(_conversationId)
//           .collection('messages')
//           .doc();
      
//       // Message data
//       final messageData = {
//         'message': message,
//         'senderId': _currentUserId,
//         'receiverId': widget.userId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       };
      
//       // Update conversation metadata
//       await _firestore.collection('chats').doc(_conversationId).set({
//         'participants': [_currentUserId, widget.userId],
//         'lastMessage': message,
//         'lastMessageTimestamp': FieldValue.serverTimestamp(),
//         'lastMessageSenderId': _currentUserId,
//         'unreadCount': FieldValue.increment(1),
//       }, SetOptions(merge: true));
      
//       // Add the message
//       await messageRef.set(messageData);
      
//       // Clear input
//       _messageController.clear();
      
//       // Scroll to bottom
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSending = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appBarColor = widget.isMechanic
//         ? const Color.fromARGB(255, 208, 63, 2)
//         : Colors.blue;
        
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBarWidget(
//         pageName: widget.userName,
//         color: appBarColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _buildMessageList(),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     if (_conversationId == null || _currentUserId == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('chats')
//           .doc(_conversationId)
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final messages = snapshot.data?.docs ?? [];

//         if (messages.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 70,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No messages yet',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start the conversation!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           controller: _scrollController,
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             final message = messages[index].data() as Map<String, dynamic>;
//             final isFromMe = message['senderId'] == _currentUserId;
//             final messageText = message['message'] as String;
//             final timestamp = message['timestamp'] as Timestamp?;
//             final messageTime = timestamp?.toDate() ?? DateTime.now();
            
//             // Check if we should show date header
//             bool showDate = index == messages.length - 1;
//             if (index < messages.length - 1) {
//               showDate = showDate || _shouldShowDateHeader(
//                 messages[index], 
//                 messages[index + 1]
//               );
//             }
            
//             return Column(
//               children: [
//                 if (showDate) 
//                   _buildDateHeader(messageTime),
//                 _buildMessageBubble(
//                   messageText, 
//                   isFromMe, 
//                   messageTime
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildDateHeader(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(today.year, today.month, today.day - 1);
//     final messageDate = DateTime(date.year, date.month, date.day);
    
//     String dateText;
//     if (messageDate == today) {
//       dateText = 'Today';
//     } else if (messageDate == yesterday) {
//       dateText = 'Yesterday';
//     } else if (now.difference(date).inDays < 7) {
//       dateText = DateFormat('EEEE').format(date); // e.g., Monday
//     } else {
//       dateText = DateFormat('MMMM d, y').format(date); // e.g., January 1, 2023
//     }
    
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             dateText,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[800],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool _shouldShowDateHeader(DocumentSnapshot current, DocumentSnapshot next) {
//     // Make sure both documents exist and have data
//     if (current.data() == null || next.data() == null) return true;
    
//     final currentData = current.data() as Map<String, dynamic>;
//     final nextData = next.data() as Map<String, dynamic>;
    
//     final currentTimestamp = currentData['timestamp'] as Timestamp?;
//     final nextTimestamp = nextData['timestamp'] as Timestamp?;
    
//     if (currentTimestamp == null || nextTimestamp == null) return true;
    
//     final currentDate = currentTimestamp.toDate();
//     final nextDate = nextTimestamp.toDate();
    
//     return currentDate.year != nextDate.year ||
//            currentDate.month != nextDate.month ||
//            currentDate.day != nextDate.day;
//   }

//   Widget _buildMessageBubble(String message, bool isFromMe, DateTime time) {
//     final bubbleColor = isFromMe
//         ? (widget.isMechanic 
//             ? const Color.fromARGB(255, 208, 63, 2) 
//             : Colors.blue[600])
//         : Colors.white;
    
//     final textColor = isFromMe ? Colors.white : Colors.black87;
//     final timeColor = isFromMe 
//         ? Colors.white.withOpacity(0.7) 
//         : Colors.grey[600];
    
//     final bubbleAlignment = isFromMe 
//         ? Alignment.centerRight 
//         : Alignment.centerLeft;
    
//     final bubbleMargin = EdgeInsets.only(
//       top: 4,
//       bottom: 4,
//       left: isFromMe ? 80 : 0,
//       right: isFromMe ? 0 : 80,
//     );
    
//     final bubbleRadius = BorderRadius.only(
//       topLeft: const Radius.circular(16),
//       topRight: const Radius.circular(16),
//       bottomLeft: Radius.circular(isFromMe ? 16 : 4),
//       bottomRight: Radius.circular(isFromMe ? 4 : 16),
//     );
    
//     return Align(
//       alignment: bubbleAlignment,
//       child: Container(
//         margin: bubbleMargin,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: bubbleColor,
//           borderRadius: bubbleRadius,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 3,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               message,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               DateFormat('h:mm a').format(time),
//               style: TextStyle(
//                 color: timeColor,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     final sendButtonColor = widget.isMechanic
//         ? const Color.fromARGB(255, 208, 63, 2)
//         : Colors.blue;
        
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: TextField(
//                   controller: _messageController,
//                   decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   maxLines: 3,
//                   minLines: 1,
//                   textCapitalization: TextCapitalization.sentences,
//                   textInputAction: TextInputAction.send,
//                   onSubmitted: (_) => _sendMessage(),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             _isSending
//                 ? SizedBox(
//                     width: 48,
//                     height: 48,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(sendButtonColor),
//                       ),
//                     ),
//                   )
//                 : InkWell(
//                     onTap: _sendMessage,
//                     borderRadius: BorderRadius.circular(24),
//                     child: Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: sendButtonColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../bars/app_bar.dart';

class DirectChatScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final bool isMechanic;

  const DirectChatScreen({
    Key? key,
    required this.userName,
    required this.userId,
    this.isMechanic = false,
  }) : super(key: key);

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSending = false;
  String? _currentUserId;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _setupConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Create a unique conversation ID from two user IDs
  String _getConversationId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return "${ids[0]}_${ids[1]}";
  }

  void _setupConversation() async {
    if (_currentUserId == null) return;
    
    // Generate conversation ID
    _conversationId = _getConversationId(_currentUserId!, widget.userId);
    
    // Mark messages as read when opening chat
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    if (_conversationId == null || _currentUserId == null) return;
    
    try {
      // Get unread messages sent by the other user
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(_conversationId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      // Create a batch write
      final batch = _firestore.batch();
      
      // Update each message
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      // Reset unread count in conversation metadata
      if (unreadMessages.docs.isNotEmpty) {
        batch.update(
          _firestore.collection('chats').doc(_conversationId),
          {'unreadCount': 0}
        );
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentUserId == null || _conversationId == null) return;
    
    setState(() {
      _isSending = true;
    });

    try {
      // Create a reference for the new message
      final messageRef = _firestore
          .collection('chats')
          .doc(_conversationId)
          .collection('messages')
          .doc();
      
      // Message data
      final messageData = {
        'message': message,
        'senderId': _currentUserId,
        'receiverId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      
      // Get current user and other user name for participantNames
      String currentUserName = "Unknown";
      String otherUserName = widget.userName;
      
      try {
        final currentUserDoc = await _firestore.collection('users').doc(_currentUserId).get();
        if (currentUserDoc.exists) {
          currentUserName = currentUserDoc.data()?['username'] ?? "Unknown";
        }
      } catch (e) {
        print('Error getting current user name: $e');
      }
      
      // Update conversation metadata
      await _firestore.collection('chats').doc(_conversationId).set({
        'participants': [_currentUserId, widget.userId],
        'participantNames': {
          _currentUserId: currentUserName,
          widget.userId: otherUserName
        },
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(), // Changed from lastMessageTimestamp
        'lastMessageSenderId': _currentUserId,
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      // Add the message
      await messageRef.set(messageData);
      
      // Clear input
      _messageController.clear();
      
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = widget.isMechanic
        ? const Color.fromARGB(255, 208, 63, 2)
        : Colors.blue;
        
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBarWidget(
        pageName: widget.userName,
        color: appBarColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_conversationId == null || _currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(_conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 70,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isFromMe = message['senderId'] == _currentUserId;
            final messageText = message['message'] as String;
            final timestamp = message['timestamp'] as Timestamp?;
            final messageTime = timestamp?.toDate() ?? DateTime.now();
            
            // Check if we should show date header
            bool showDate = index == messages.length - 1;
            if (index < messages.length - 1) {
              showDate = showDate || _shouldShowDateHeader(
                messages[index], 
                messages[index + 1]
              );
            }
            
            return Column(
              children: [
                if (showDate) 
                  _buildDateHeader(messageTime),
                _buildMessageBubble(
                  messageText, 
                  isFromMe, 
                  messageTime
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      dateText = DateFormat('EEEE').format(date); // e.g., Monday
    } else {
      dateText = DateFormat('MMMM d, y').format(date); // e.g., January 1, 2023
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(DocumentSnapshot current, DocumentSnapshot next) {
    // Make sure both documents exist and have data
    if (current.data() == null || next.data() == null) return true;
    
    final currentData = current.data() as Map<String, dynamic>;
    final nextData = next.data() as Map<String, dynamic>;
    
    final currentTimestamp = currentData['timestamp'] as Timestamp?;
    final nextTimestamp = nextData['timestamp'] as Timestamp?;
    
    if (currentTimestamp == null || nextTimestamp == null) return true;
    
    final currentDate = currentTimestamp.toDate();
    final nextDate = nextTimestamp.toDate();
    
    return currentDate.year != nextDate.year ||
           currentDate.month != nextDate.month ||
           currentDate.day != nextDate.day;
  }

  Widget _buildMessageBubble(String message, bool isFromMe, DateTime time) {
    final bubbleColor = isFromMe
        ? (widget.isMechanic 
            ? const Color.fromARGB(255, 208, 63, 2) 
            : Colors.blue[600])
        : Colors.white;
    
    final textColor = isFromMe ? Colors.white : Colors.black87;
    final timeColor = isFromMe 
        ? Colors.white.withAlpha(178) 
        : Colors.grey[600];
    
    final bubbleAlignment = isFromMe 
        ? Alignment.centerRight 
        : Alignment.centerLeft;
    
    final bubbleMargin = EdgeInsets.only(
      top: 4,
      bottom: 4,
      left: isFromMe ? 80 : 0,
      right: isFromMe ? 0 : 80,
    );
    
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isFromMe ? 16 : 4),
      bottomRight: Radius.circular(isFromMe ? 4 : 16),
    );
    
    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: bubbleMargin,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: bubbleRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(time),
              style: TextStyle(
                color: timeColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final sendButtonColor = widget.isMechanic
        ? const Color.fromARGB(255, 208, 63, 2)
        : Colors.blue;
        
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSending
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(sendButtonColor),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sendButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}