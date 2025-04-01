// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_list_item.dart';

// class ChatList extends StatelessWidget {
//   final String currentUserId;
//   final String searchQuery;

//   const ChatList({
//     Key? key,
//     required this.currentUserId,
//     this.searchQuery = '',
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       // Query chats where the current user is a participant
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .where('participants', arrayContains: currentUserId)
//           .orderBy('lastMessageTime', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         // Handle error state with more details
//         if (snapshot.hasError) {
//           print('Error in chat list: ${snapshot.error}');
//           return Center(child: Text('Error loading chats: ${snapshot.error}'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No conversations yet'));
//         }

//         // Filter chats based on search query
//         final chatDocs = snapshot.data!.docs;
//         final filteredChats = searchQuery.isEmpty
//             ? chatDocs
//             : chatDocs.where((doc) {
//                 try {
//                   final data = doc.data() as Map<String, dynamic>;

//                   // Safely handle participantNames which might not exist or have the expected format
//                   final participantNames = data['participantNames'];
//                   if (participantNames == null) return false;

//                   if (participantNames is Map<String, dynamic>) {
//                     // Filter out the current user's name and find the other participant
//                     final otherParticipantName = participantNames.entries
//                         .where((entry) => entry.key != currentUserId)
//                         .map((entry) => entry.value.toString())
//                         .join();

//                     return otherParticipantName
//                         .toLowerCase()
//                         .contains(searchQuery.toLowerCase());
//                   }
//                   return false;
//                 } catch (e) {
//                   print('Error filtering chat: $e');
//                   return false;
//                 }
//               }).toList();

//         // Display all filtered chats
//         return ListView.builder(
//           itemCount: filteredChats.length,
//           itemBuilder: (context, index) {
//             try {
//               final chatDoc = filteredChats[index];
//               final chatData = chatDoc.data() as Map<String, dynamic>;

//               // Safely extract data from chat document
//               final List<dynamic> participants = chatData['participants'] ?? [];

//               // Safely handle participantNames
//               Map<String, dynamic> participantNames = {};
//               if (chatData['participantNames'] is Map) {
//                 participantNames = Map<String, dynamic>.from(chatData['participantNames']);
//               }

//               // Find the other participant (not the current user)
//               String otherParticipantId = '';
//               for (final participantId in participants) {
//                 if (participantId != currentUserId) {
//                   otherParticipantId = participantId;
//                   break;
//                 }
//               }

//               // Get display name from participantNames or use placeholder
//               final String displayName =
//                   participantNames[otherParticipantId] ?? 'Unknown User';

//               // Get last message info with safe handling
//               final String lastMessage =
//                   chatData['lastMessage']?.toString() ?? 'No messages yet';
//               final Timestamp? lastMessageTime =
//                   chatData['lastMessageTime'] as Timestamp?;

//               // Format date for display
//               final String formattedDate = lastMessageTime != null
//                   ? _formatDate(lastMessageTime.toDate())
//                   : '';

//               return ChatListItem(
//                 participantId: otherParticipantId,
//                 initialName: displayName,
//                 lastMessage: lastMessage,
//                 formattedDate: formattedDate,
//               );
//             } catch (e) {
//               print('Error rendering chat item at index $index: $e');
//               return ListTile(
//                 title: const Text('Error loading chat'),
//                 subtitle: Text(e.toString()),
//               );
//             }
//           },
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     // Your existing date formatting logic
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(date.year, date.month, date.day);

//     if (messageDate == today) {
//       return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (messageDate == yesterday) {
//       return 'Yesterday';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Make sure to add this package to pubspec.yaml
import 'chat_list_item.dart';

class ChatList extends StatelessWidget {
  final String currentUserId;
  final String searchQuery;

  const ChatList({
    Key? key,
    required this.currentUserId,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Query chats where the current user is a participant
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Handle error state with more details
        if (snapshot.hasError) {
          print('Error in chat list: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading chats',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 208, 63, 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Start a chat with a mechanic to get help with your vehicle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter chats based on search query
        final chatDocs = snapshot.data!.docs;
        final filteredChats = searchQuery.isEmpty
            ? chatDocs
            : chatDocs.where((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;

                  // Search in participant names
                  final participantNames = data['participantNames'];
                  if (participantNames is Map<String, dynamic>) {
                    // Get the other participant's name
                    final otherParticipantName = participantNames.entries
                        .where((entry) => entry.key != currentUserId)
                        .map((entry) => entry.value.toString())
                        .join();

                    // Also search in the last message
                    final lastMessage =
                        (data['lastMessage'] ?? '').toString().toLowerCase();

                    return otherParticipantName
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        lastMessage.contains(searchQuery.toLowerCase());
                  }
                  return false;
                } catch (e) {
                  print('Error filtering chat: $e');
                  return false;
                }
              }).toList();

        if (filteredChats.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 70,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Display all filtered chats
        return ListView.separated(
          itemCount: filteredChats.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            try {
              final chatDoc = filteredChats[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              // Extract data from chat document
              final List<dynamic> participants = chatData['participants'] ?? [];

              // Find the other participant (not the current user)
              String otherParticipantId = '';
              for (final participantId in participants) {
                if (participantId != currentUserId) {
                  otherParticipantId = participantId;
                  break;
                }
              }

              // Safely handle participantNames
              Map<String, dynamic> participantNames = {};
              if (chatData['participantNames'] is Map) {
                participantNames =
                    Map<String, dynamic>.from(chatData['participantNames']);
              }

              // Get display name from participantNames or use placeholder
              final String displayName =
                  participantNames[otherParticipantId] ?? 'Unknown User';

              // Get last message info with safe handling
              final String lastMessage =
                  chatData['lastMessage']?.toString() ?? 'No messages yet';
              final Timestamp? lastMessageTime =
                  chatData['lastMessageTime'] as Timestamp?;
              final String lastMessageSenderId =
                  chatData['lastMessageSenderId']?.toString() ?? '';
              final bool isFromMe = lastMessageSenderId == currentUserId;
              final int unreadCount = chatData['unreadCount'] ?? 0;
              final bool isRead = chatData['isRead'] ?? false;

              // Format date for display
              final String formattedDate = lastMessageTime != null
                  ? _formatChatDate(lastMessageTime.toDate())
                  : '';

              return ChatListItem(
                participantId: otherParticipantId,
                initialName: displayName,
                lastMessage: lastMessage,
                formattedDate: formattedDate,
                isFromMe: isFromMe,
                isRead: isRead,
                unreadCount: unreadCount,
              );
            } catch (e) {
              print('Error rendering chat item at index $index: $e');
              return ListTile(
                title: const Text('Error loading chat'),
                subtitle: Text(e.toString()),
              );
            }
          },
        );
      },
    );
  }

  String _formatChatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(date);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date); // Day of week (Mon, Tue, etc.)
    } else {
      return DateFormat('M/d/yy').format(date);
    }
  }
}
