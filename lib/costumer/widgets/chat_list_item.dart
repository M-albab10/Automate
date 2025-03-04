import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Direct_Chat_Screen.dart';

// Chat list widget that fetches all chats for the current user
class ChatList extends StatelessWidget {
  final String currentUserId;

  const ChatList({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Query chats where the current user is a participant
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No chats found'));
        }

        // Display all chats
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;

            // Extract data from chat document
            final List<dynamic> participants = chatData['participants'] ?? [];
            final Map<String, dynamic> participantNames =
                chatData['participantNames'] ?? {};

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

            // Get last message info
            final String lastMessage =
                chatData['lastMessage'] ?? 'No messages yet';
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

// Your existing ChatListItem widget with improvements
class ChatListItem extends StatefulWidget {
  final String participantId;
  final String initialName;
  final String lastMessage;
  final String formattedDate;

  const ChatListItem({
    Key? key,
    required this.participantId,
    required this.initialName,
    required this.lastMessage,
    required this.formattedDate,
  }) : super(key: key);

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _displayName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipantName();
  }

  Future<void> _loadParticipantName() async {
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

      if (mechanicDoc.exists) {
        final data = mechanicDoc.data() as Map<String, dynamic>;
        setState(() {
          _displayName = data['fullName'] ??
              data['displayName'] ??
              data['name'] ??
              widget.initialName;
          _isLoading = false;
        });
        return;
      }

      // Then check users collection
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.participantId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _displayName = data['fullName'] ??
              data['displayName'] ??
              data['name'] ??
              widget.initialName;
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
      print('Error loading participant name: $e');
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
    final firstLetter =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blue,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        _isLoading ? 'Loading...' : _displayName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.blue),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              widget.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Text(widget.formattedDate),
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
    );
  }
}
