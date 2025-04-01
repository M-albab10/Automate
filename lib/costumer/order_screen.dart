// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../bars/navbar.dart';
// import '../costumer/maintenance_request_screen.dart';
// import '../costumer/offers_screen.dart'; // Import the new OffersScreen
// import '../bars/app_bar.dart';

// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _deleteRequest(String requestId) async {
//     bool confirm = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Delete Request'),
//             content: const Text(
//                 'Are you sure you want to delete this maintenance request?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                 ),
//                 onPressed: () => Navigator.pop(context, true),
//                 child:
//                     const Text('Delete', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirm) return;

//     await _firestore.collection('maintenance_requests').doc(requestId).delete();

//     final offersQuery = await _firestore
//         .collection('offers')
//         .where('requestId', isEqualTo: requestId)
//         .get();

//     final batch = _firestore.batch();
//     for (var doc in offersQuery.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }

//   void _viewOffers(BuildContext context, DocumentSnapshot request) {
//     Map<String, dynamic> data = request.data() as Map<String, dynamic>;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OffersScreen(
//           requestId: request.id,
//           carModel: data['car'] ?? 'Unknown Car',
//           problemDescription: data['problemDescription'] ?? 'Not specified',
//         ),
//       ),
//     );
//   }

//   Future<int> _getOffersCount(String requestId) async {
//     final QuerySnapshot offerSnapshot = await _firestore
//         .collection('offers')
//         .where('requestId', isEqualTo: requestId)
//         .get();

//     return offerSnapshot.docs.length;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBarWidget(pageName: 'Maintenance'),
//       backgroundColor: Colors.white, // Explicitly set background color to white
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: StreamBuilder(
//           stream: _firestore
//               .collection('maintenance_requests')
//               .where('userId', isEqualTo: _auth.currentUser?.uid)
//               .snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.assignment,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No requests added yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tap the + button to add your first request!',
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             var requests = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: requests.length,
//               itemBuilder: (context, index) {
//                 var request = requests[index];
//                 return Card(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: InkWell(
//                     onTap: () => _viewOffers(context, request),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               const CircleAvatar(
//                                 radius: 25,
//                                 backgroundColor: Colors.grey,
//                                 child:
//                                     Icon(Icons.car_repair, color: Colors.white),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Car: ${request['car']}",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       "Problem: ${request['problemDescription'] ?? 'Not specified'}",
//                                       style: TextStyle(
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon:
//                                     const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   _deleteRequest(request.id);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20, right: 10),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MaintenanceRequestScreen(),
//               ),
//             );
//           },
//           backgroundColor: Colors.blue,
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text('Request', style: TextStyle(color: Colors.white)),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 1,
//         onTap: (index) {},
//       ),
//     );
//   }
// }
//change 1st
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../bars/navbar.dart';
// import '../costumer/maintenance_request_screen.dart';
// import '../costumer/offers_screen.dart';
// import '../bars/app_bar.dart';
// import './widgets/customer_job_card.dart'; // Import the new CustomerJobCard
// import 'package:intl/intl.dart';
// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _deleteRequest(String requestId) async {
//     bool confirm = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Delete Request'),
//             content: const Text(
//                 'Are you sure you want to delete this maintenance request?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                 ),
//                 onPressed: () => Navigator.pop(context, true),
//                 child:
//                     const Text('Delete', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirm) return;

//     await _firestore.collection('maintenance_requests').doc(requestId).delete();

//     final offersQuery = await _firestore
//         .collection('offers')
//         .where('requestId', isEqualTo: requestId)
//         .get();

//     final batch = _firestore.batch();
//     for (var doc in offersQuery.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }

//   void _viewOffers(BuildContext context, DocumentSnapshot request) {
//     Map<String, dynamic> data = request.data() as Map<String, dynamic>;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OffersScreen(
//           requestId: request.id,
//           carModel: data['car'] ?? 'Unknown Car',
//           problemDescription: data['problemDescription'] ?? 'Not specified',
//         ),
//       ),
//     );
//   }

//   // void _viewJobDetails(BuildContext context, DocumentSnapshot request, DocumentSnapshot? acceptedOffer) {
//   //   // Implement a dialog or navigation to show full job details
//   //   Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
//   //   Map<String, dynamic> offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: Text('Job Details: ${requestData['car']}'),
//   //       content: SingleChildScrollView(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Text('Problem: ${requestData['problemDescription'] ?? 'Not specified'}'),
//   //             const SizedBox(height: 8),
//   //             Text('Status: ${requestData['status'] ?? 'pending'}'),
//   //             const SizedBox(height: 8),
//   //             Text('Price: \$${offerData['price'] ?? 'Not specified'}'),
//   //             if (offerData['mechanicNote'] != null) ...[
//   //               const SizedBox(height: 8),
//   //               const Divider(),
//   //               const SizedBox(height: 8),
//   //               Text('Mechanic Note: ${offerData['mechanicNote']}'),
//   //             ],
//   //             const SizedBox(height: 16),
//   //             const Text('Contact your mechanic for more information.'),
//   //           ],
//   //         ),
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('Close'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   void _viewJobDetails(BuildContext context, DocumentSnapshot request, DocumentSnapshot? acceptedOffer) {
//   Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
//   Map<String, dynamic> offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
  
//   // Correctly access the price from the offer
//   final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Job Details: ${requestData['car']}'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Problem: ${requestData['problemDescription'] ?? 'Not specified'}'),
//             const SizedBox(height: 8),
//             Text('Status: ${requestData['status'] ?? 'pending'}'),
//             const SizedBox(height: 8),
//             Text('Price: \$${price}'),
//             if (offerData['mechanicNote'] != null) ...[
//               const SizedBox(height: 8),
//               const Divider(),
//               const SizedBox(height: 8),
//               Text('Mechanic Note: ${offerData['mechanicNote']}'),
//             ],
//             if (requestData['statusUpdatedAt'] != null) ...[
//               const SizedBox(height: 8),
//               Text('Last Updated: ${_formatDate(requestData['statusUpdatedAt'])}'),
//             ],
//             const SizedBox(height: 16),
//             const Text('Contact your mechanic for more information.'),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Close'),
//         ),
//       ],
//     ),
//   );
// }

// String _formatDate(dynamic timestamp) {
//   if (timestamp == null) return 'N/A';
  
//   if (timestamp is Timestamp) {
//     final date = timestamp.toDate();
//     return DateFormat('MMM d, yyyy - h:mm a').format(date);
//   }
  
//   return 'N/A';
// }
//   // Future<DocumentSnapshot?> _getAcceptedOffer(String requestId) async {
//   //   final QuerySnapshot offerSnapshot = await _firestore
//   //       .collection('offers')
//   //       .where('requestId', isEqualTo: requestId)
//   //       .where('status', isEqualTo: 'accepted')
//   //       .get();

//   //   if (offerSnapshot.docs.isNotEmpty) {
//   //     return offerSnapshot.docs.first;
//   //   }
//   //   return null;
//   // }
//   Future<DocumentSnapshot?> _getAcceptedOffer(String requestId) async {
//   try {
//     // First try the offers collection
//     final QuerySnapshot offerSnapshot = await _firestore
//         .collection('offers')
//         .where('requestId', isEqualTo: requestId)
//         .where('status', isEqualTo: 'accepted')
//         .get();

//     if (offerSnapshot.docs.isNotEmpty) {
//       return offerSnapshot.docs.first;
//     }
    
//     // If no accepted offer found in offers collection, check the accepted_offers collection
//     // This is an alternative approach if you store accepted offers separately
//     final acceptedOfferDoc = await _firestore
//         .collection('accepted_offers')
//         .doc(requestId)
//         .get();
    
//     if (acceptedOfferDoc.exists) {
//       return acceptedOfferDoc;
//     }
    
//     return null;
//   } catch (e) {
//     print('Error fetching accepted offer: $e');
//     return null;
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBarWidget(pageName: 'Maintenance'),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: StreamBuilder(
//           stream: _firestore
//               .collection('maintenance_requests')
//               .where('userId', isEqualTo: _auth.currentUser?.uid)
//               .snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.assignment,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No requests added yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tap the + button to add your first request!',
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             var requests = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: requests.length,
//               itemBuilder: (context, index) {
//                 var request = requests[index];
//                 bool hasAcceptedOffer = request['status'] != null && 
//                                       request['status'] != 'pending' && 
//                                       request['status'] != 'awaiting_acceptance';
                
//                 if (hasAcceptedOffer) {
//                   // For requests with accepted offers, use FutureBuilder to get the offer
//                   return FutureBuilder<DocumentSnapshot?>(
//                     future: _getAcceptedOffer(request.id),
//                     builder: (context, offerSnapshot) {
//                       if (offerSnapshot.connectionState == ConnectionState.waiting) {
//                         return const Card(
//                           margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           child: Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(child: CircularProgressIndicator()),
//                           ),
//                         );
//                       }
                      
//                       final acceptedOffer = offerSnapshot.data;
                      
//                       return CustomerJobCard(
//                         request: request,
//                         acceptedOffer: acceptedOffer,
//                         onTap: () => _viewJobDetails(context, request, acceptedOffer),
//                       );
//                     },
//                   );
//                 } else {
//                   // For pending requests, use the existing card style
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: InkWell(
//                       onTap: () => _viewOffers(context, request),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 const CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Colors.grey,
//                                   child: Icon(Icons.car_repair, color: Colors.white),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Car: ${request['car']}",
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         "Problem: ${request['problemDescription'] ?? 'Not specified'}",
//                                         style: TextStyle(
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () {
//                                     _deleteRequest(request.id);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20, right: 10),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MaintenanceRequestScreen(),
//               ),
//             );
//           },
//           backgroundColor: Colors.blue,
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text('Request', style: TextStyle(color: Colors.white)),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 1,
//         onTap: (index) {},
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../bars/navbar.dart';
// import '../costumer/maintenance_request_screen.dart';
// import '../costumer/offers_screen.dart';
// import '../bars/app_bar.dart';
// import './widgets/customer_job_card.dart';
// import 'package:intl/intl.dart';

// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // UPDATED: Delete request and its offers subcollection
//   Future<void> _deleteRequest(String requestId) async {
//     bool confirm = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Delete Request'),
//             content: const Text(
//                 'Are you sure you want to delete this maintenance request?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                 ),
//                 onPressed: () => Navigator.pop(context, true),
//                 child:
//                     const Text('Delete', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirm) return;

//     try {
//       // Delete offers subcollection first
//       final offersSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .get();
      
//       // Delete offers in batches
//       final batch = _firestore.batch();
//       for (var doc in offersSnapshot.docs) {
//         batch.delete(doc.reference);
//       }
//       await batch.commit();
      
//       // Then delete the request
//       await _firestore.collection('maintenance_requests').doc(requestId).delete();
//     } catch (e) {
//       print('Error deleting request: $e');
//     }
//   }

//   void _viewOffers(BuildContext context, DocumentSnapshot request) {
//     Map<String, dynamic> data = request.data() as Map<String, dynamic>;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OffersScreen(
//           requestId: request.id,
//           carModel: data['car'] ?? 'Unknown Car',
//           problemDescription: data['problemDescription'] ?? 'Not specified',
//         ),
//       ),
//     );
//   }

//   void _viewJobDetails(BuildContext context, DocumentSnapshot request, DocumentSnapshot? acceptedOffer) {
//     Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
//     Map<String, dynamic> offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
//     // Correctly access the price from the offer
//     final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Job Details: ${requestData['car']}'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Problem: ${requestData['problemDescription'] ?? 'Not specified'}'),
//               const SizedBox(height: 8),
//               Text('Status: ${requestData['status'] ?? 'pending'}'),
//               const SizedBox(height: 8),
//               Text('Price: \$${price}'),
//               if (offerData['mechanicNote'] != null) ...[
//                 const SizedBox(height: 8),
//                 const Divider(),
//                 const SizedBox(height: 8),
//                 Text('Mechanic Note: ${offerData['mechanicNote']}'),
//               ],
//               if (requestData['statusUpdatedAt'] != null) ...[
//                 const SizedBox(height: 8),
//                 Text('Last Updated: ${_formatDate(requestData['statusUpdatedAt'])}'),
//               ],
//               const SizedBox(height: 16),
//               const Text('Contact your mechanic for more information.'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(dynamic timestamp) {
//     if (timestamp == null) return 'N/A';
    
//     if (timestamp is Timestamp) {
//       final date = timestamp.toDate();
//       return DateFormat('MMM d, yyyy - h:mm a').format(date);
//     }
    
//     return 'N/A';
//   }

//   // UPDATED: Get accepted offer from subcollection
//   Future<DocumentSnapshot?> _getAcceptedOffer(String requestId) async {
//     try {
//       // First check if the request has an acceptedOfferId field
//       final requestDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .get();
      
//       final requestData = requestDoc.data() as Map<String, dynamic>?;
      
//       // If there's a specific acceptedOfferId, use that
//       if (requestData != null && requestData.containsKey('acceptedOfferId')) {
//         final offerId = requestData['acceptedOfferId'];
        
//         final offerDoc = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .doc(offerId)
//             .get();
        
//         if (offerDoc.exists) {
//           return offerDoc;
//         }
//       }
      
//       // Otherwise query for an accepted offer in the subcollection
//       final QuerySnapshot offerSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .where('status', isEqualTo: 'accepted')
//           .get();
      
//       if (offerSnapshot.docs.isNotEmpty) {
//         return offerSnapshot.docs.first;
//       }
      
//       // If all else fails, try the old way (for backwards compatibility during migration)
//       final oldOfferSnapshot = await _firestore
//           .collection('offers')
//           .where('requestId', isEqualTo: requestId)
//           .where('status', isEqualTo: 'accepted')
//           .get();

//       if (oldOfferSnapshot.docs.isNotEmpty) {
//         return oldOfferSnapshot.docs.first;
//       }
      
//       return null;
//     } catch (e) {
//       print('Error fetching accepted offer: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBarWidget(pageName: 'Maintenance'),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: StreamBuilder(
//           stream: _firestore
//               .collection('maintenance_requests')
//               .where('userId', isEqualTo: _auth.currentUser?.uid)
//               .snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.assignment,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No requests added yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tap the + button to add your first request!',
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             var requests = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: requests.length,
//               itemBuilder: (context, index) {
//                 var request = requests[index];
//                 bool hasAcceptedOffer = request['status'] != null && 
//                                       request['status'] != 'pending' && 
//                                       request['status'] != 'awaiting_acceptance';
                
//                 if (hasAcceptedOffer) {
//                   // For requests with accepted offers, use FutureBuilder to get the offer
//                   return FutureBuilder<DocumentSnapshot?>(
//                     future: _getAcceptedOffer(request.id),
//                     builder: (context, offerSnapshot) {
//                       if (offerSnapshot.connectionState == ConnectionState.waiting) {
//                         return const Card(
//                           margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           child: Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(child: CircularProgressIndicator()),
//                           ),
//                         );
//                       }
                      
//                       final acceptedOffer = offerSnapshot.data;
                      
//                       return CustomerJobCard(
//                         request: request,
//                         acceptedOffer: acceptedOffer,
//                         onTap: () => _viewJobDetails(context, request, acceptedOffer),
//                       );
//                     },
//                   );
//                 } else {
//                   // For pending requests, use the existing card style
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: InkWell(
//                       onTap: () => _viewOffers(context, request),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 const CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Colors.grey,
//                                   child: Icon(Icons.car_repair, color: Colors.white),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Car: ${request['car']}",
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         "Problem: ${request['problemDescription'] ?? 'Not specified'}",
//                                         style: TextStyle(
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () {
//                                     _deleteRequest(request.id);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20, right: 10),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MaintenanceRequestScreen(),
//               ),
//             );
//           },
//           backgroundColor: Colors.blue,
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text('Request', style: TextStyle(color: Colors.white)),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 1,
//         onTap: (index) {},
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bars/navbar.dart';
import '../costumer/maintenance_request_screen.dart';
import '../costumer/offers_screen.dart';
import '../bars/app_bar.dart';
import './widgets/customer_job_card.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UPDATED: Delete request and its offers subcollection
  Future<void> _deleteRequest(String requestId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Request'),
            content: const Text(
                'Are you sure you want to delete this maintenance request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // Delete offers subcollection first
      final offersSnapshot = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .collection('offers')
          .get();
      
      // Delete offers in batches
      final batch = _firestore.batch();
      for (var doc in offersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Then delete the request
      await _firestore.collection('maintenance_requests').doc(requestId).delete();
    } catch (e) {
      print('Error deleting request: $e');
    }
  }

  void _viewOffers(BuildContext context, DocumentSnapshot request) {
    Map<String, dynamic> data = request.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OffersScreen(
          requestId: request.id,
          carModel: data['car'] ?? 'Unknown Car',
          problemDescription: data['problemDescription'] ?? 'Not specified',
        ),
      ),
    );
  }

  void _viewJobDetails(BuildContext context, DocumentSnapshot request, DocumentSnapshot? acceptedOffer) {
    Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
    Map<String, dynamic> offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
    // Correctly access the price from the offer
    final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details: ${requestData['car']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Problem: ${requestData['problemDescription'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Status: ${requestData['status'] ?? 'pending'}'),
              const SizedBox(height: 8),
              Text('Price: \$$price'),
              if (offerData['mechanicNote'] != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text('Mechanic Note: ${offerData['mechanicNote']}'),
              ],
              if (requestData['statusUpdatedAt'] != null) ...[
                const SizedBox(height: 8),
                Text('Last Updated: ${_formatDate(requestData['statusUpdatedAt'])}'),
              ],
              const SizedBox(height: 16),
              const Text('Contact your mechanic for more information.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    }
    
    return 'N/A';
  }

  // UPDATED: Get accepted offer from subcollection
  Future<DocumentSnapshot?> _getAcceptedOffer(String requestId) async {
    try {
      // First check if the request has an acceptedOfferId field
      final requestDoc = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .get();
      
      final requestData = requestDoc.data(); //as Map<String, dynamic>?;
      
      // If there's a specific acceptedOfferId, use that
      if (requestData != null && requestData.containsKey('acceptedOfferId')) {
        final offerId = requestData['acceptedOfferId'];
        
        final offerDoc = await _firestore
            .collection('maintenance_requests')
            .doc(requestId)
            .collection('offers')
            .doc(offerId)
            .get();
        
        if (offerDoc.exists) {
          return offerDoc;
        }
      }
      
      // Otherwise query for an accepted offer in the subcollection
      final QuerySnapshot offerSnapshot = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .collection('offers')
          .where('status', isEqualTo: 'accepted')
          .get();
      
      if (offerSnapshot.docs.isNotEmpty) {
        return offerSnapshot.docs.first;
      }
      
      // If all else fails, try the old way (for backwards compatibility during migration)
      final oldOfferSnapshot = await _firestore
          .collection('offers')
          .where('requestId', isEqualTo: requestId)
          .where('status', isEqualTo: 'accepted')
          .get();

      if (oldOfferSnapshot.docs.isNotEmpty) {
        return oldOfferSnapshot.docs.first;
      }
      
      return null;
    } catch (e) {
      print('Error fetching accepted offer: $e');
      return null;
    }
  }

  // NEW: Get the count of offers for a request
  Future<int> _getOffersCount(String requestId) async {
    try {
      final QuerySnapshot offerSnapshot = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .collection('offers')
          .get();
      
      return offerSnapshot.docs.length;
    } catch (e) {
      print('Error fetching offers count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(pageName: 'Maintenance'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: StreamBuilder(
          stream: _firestore
              .collection('maintenance_requests')
              .where('userId', isEqualTo: _auth.currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No requests added yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first request!',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            var requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index];
                bool hasAcceptedOffer = request['status'] != null && 
                                      request['status'] != 'pending' && 
                                      request['status'] != 'awaiting_acceptance';
                
                if (hasAcceptedOffer) {
                  // For requests with accepted offers, use FutureBuilder to get the offer
                  return FutureBuilder<DocumentSnapshot?>(
                    future: _getAcceptedOffer(request.id),
                    builder: (context, offerSnapshot) {
                      if (offerSnapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      
                      final acceptedOffer = offerSnapshot.data;
                      
                      return CustomerJobCard(
                        request: request,
                        acceptedOffer: acceptedOffer,
                        onTap: () => _viewJobDetails(context, request, acceptedOffer),
                      );
                    },
                  );
                } else {
                  // For requests without accepted offers, use the enhanced card with offers count
                  return FutureBuilder<int>(
                    future: _getOffersCount(request.id),
                    builder: (context, offersCountSnapshot) {
                      final offersCount = offersCountSnapshot.data ?? 0;
                      
                      return Dismissible(
                        key: Key(request.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Request'),
                              content: const Text(
                                  'Are you sure you want to delete this maintenance request?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', 
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _deleteRequest(request.id);
                        },
                        child: CustomerJobCard(
                          request: request,
                          acceptedOffer: null,
                          offersCount: offersCount,
                          onTap: () => _viewOffers(context, request),
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MaintenanceRequestScreen(),
              ),
            );
          },
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Request', style: TextStyle(color: Colors.white)),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}