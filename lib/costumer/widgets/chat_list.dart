import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_list_item.dart'; // Import the separate ChatListItem widget

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
          .orderBy('lastMessageTime', descending: true) // Sort by most recent message
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
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
                final data = doc.data() as Map<String, dynamic>;
                final participantNames = data['participantNames'] as Map<String, dynamic>? ?? {};

                // Filter out the current user's name and find the other participant
                final otherParticipantName = participantNames.entries
                    .where((entry) => entry.key != currentUserId)
                    .map((entry) => entry.value.toString())
                    .join();

                return otherParticipantName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
              }).toList();

        // Display all filtered chats
        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chatDoc = filteredChats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            
            // Extract data from chat document
            final List<dynamic> participants = chatData['participants'] ?? [];
            final Map<String, dynamic> participantNames = 
                Map<String, dynamic>.from(chatData['participantNames'] ?? {});
            
            // Find the other participant (not the current user)
            String otherParticipantId = '';
            for (final participantId in participants) {
              if (participantId != currentUserId) {
                otherParticipantId = participantId;
                break;
              }
            }
            
            // Get display name from participantNames or use placeholder
            final String displayName = participantNames[otherParticipantId] ?? 'Unknown User';
            
            // Get last message info
            final String lastMessage = chatData['lastMessage'] ?? 'No messages yet';
            final Timestamp? lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
            
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
          },
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    // Simple date formatting - customize as needed
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      // Format as time if today
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as date
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}