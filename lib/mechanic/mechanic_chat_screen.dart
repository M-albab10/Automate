// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import '../costumer/direct_chat_screen.dart';

// class MechanicChatScreen extends StatefulWidget {
//   const MechanicChatScreen({super.key});

//   @override
//   State<MechanicChatScreen> createState() => _MechanicChatScreenState();
// }

// class _MechanicChatScreenState extends State<MechanicChatScreen> {
//   int _currentIndex = 1; // Chat is index 1 in mechanic navigation
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Mechanic Chat',
//         color: Color.fromARGB(255, 208, 63, 2),
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           Expanded(
//             child: _buildChatList(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search Customers',
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.blue.shade300),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         onChanged: (value) {
//           setState(() {
//             _searchQuery = value.toLowerCase();
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildChatList() {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     if (currentUserId == null) {
//       return const Center(child: Text('Please log in to view your chats'));
//     }

//     // Using orderBy only approach to avoid index issues
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .orderBy('lastMessageTime', descending: true) // Changed to lastMessageTime
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 208, 63, 2),
//           ));
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final allChats = snapshot.data?.docs ?? [];
        
//         // Filter chats in Dart to avoid query index issues
//         final conversations = allChats.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final participants = List<String>.from(data['participants'] ?? []);
//           return participants.contains(currentUserId);
//         }).toList();
        
//         if (conversations.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No customer conversations yet',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                   child: Text(
//                     'You\'ll see messages from customers here when they contact you',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // If search is active, filter the results
//         if (_searchQuery.isNotEmpty) {
//           return _buildFilteredChatList(conversations, currentUserId);
//         }

//         return ListView.builder(
//           itemCount: conversations.length,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemBuilder: (context, index) {
//             return _buildChatItem(
//               conversations[index], 
//               currentUserId
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildFilteredChatList(List<DocumentSnapshot> conversations, String currentUserId) {
//     // This function handles searching by user name
//     // We'll gather all the user data first, then filter
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getUserDataForConversations(conversations, currentUserId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 208, 63, 2),
//           ));
//         }
        
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
        
//         final conversationsWithUserData = snapshot.data ?? [];
        
//         // Filter by username
//         final filteredConversations = conversationsWithUserData
//             .where((item) => item['userName'].toLowerCase().contains(_searchQuery))
//             .toList();
            
//         if (filteredConversations.isEmpty) {
//           return Center(
//             child: Text(
//               'No results found for "$_searchQuery"',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           );
//         }
        
//         return ListView.builder(
//           itemCount: filteredConversations.length,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemBuilder: (context, index) {
//             final item = filteredConversations[index];
//             return _buildChatItemWithData(
//               item['conversation'], 
//               currentUserId,
//               item['userName'],
//               item['photoUrl']
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> _getUserDataForConversations(
//     List<DocumentSnapshot> conversations, 
//     String currentUserId
//   ) async {
//     List<Map<String, dynamic>> result = [];
    
//     for (var convo in conversations) {
//       final conversationData = convo.data() as Map<String, dynamic>;
//       final participants = List<String>.from(conversationData['participants']);
      
//       // Get the other user's ID (the customer)
//       final otherUserId = participants.firstWhere(
//         (id) => id != currentUserId,
//         orElse: () => 'Unknown User',
//       );
      
//       // Check if participantNames exists and has the customer's name
//       String? nameFromChat;
//       if (conversationData.containsKey('participantNames')) {
//         final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
//         if (participantNames != null && participantNames.containsKey(otherUserId)) {
//           nameFromChat = participantNames[otherUserId];
//         }
//       }
      
//       // Get customer information from users collection if not in participantNames
//       try {
//         String userName = nameFromChat ?? 'Unknown User';
//         String? photoUrl;
        
//         // Only fetch from users collection if we don't have the name already
//         if (nameFromChat == null) {
//           final userDoc = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(otherUserId)
//               .get();
              
//           if (userDoc.exists) {
//             final userData = userDoc.data() as Map<String, dynamic>;
//             userName = userData['username'] ?? 'Unknown User';
//             photoUrl = userData['photoUrl'];
//           }
//         }
        
//         result.add({
//           'conversation': convo,
//           'userName': userName,
//           'photoUrl': photoUrl,
//           'userId': otherUserId,
//         });
//       } catch (e) {
//         print('Error getting user data: $e');
//         // Still add conversation with placeholder data
//         result.add({
//           'conversation': convo,
//           'userName': nameFromChat ?? 'Unknown User',
//           'photoUrl': null,
//           'userId': otherUserId,
//         });
//       }
//     }
    
//     return result;
//   }

//   Widget _buildChatItem(DocumentSnapshot document, String currentUserId) {
//     final conversationData = document.data() as Map<String, dynamic>;
//     final participants = List<String>.from(conversationData['participants']);
    
//     // Get the other participant's ID (the customer)
//     final customerId = participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => 'Unknown User',
//     );
    
//     // Check if we already have the customer name in participantNames
//     String? customerNameFromChat;
//     if (conversationData.containsKey('participantNames')) {
//       final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
//       if (participantNames != null && participantNames.containsKey(customerId)) {
//         customerNameFromChat = participantNames[customerId];
//       }
//     }
    
//     // Get message data
//     final lastMessage = conversationData['lastMessage'] ?? 'No messages';
//     final lastMessageTimestamp = conversationData['lastMessageTime'] as Timestamp?; // Changed from lastMessageTimestamp
//     final lastMessageDate = lastMessageTimestamp?.toDate() ?? DateTime.now();
//     final isFromMe = conversationData['lastMessageSenderId'] == currentUserId;
//     final unreadCount = conversationData['unreadCount'] ?? 0;
    
//     // Format the date for display
//     final formattedDate = _formatChatDate(lastMessageDate);
    
//     // If we already have the customer name, use it directly
//     if (customerNameFromChat != null) {
//       return _buildChatItemWithCustomerName(
//         document,
//         currentUserId,
//         customerNameFromChat,
//         null, // No photo URL from participantNames
//         customerId,
//         lastMessage,
//         formattedDate,
//         isFromMe,
//         unreadCount
//       );
//     }
    
//     // Otherwise fetch from users collection
//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('users').doc(customerId).get(),
//       builder: (context, snapshot) {
//         String customerName = 'Loading...';
//         String? photoUrl;
        
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasData && snapshot.data!.exists) {
//             final userData = snapshot.data!.data() as Map<String, dynamic>;
//             customerName = userData['username'] ?? 'Unknown User';
//             photoUrl = userData['photoUrl'];
//           } else {
//             customerName = 'Unknown User';
//           }
//         }
        
//         return _buildChatItemWithCustomerName(
//           document,
//           currentUserId,
//           customerName,
//           photoUrl,
//           customerId,
//           lastMessage,
//           formattedDate,
//           isFromMe,
//           unreadCount
//         );
//       },
//     );
//   }
  
//   Widget _buildChatItemWithCustomerName(
//     DocumentSnapshot document,
//     String currentUserId,
//     String customerName,
//     String? photoUrl,
//     String customerId,
//     String lastMessage,
//     String formattedDate,
//     bool isFromMe,
//     int unreadCount
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundColor: Colors.blue.shade100,
//           backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
//           child: photoUrl == null
//               ? Text(
//                   customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               : null,
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 customerName,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (unreadCount > 0 && !isFromMe)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 208, 63, 2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   unreadCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Row(
//             children: [
//               if (isFromMe) ...[
//                 const Icon(
//                   Icons.check,
//                   size: 16,
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 5),
//                 const Text(
//                   'You: ',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//               Expanded(
//                 child: Text(
//                   lastMessage,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         trailing: Text(
//           formattedDate,
//           style: TextStyle(
//             color: Colors.grey[500],
//             fontSize: 12,
//           ),
//         ),
//         onTap: () {
//           // Update to direct to the correct chat screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DirectChatScreen(
//                 userName: customerName,
//                 userId: customerId,
//                 isMechanic: true, // Add this parameter to DirectChatScreen
//               ),
//             ),
//           ).then((_) {
//             // Refresh when coming back
//             setState(() {});
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildChatItemWithData(
//     DocumentSnapshot document, 
//     String currentUserId,
//     String customerName,
//     String? photoUrl
//   ) {
//     final conversationData = document.data() as Map<String, dynamic>;
//     final participants = List<String>.from(conversationData['participants']);
    
//     // Get the other participant's ID (the customer)
//     final customerId = participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => 'Unknown User',
//     );
    
//     // Get message data
//     final lastMessage = conversationData['lastMessage'] ?? 'No messages';
//     final lastMessageTimestamp = conversationData['lastMessageTime'] as Timestamp?; // Changed from lastMessageTimestamp
//     final lastMessageDate = lastMessageTimestamp?.toDate() ?? DateTime.now();
//     final isFromMe = conversationData['lastMessageSenderId'] == currentUserId;
//     final unreadCount = conversationData['unreadCount'] ?? 0;
    
//     // Format the date for display
//     final formattedDate = _formatChatDate(lastMessageDate);
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundColor: Colors.blue.shade100,
//           backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
//           child: photoUrl == null
//               ? Text(
//                   customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               : null,
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 customerName,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (unreadCount > 0 && !isFromMe)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 208, 63, 2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   unreadCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Row(
//             children: [
//               if (isFromMe) ...[
//                 const Icon(
//                   Icons.check,
//                   size: 16,
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 5),
//                 const Text(
//                   'You: ',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//               Expanded(
//                 child: Text(
//                   lastMessage,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         trailing: Text(
//           formattedDate,
//           style: TextStyle(
//             color: Colors.grey[500],
//             fontSize: 12,
//           ),
//         ),
//         onTap: () {
//           // Update to direct to the correct chat screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DirectChatScreen(
//                 userName: customerName,
//                 userId: customerId,
//                 isMechanic: true, // Add this parameter to DirectChatScreen
//               ),
//             ),
//           ).then((_) {
//             // Refresh when coming back
//             setState(() {});
//           });
//         },
//       ),
//     );
//   }

//   String _formatChatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(today.year, today.month, today.day - 1);
//     final dateToCheck = DateTime(date.year, date.month, date.day);
    
//     if (dateToCheck == today) {
//       return DateFormat('h:mm a').format(date);
//     } else if (dateToCheck == yesterday) {
//       return 'Yesterday';
//     } else if (now.difference(date).inDays < 7) {
//       return DateFormat('EEE').format(date); // Day of week (Mon, Tue, etc.)
//     } else {
//       return DateFormat('MM/dd/yyyy').format(date); // Format like your example
//     }
//   }
// }
//change 2
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import '../costumer/direct_chat_screen.dart';

// class MechanicChatScreen extends StatefulWidget {
//   const MechanicChatScreen({super.key});

//   @override
//   State<MechanicChatScreen> createState() => _MechanicChatScreenState();
// }

// class _MechanicChatScreenState extends State<MechanicChatScreen> {
//   int _currentIndex = 1; // Chat is index 1 in mechanic navigation
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Mechanic Chat',
//         color: Color.fromARGB(255, 208, 63, 2),
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           Expanded(
//             child: _buildChatList(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search Customers',
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.blue.shade300),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         onChanged: (value) {
//           setState(() {
//             _searchQuery = value.toLowerCase();
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildChatList() {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     if (currentUserId == null) {
//       return const Center(child: Text('Please log in to view your chats'));
//     }

//     // Using orderBy only approach to avoid index issues
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .orderBy('lastMessageTime', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 208, 63, 2),
//           ));
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final allChats = snapshot.data?.docs ?? [];
        
//         // Filter chats in Dart to avoid query index issues
//         final conversations = allChats.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final participants = List<String>.from(data['participants'] ?? []);
//           return participants.contains(currentUserId);
//         }).toList();
        
//         if (conversations.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No customer conversations yet',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                   child: Text(
//                     'You\'ll see messages from customers here when they contact you',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // If search is active, filter the results
//         if (_searchQuery.isNotEmpty) {
//           return _buildFilteredChatList(conversations, currentUserId);
//         }

//         return ListView.builder(
//           itemCount: conversations.length,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemBuilder: (context, index) {
//             return _buildChatItem(
//               conversations[index], 
//               currentUserId
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildFilteredChatList(List<DocumentSnapshot> conversations, String currentUserId) {
//     // This function handles searching by user name
//     // We'll gather all the user data first, then filter
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getUserDataForConversations(conversations, currentUserId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: Color.fromARGB(255, 208, 63, 2),
//           ));
//         }
        
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
        
//         final conversationsWithUserData = snapshot.data ?? [];
        
//         // Filter by username
//         final filteredConversations = conversationsWithUserData
//             .where((item) => item['userName'].toLowerCase().contains(_searchQuery))
//             .toList();
            
//         if (filteredConversations.isEmpty) {
//           return Center(
//             child: Text(
//               'No results found for "$_searchQuery"',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           );
//         }
        
//         return ListView.builder(
//           itemCount: filteredConversations.length,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemBuilder: (context, index) {
//             final item = filteredConversations[index];
//             return _buildWhatsAppChatItem(
//               item['conversation'], 
//               currentUserId,
//               item['userName'],
//               item['photoUrl'],
//               item['userId']
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> _getUserDataForConversations(
//     List<DocumentSnapshot> conversations, 
//     String currentUserId
//   ) async {
//     List<Map<String, dynamic>> result = [];
    
//     for (var convo in conversations) {
//       final conversationData = convo.data() as Map<String, dynamic>;
//       final participants = List<String>.from(conversationData['participants']);
      
//       // Get the other user's ID (the customer)
//       final otherUserId = participants.firstWhere(
//         (id) => id != currentUserId,
//         orElse: () => 'Unknown User',
//       );
      
//       // Check if participantNames exists and has the customer's name
//       String? nameFromChat;
//       if (conversationData.containsKey('participantNames')) {
//         final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
//         if (participantNames != null && participantNames.containsKey(otherUserId)) {
//           nameFromChat = participantNames[otherUserId];
//         }
//       }
      
//       // Get customer information from users collection if not in participantNames
//       try {
//         String userName = nameFromChat ?? 'Unknown User';
//         String? photoUrl;
        
//         // Only fetch from users collection if we don't have the name already
//         if (nameFromChat == null) {
//           final userDoc = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(otherUserId)
//               .get();
              
//           if (userDoc.exists) {
//             final userData = userDoc.data() as Map<String, dynamic>;
//             userName = userData['username'] ?? 'Unknown User';
//             photoUrl = userData['photoUrl'];
//           }
//         }
        
//         result.add({
//           'conversation': convo,
//           'userName': userName,
//           'photoUrl': photoUrl,
//           'userId': otherUserId,
//         });
//       } catch (e) {
//         print('Error getting user data: $e');
//         // Still add conversation with placeholder data
//         result.add({
//           'conversation': convo,
//           'userName': nameFromChat ?? 'Unknown User',
//           'photoUrl': null,
//           'userId': otherUserId,
//         });
//       }
//     }
    
//     return result;
//   }

//   Widget _buildChatItem(DocumentSnapshot document, String currentUserId) {
//     final conversationData = document.data() as Map<String, dynamic>;
//     final participants = List<String>.from(conversationData['participants']);
    
//     // Get the other participant's ID (the customer)
//     final customerId = participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => 'Unknown User',
//     );
    
//     // Check if we already have the customer name in participantNames
//     String? customerNameFromChat;
//     if (conversationData.containsKey('participantNames')) {
//       final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
//       if (participantNames != null && participantNames.containsKey(customerId)) {
//         customerNameFromChat = participantNames[customerId];
//       }
//     }
    
//     // If we already have the customer name, use it directly
//     if (customerNameFromChat != null) {
//       return _buildWhatsAppChatItem(
//         document,
//         currentUserId,
//         customerNameFromChat,
//         null, // No photo URL from participantNames
//         customerId
//       );
//     }
    
//     // Otherwise fetch from users collection
//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('users').doc(customerId).get(),
//       builder: (context, snapshot) {
//         String customerName = 'Loading...';
//         String? photoUrl;
        
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasData && snapshot.data!.exists) {
//             final userData = snapshot.data!.data() as Map<String, dynamic>;
//             customerName = userData['username'] ?? 'Unknown User';
//             photoUrl = userData['photoUrl'];
//           } else {
//             customerName = 'Unknown User';
//           }
//         }
        
//         return _buildWhatsAppChatItem(
//           document,
//           currentUserId,
//           customerName,
//           photoUrl,
//           customerId
//         );
//       },
//     );
//   }
  
//   Widget _buildWhatsAppChatItem(
//     DocumentSnapshot document,
//     String currentUserId,
//     String customerName,
//     String? photoUrl,
//     String customerId
//   ) {
//     final conversationData = document.data() as Map<String, dynamic>;
    
//     // Get message data
//     final lastMessage = conversationData['lastMessage'] ?? 'No messages';
//     final lastMessageTimestamp = conversationData['lastMessageTime'] as Timestamp?;
//     final lastMessageDate = lastMessageTimestamp?.toDate() ?? DateTime.now();
//     final isFromMe = conversationData['lastMessageSenderId'] == currentUserId;
//     final unreadCount = conversationData['unreadCount'] ?? 0;
//     final bool isRead = conversationData['isRead'] ?? false;
    
//     // Format the date for display
//     final formattedDate = _formatChatDate(lastMessageDate);
    
//     // Generate avatar color based on name (for consistency)
//     final Color avatarColor = Colors.primaries[
//       customerName.isNotEmpty
//           ? customerName.codeUnitAt(0) % Colors.primaries.length
//           : 0
//     ];
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(15),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(15),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => DirectChatScreen(
//                   userName: customerName,
//                   userId: customerId,
//                   isMechanic: true,
//                 ),
//               ),
//             ).then((_) {
//               setState(() {});
//             });
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 // Profile picture
//                 CircleAvatar(
//                   radius: 25,
//                   backgroundColor: avatarColor,
//                   backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
//                   child: photoUrl == null
//                       ? Text(
//                           customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : null,
//                 ),
                
//                 const SizedBox(width: 15),
                
//                 // Chat content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Name and time row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Customer name
//                           Flexible(
//                             child: Text(
//                               customerName,
//                               style: TextStyle(
//                                 fontWeight: unreadCount > 0 && !isFromMe
//                                     ? FontWeight.bold
//                                     : FontWeight.w500,
//                                 fontSize: 16,
//                                 color: unreadCount > 0 && !isFromMe
//                                     ? Colors.black
//                                     : Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
                          
//                           // Time
//                           Text(
//                             formattedDate,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: unreadCount > 0 && !isFromMe
//                                   ? const Color.fromARGB(255, 208, 63, 2)
//                                   : Colors.grey.shade500,
//                               fontWeight: unreadCount > 0 && !isFromMe
//                                   ? FontWeight.w500
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 6),
                      
//                       // Message preview row with badges
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Message status icon (for messages I sent)
//                           if (isFromMe) ...[
//                             Padding(
//                               padding: const EdgeInsets.only(top: 3),
//                               child: Icon(
//                                 isRead ? Icons.done_all : Icons.done,
//                                 size: 16,
//                                 color: isRead ? Colors.blue : Colors.grey,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                           ],
                          
//                           // Message preview with "You: " prefix if needed
//                           Expanded(
//                             child: RichText(
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               text: TextSpan(
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: unreadCount > 0 && !isFromMe
//                                       ? Colors.black87
//                                       : Colors.grey.shade600,
//                                 ),
//                                 children: [
//                                   if (isFromMe)
//                                     TextSpan(
//                                       text: "You: ",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey.shade700,
//                                       ),
//                                     ),
//                                   TextSpan(
//                                     text: lastMessage,
//                                     style: TextStyle(
//                                       fontWeight: unreadCount > 0 && !isFromMe
//                                           ? FontWeight.w500
//                                           : FontWeight.normal,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
                          
//                           // Unread count badge
//                           if (unreadCount > 0 && !isFromMe)
//                             Container(
//                               margin: const EdgeInsets.only(left: 8, top: 2),
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: const Color.fromARGB(255, 208, 63, 2),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text(
//                                 unreadCount.toString(),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatChatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(today.year, today.month, today.day - 1);
//     final dateToCheck = DateTime(date.year, date.month, date.day);
    
//     if (dateToCheck == today) {
//       return DateFormat('h:mm a').format(date);
//     } else if (dateToCheck == yesterday) {
//       return 'Yesterday';
//     } else if (now.difference(date).inDays < 7) {
//       return DateFormat('EEE').format(date); // Day of week (Mon, Tue, etc.)
//     } else {
//       return DateFormat('MM/dd/yyyy').format(date); // Format like your example
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/mechanic_navbar.dart';
import '../costumer/direct_chat_screen.dart';

class MechanicChatScreen extends StatefulWidget {
  const MechanicChatScreen({super.key});

  @override
  State<MechanicChatScreen> createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  int _currentIndex = 1; // Chat is index 1 in mechanic navigation
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWidget(
        pageName: 'Mechanic Chat',
        color: Color.fromARGB(255, 208, 63, 2),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
      bottomNavigationBar: MechanicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Customers',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildChatList() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text('Please log in to view your chats'));
    }

    // Using orderBy only approach to avoid index issues
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
            color: Color.fromARGB(255, 208, 63, 2),
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allChats = snapshot.data?.docs ?? [];
        
        // Filter chats in Dart to avoid query index issues
        final conversations = allChats.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final participants = List<String>.from(data['participants'] ?? []);
          return participants.contains(currentUserId);
        }).toList();
        
        if (conversations.isEmpty) {
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
                  'No customer conversations yet',
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
                    'You\'ll see messages from customers here when they contact you',
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

        // If search is active, filter the results
        if (_searchQuery.isNotEmpty) {
          return _buildFilteredChatList(conversations, currentUserId);
        }

        return ListView.separated(
          itemCount: conversations.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            return _buildChatItem(
              conversations[index], 
              currentUserId
            );
          },
        );
      },
    );
  }

  Widget _buildFilteredChatList(List<DocumentSnapshot> conversations, String currentUserId) {
    // This function handles searching by user name
    // We'll gather all the user data first, then filter
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getUserDataForConversations(conversations, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
            color: Color.fromARGB(255, 208, 63, 2),
          ));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final conversationsWithUserData = snapshot.data ?? [];
        
        // Filter by username
        final filteredConversations = conversationsWithUserData
            .where((item) {
              final matchesName = item['userName'].toLowerCase().contains(_searchQuery);
              
              // Also search in the last message
              final data = (item['conversation'].data() as Map<String, dynamic>);
              final lastMessage = (data['lastMessage'] ?? '').toLowerCase();
              final matchesMessage = lastMessage.contains(_searchQuery);
              
              return matchesName || matchesMessage;
            })
            .toList();
            
        if (filteredConversations.isEmpty) {
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
        
        return ListView.separated(
          itemCount: filteredConversations.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            final item = filteredConversations[index];
            return _buildWhatsAppChatItem(
              item['conversation'], 
              currentUserId,
              item['userName'],
              item['photoUrl'],
              item['userId']
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getUserDataForConversations(
    List<DocumentSnapshot> conversations, 
    String currentUserId
  ) async {
    List<Map<String, dynamic>> result = [];
    
    for (var convo in conversations) {
      final conversationData = convo.data() as Map<String, dynamic>;
      final participants = List<String>.from(conversationData['participants']);
      
      // Get the other user's ID (the customer)
      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => 'Unknown User',
      );
      
      // Check if participantNames exists and has the customer's name
      String? nameFromChat;
      if (conversationData.containsKey('participantNames')) {
        final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
        if (participantNames != null && participantNames.containsKey(otherUserId)) {
          nameFromChat = participantNames[otherUserId];
        }
      }
      
      // Get customer information from users collection if not in participantNames
      try {
        String userName = nameFromChat ?? 'Unknown User';
        String? photoUrl;
        
        // Only fetch from users collection if we don't have the name already
        if (nameFromChat == null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get();
              
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['username'] ?? 'Unknown User';
            photoUrl = userData['photoUrl'];
          }
        }
        
        result.add({
          'conversation': convo,
          'userName': userName,
          'photoUrl': photoUrl,
          'userId': otherUserId,
        });
      } catch (e) {
        print('Error getting user data: $e');
        // Still add conversation with placeholder data
        result.add({
          'conversation': convo,
          'userName': nameFromChat ?? 'Unknown User',
          'photoUrl': null,
          'userId': otherUserId,
        });
      }
    }
    
    return result;
  }

  Widget _buildChatItem(DocumentSnapshot document, String currentUserId) {
    final conversationData = document.data() as Map<String, dynamic>;
    final participants = List<String>.from(conversationData['participants']);
    
    // Get the other participant's ID (the customer)
    final customerId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown User',
    );
    
    // Check if we already have the customer name in participantNames
    String? customerNameFromChat;
    if (conversationData.containsKey('participantNames')) {
      final participantNames = conversationData['participantNames'] as Map<String, dynamic>?;
      if (participantNames != null && participantNames.containsKey(customerId)) {
        customerNameFromChat = participantNames[customerId];
      }
    }
    
    // If we already have the customer name, use it directly
    if (customerNameFromChat != null) {
      return _buildWhatsAppChatItem(
        document,
        currentUserId,
        customerNameFromChat,
        null, // No photo URL from participantNames
        customerId
      );
    }
    
    // Otherwise fetch from users collection
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(customerId).get(),
      builder: (context, snapshot) {
        String customerName = 'Loading...';
        String? photoUrl;
        
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            customerName = userData['username'] ?? 'Unknown User';
            photoUrl = userData['photoUrl'];
          } else {
            customerName = 'Unknown User';
          }
        }
        
        return _buildWhatsAppChatItem(
          document,
          currentUserId,
          customerName,
          photoUrl,
          customerId
        );
      },
    );
  }
  
  Widget _buildWhatsAppChatItem(
    DocumentSnapshot document,
    String currentUserId,
    String customerName,
    String? photoUrl,
    String customerId
  ) {
    final conversationData = document.data() as Map<String, dynamic>;
    
    // Get message data
    final lastMessage = conversationData['lastMessage'] ?? 'No messages';
    final lastMessageTimestamp = conversationData['lastMessageTime'] as Timestamp?;
    final lastMessageDate = lastMessageTimestamp?.toDate() ?? DateTime.now();
    final isFromMe = conversationData['lastMessageSenderId'] == currentUserId;
    final unreadCount = conversationData['unreadCount'] ?? 0;
    final bool isRead = conversationData['isRead'] ?? false;
    
    // Format the date for display
    final formattedDate = _formatChatDate(lastMessageDate);
    
    // Generate avatar color based on name (for consistency)
    final Color avatarColor = Colors.primaries[
      customerName.isNotEmpty
          ? customerName.codeUnitAt(0) % Colors.primaries.length
          : 0
    ];
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectChatScreen(
              userName: customerName,
              userId: customerId,
              isMechanic: true,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
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
                      // Customer name
                      Flexible(
                        child: Text(
                          customerName,
                          style: TextStyle(
                            fontWeight: unreadCount > 0 && !isFromMe
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 16,
                            color: unreadCount > 0 && !isFromMe
                                ? Colors.black
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Time
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0 && !isFromMe
                              ? const Color.fromARGB(255, 208, 63, 2)
                              : Colors.grey.shade500,
                          fontWeight: unreadCount > 0 && !isFromMe
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
                      if (isFromMe) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            isRead ? Icons.done_all : Icons.done,
                            size: 16,
                            color: isRead ? Colors.blue : Colors.grey,
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
                              color: unreadCount > 0 && !isFromMe
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                            children: [
                              if (isFromMe)
                                TextSpan(
                                  text: "You: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              TextSpan(
                                text: lastMessage,
                                style: TextStyle(
                                  fontWeight: unreadCount > 0 && !isFromMe
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Unread count badge
                      if (unreadCount > 0 && !isFromMe)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 208, 63, 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
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

  String _formatChatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return DateFormat('h:mm a').format(date);
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date); // Day of week (Mon, Tue, etc.)
    } else {
      return DateFormat('MM/dd/yy').format(date); // Format like your example
    }
  }
}