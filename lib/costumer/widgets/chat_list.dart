import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          return Center(child: Text('Error loading chats: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }

        // Filter chats based on search query
        final chatDocs = snapshot.data!.docs;
        final filteredChats = searchQuery.isEmpty
            ? chatDocs
            : chatDocs.where((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Safely handle participantNames which might not exist or have the expected format
                  final participantNames = data['participantNames'];
                  if (participantNames == null) return false;
                  
                  if (participantNames is Map<String, dynamic>) {
                    // Filter out the current user's name and find the other participant
                    final otherParticipantName = participantNames.entries
                        .where((entry) => entry.key != currentUserId)
                        .map((entry) => entry.value.toString())
                        .join();

                    return otherParticipantName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }
                  return false;
                } catch (e) {
                  print('Error filtering chat: $e');
                  return false;
                }
              }).toList();

        // Display all filtered chats
        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            try {
              final chatDoc = filteredChats[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              // Safely extract data from chat document
              final List<dynamic> participants = chatData['participants'] ?? [];
              
              // Safely handle participantNames
              Map<String, dynamic> participantNames = {};
              if (chatData['participantNames'] is Map) {
                participantNames = Map<String, dynamic>.from(chatData['participantNames']);
              }

              // Find the other participant (not the current user)
              String otherParticipantId = '';
              for (final participantId in participants) {
                if (participantId != currentUserId) {
                  otherParticipantId = participantId;
                  break;
                }
              }

              // Get display name from participantNames or use placeholder
              final String displayName =
                  participantNames[otherParticipantId] ?? 'Unknown User';

              // Get last message info with safe handling
              final String lastMessage =
                  chatData['lastMessage']?.toString() ?? 'No messages yet';
              final Timestamp? lastMessageTime =
                  chatData['lastMessageTime'] as Timestamp?;

              // Format date for display
              final String formattedDate = lastMessageTime != null
                  ? _formatDate(lastMessageTime.toDate())
                  : '';

              return ChatListItem(
                participantId: otherParticipantId,
                initialName: displayName,
                lastMessage: lastMessage,
                formattedDate: formattedDate,
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

  String _formatDate(DateTime date) {
    // Your existing date formatting logic
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}