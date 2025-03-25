// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../Direct_Chat_Screen.dart';

// // Chat list widget that fetches all chats for the current user
// class ChatList extends StatelessWidget {
//   final String currentUserId;

//   const ChatList({Key? key, required this.currentUserId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       // Query chats where the current user is a participant
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .where('participants', arrayContains: currentUserId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something in item went wrong'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No chats found'));
//         }

//         // Display all chats
//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             final chatDoc = snapshot.data!.docs[index];
//             final chatData = chatDoc.data() as Map<String, dynamic>;

//             // Extract data from chat document
//             final List<dynamic> participants = chatData['participants'] ?? [];
//             final Map<String, dynamic> participantNames =
//                 chatData['participantNames'] ?? {};

//             // Find the other participant (not the current user)
//             String otherParticipantId = '';
//             for (final participantId in participants) {
//               if (participantId != currentUserId) {
//                 otherParticipantId = participantId;
//                 break;
//               }
//             }

//             // Get display name from participantNames or use placeholder
//             final String displayName =
//                 participantNames[otherParticipantId] ?? 'Unknown User';

//             // Get last message info
//             final String lastMessage =
//                 chatData['lastMessage'] ?? 'No messages yet';
//             final Timestamp? lastMessageTime =
//                 chatData['lastMessageTime'] as Timestamp?;

//             // Format date for display
//             final String formattedDate = lastMessageTime != null
//                 ? _formatDate(lastMessageTime.toDate())
//                 : '';

//             return ChatListItem(
//               participantId: otherParticipantId,
//               initialName: displayName,
//               lastMessage: lastMessage,
//               formattedDate: formattedDate,
//             );
//           },
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     // Simple date formatting - customize as needed
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(date.year, date.month, date.day);

//     if (messageDate == today) {
//       // Format as time if today
//       return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (messageDate == yesterday) {
//       return 'Yesterday';
//     } else {
//       // Format as date
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
//to here


// // Your existing ChatListItem widget with improvements
// class ChatListItem extends StatefulWidget {
//   final String participantId;
//   final String initialName;
//   final String lastMessage;
//   final String formattedDate;

//   const ChatListItem({
//     Key? key,
//     required this.participantId,
//     required this.initialName,
//     required this.lastMessage,
//     required this.formattedDate,
//   }) : super(key: key);

//   @override
//   State<ChatListItem> createState() => _ChatListItemState();
// }

// class _ChatListItemState extends State<ChatListItem> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _displayName = '';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadParticipantName();
//   }

//   Future<void> _loadParticipantName() async {
//     try {
//       // Set initial name while loading
//       setState(() {
//         _displayName = widget.initialName;
//         _isLoading = widget.initialName == 'Unknown User';
//       });

//       // If we already have a valid name from participantNames, don't query again
//       if (widget.initialName != 'Unknown User') {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // First check Mechanic collection
//       DocumentSnapshot mechanicDoc = await _firestore
//           .collection('Mechanic')
//           .doc(widget.participantId)
//           .get();

//       if (mechanicDoc.exists) {
//         final data = mechanicDoc.data() as Map<String, dynamic>;
//         setState(() {
//           _displayName = data['fullName'] ??
//               data['displayName'] ??
//               data['name'] ??
//               widget.initialName;
//           _isLoading = false;
//         });
//         return;
//       }

//       // Then check users collection
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(widget.participantId).get();

//       if (userDoc.exists) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           _displayName = data['fullName'] ??
//               data['displayName'] ??
//               data['name'] ??
//               widget.initialName;
//           _isLoading = false;
//         });
//         return;
//       }

//       // If not found in any collection
//       if (mounted) {
//         setState(() {
//           _displayName = 'Unknown User';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading participant name: $e');
//       if (mounted) {
//         setState(() {
//           _displayName = widget.initialName != 'Loading...'
//               ? widget.initialName
//               : 'Unknown User';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final firstLetter =
//         _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

//     return ListTile(
//       leading: CircleAvatar(
//         radius: 25,
//         backgroundColor: Colors.blue,
//         child: _isLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : Text(
//                 firstLetter,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//       title: Text(
//         _isLoading ? 'Loading...' : _displayName,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Row(
//         children: [
//           const Icon(Icons.check, size: 16, color: Colors.blue),
//           const SizedBox(width: 5),
//           Expanded(
//             child: Text(
//               widget.lastMessage,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//       trailing: Text(widget.formattedDate),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DirectChatScreen(
//               userName: _displayName,
//               userId: widget.participantId,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//change 
// class ChatListItem extends StatefulWidget {
//   final String participantId;
//   final String initialName;
//   final String lastMessage;
//   final String formattedDate;

//   const ChatListItem({
//     Key? key,
//     required this.participantId,
//     required this.initialName,
//     required this.lastMessage,
//     required this.formattedDate,
//   }) : super(key: key);

//   @override
//   State<ChatListItem> createState() => _ChatListItemState();
// }

// class _ChatListItemState extends State<ChatListItem> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _displayName = '';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadParticipantName();
//   }

//   Future<void> _loadParticipantName() async {
//     if (!mounted) return;
    
//     try {
//       // Set initial name while loading
//       setState(() {
//         _displayName = widget.initialName;
//         _isLoading = widget.initialName == 'Unknown User';
//       });

//       // If we already have a valid name from participantNames, don't query again
//       if (widget.initialName != 'Unknown User') {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // First check Mechanic collection
//       DocumentSnapshot mechanicDoc = await _firestore
//           .collection('Mechanic')
//           .doc(widget.participantId)
//           .get();

//       if (mechanicDoc.exists && mechanicDoc.data() is Map<String, dynamic>) {
//         final data = mechanicDoc.data() as Map<String, dynamic>;
//         if (!mounted) return;
        
//         setState(() {
//           _displayName = data['fullName'] ??
//               data['displayName'] ??
//               data['name'] ??
//               widget.initialName;
//           _isLoading = false;
//         });
//         return;
//       }

//       // Then check users collection
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(widget.participantId).get();

//       if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         if (!mounted) return;
        
//         setState(() {
//           _displayName = data['fullName'] ??
//               data['displayName'] ??
//               data['name'] ??
//               widget.initialName;
//           _isLoading = false;
//         });
//         return;
//       }

//       // If not found in any collection
//       if (mounted) {
//         setState(() {
//           _displayName = 'Unknown User';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading participant name: $e');
//       if (mounted) {
//         setState(() {
//           _displayName = widget.initialName != 'Loading...'
//               ? widget.initialName
//               : 'Unknown User';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final firstLetter =
//         _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

//     return ListTile(
//       leading: CircleAvatar(
//         radius: 25,
//         backgroundColor: Colors.blue,
//         child: _isLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : Text(
//                 firstLetter,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//       title: Text(
//         _isLoading ? 'Loading...' : _displayName,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Row(
//         children: [
//           const Icon(Icons.check, size: 16, color: Colors.blue),
//           const SizedBox(width: 5),
//           Expanded(
//             child: Text(
//               widget.lastMessage,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//       trailing: Text(widget.formattedDate),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DirectChatScreen(
//               userName: _displayName,
//               userId: widget.participantId,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Direct_Chat_Screen.dart';

class ChatListItem extends StatefulWidget {
  final String participantId;
  final String initialName;
  final String lastMessage;
  final String formattedDate;
  final bool isFromMe;
  final bool isRead;
  final int unreadCount;

  const ChatListItem({
    Key? key,
    required this.participantId,
    required this.initialName,
    required this.lastMessage,
    required this.formattedDate,
    this.isFromMe = false,
    this.isRead = false,
    this.unreadCount = 0,
  }) : super(key: key);

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _displayName = '';
  bool _isLoading = true;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadParticipantInfo();
  }

  Future<void> _loadParticipantInfo() async {
    if (!mounted) return;
    
    try {
      // Set initial name while loading
      setState(() {
        _displayName = widget.initialName;
        _isLoading = widget.initialName == 'Unknown User';
      });

      // If we already have a valid name from participantNames, don't query again
      if (widget.initialName != 'Unknown User') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // First check Mechanic collection
      DocumentSnapshot mechanicDoc = await _firestore
          .collection('Mechanic')
          .doc(widget.participantId)
          .get();

      if (mechanicDoc.exists && mechanicDoc.data() is Map<String, dynamic>) {
        final data = mechanicDoc.data() as Map<String, dynamic>;
        if (!mounted) return;
        
        setState(() {
          _displayName = data['fullName'] ??
              data['displayName'] ??
              data['name'] ??
              widget.initialName;
          _photoUrl = data['photoUrl'];
          _isLoading = false;
        });
        return;
      }

      // Then check users collection
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.participantId).get();

      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (!mounted) return;
        
        setState(() {
          _displayName = data['fullName'] ??
              data['displayName'] ??
              data['name'] ??
              data['username'] ??
              widget.initialName;
          _photoUrl = data['photoUrl'];
          _isLoading = false;
        });
        return;
      }

      // If not found in any collection
      if (mounted) {
        setState(() {
          _displayName = 'Unknown User';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading participant info: $e');
      if (mounted) {
        setState(() {
          _displayName = widget.initialName != 'Loading...'
              ? widget.initialName
              : 'Unknown User';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate avatar color based on name
    final Color avatarColor = Colors.primaries[
      _displayName.isNotEmpty
          ? _displayName.codeUnitAt(0) % Colors.primaries.length
          : 0
    ];

    final firstLetter =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectChatScreen(
              userName: _displayName,
              userId: widget.participantId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor,
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : (_photoUrl == null
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null),
            ),
            
            const SizedBox(width: 15),
            
            // Chat content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Contact name
                      Flexible(
                        child: Text(
                          _isLoading ? 'Loading...' : _displayName,
                          style: TextStyle(
                            fontWeight: widget.unreadCount > 0 && !widget.isFromMe
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 16,
                            color: widget.unreadCount > 0 && !widget.isFromMe
                                ? Colors.black
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Time
                      Text(
                        widget.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.unreadCount > 0 && !widget.isFromMe
                              ? const Color.fromARGB(255, 208, 63, 2)
                              : Colors.grey.shade500,
                          fontWeight: widget.unreadCount > 0 && !widget.isFromMe
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Message preview row with badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message status icon (for messages I sent)
                      if (widget.isFromMe) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            widget.isRead ? Icons.done_all : Icons.done,
                            size: 16,
                            color: widget.isRead ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      
                      // Message preview with "You: " prefix if needed
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.unreadCount > 0 && !widget.isFromMe
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                            children: [
                              if (widget.isFromMe)
                                TextSpan(
                                  text: "You: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              TextSpan(
                                text: widget.lastMessage,
                                style: TextStyle(
                                  fontWeight: widget.unreadCount > 0 && !widget.isFromMe
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Unread count badge
                      if (widget.unreadCount > 0 && !widget.isFromMe)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 208, 63, 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}