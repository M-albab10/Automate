// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';
// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) return;

//       // 1. Get all offers made by this mechanic
//       final offersSnapshot = await _firestore
//           .collection('offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();

//       // Get all request IDs from offers
//       final requestIds = offersSnapshot.docs
//           .map((doc) => doc.data()['requestId'] as String)
//           .toSet();

//       if (requestIds.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // 2. Get all relevant request documents
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .where(FieldPath.documentId, whereIn: requestIds.toList())
//           .get();

//       // Create a map of request documents by ID for quick lookup
//       final requestDocsMap = {
//         for (var doc in requestsSnapshot.docs) doc.id: doc
//       };

//       // Create a map of offer documents by request ID for quick lookup
//       final offersByRequestId = <String, List<DocumentSnapshot>>{};
//       for (var offerDoc in offersSnapshot.docs) {
//         final requestId = offerDoc.data()['requestId'] as String;
//         offersByRequestId.putIfAbsent(requestId, () => []).add(offerDoc);
//       }

//       // 3. Group offers by status
//       final pendingOffers = <DocumentSnapshot>[];
//       final acceptedOffers = <DocumentSnapshot>[];
//       final completedOffers = <DocumentSnapshot>[];

//       for (final requestId in requestIds) {
//         final request = requestDocsMap[requestId];
//         if (request == null) continue;

//         final data = request.data();
//         final status = data['status'] as String? ?? 'pending';
//         final acceptedOfferId = data['acceptedOfferId'] as String?;

//         // Check if this mechanic's offer was accepted
//         final mechanicOfferAccepted = offersByRequestId[requestId]?.any(
//           (offerDoc) => offerDoc.id == acceptedOfferId
//         ) ?? false;

//         if (status == 'completed') {
//           if (mechanicOfferAccepted) {
//             completedOffers.add(request);
//           }
//         } else if (mechanicOfferAccepted) {
//           acceptedOffers.add(request);
//         } else {
//           pendingOffers.add(request);
//         }
//       }

//       setState(() {
//         _pendingOffers = pendingOffers;
//         _acceptedOffers = acceptedOffers;
//         _completedOffers = completedOffers;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildOffersList(_acceptedOffers, 'accepted'),
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// change 1st
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/accepted_job_card.dart'; // New import for the AcceptedJobCard
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store accepted offers data keyed by request ID
//   Map<String, DocumentSnapshot> _acceptedOffersMap = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) return;

//       // 1. Get all offers made by this mechanic
//       final offersSnapshot = await _firestore
//           .collection('offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();

//       // Get all request IDs from offers
//       final requestIds = offersSnapshot.docs
//           .map((doc) => doc.data()['requestId'] as String)
//           .toSet();

//       if (requestIds.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // 2. Get all relevant request documents
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .where(FieldPath.documentId, whereIn: requestIds.toList())
//           .get();

//       // Create a map of request documents by ID for quick lookup
//       final requestDocsMap = {
//         for (var doc in requestsSnapshot.docs) doc.id: doc
//       };

//       // Create a map of offer documents by request ID for quick lookup
//       final offersByRequestId = <String, List<DocumentSnapshot>>{};
//       for (var offerDoc in offersSnapshot.docs) {
//         final requestId = offerDoc.data()['requestId'] as String;
//         offersByRequestId.putIfAbsent(requestId, () => []).add(offerDoc);
//       }

//       // 3. Get all accepted offers for this mechanic
//       final acceptedOffersSnapshot = await _firestore
//           .collection('accepted_offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();

//       // Create a map of accepted offer documents by request ID
//       final Map<String, DocumentSnapshot> acceptedOffersMap = {};
//       for (var doc in acceptedOffersSnapshot.docs) {
//         final data = doc.data();
//         final requestId = data['requestId'] as String;
//         acceptedOffersMap[requestId] = doc;
//       }

//       // 4. Group offers by status
//       final pendingOffers = <DocumentSnapshot>[];
//       final acceptedOffers = <DocumentSnapshot>[];
//       final completedOffers = <DocumentSnapshot>[];

//       for (final requestId in requestIds) {
//         final request = requestDocsMap[requestId];
//         if (request == null) continue;

//         final data = request.data();
//         final status = data['status'] as String? ?? 'pending';
//         final acceptedOfferId = data['acceptedOfferId'] as String?;

//         // Check if this mechanic's offer was accepted
//         final mechanicOfferAccepted = offersByRequestId[requestId]?.any(
//           (offerDoc) => offerDoc.id == acceptedOfferId
//         ) ?? false;

//         if (status == 'completed') {
//           if (mechanicOfferAccepted) {
//             completedOffers.add(request);
//           }
//         } else if (mechanicOfferAccepted) {
//           acceptedOffers.add(request);
//         } else {
//           pendingOffers.add(request);
//         }
//       }

//       setState(() {
//         _pendingOffers = pendingOffers;
//         _acceptedOffers = acceptedOffers;
//         _completedOffers = completedOffers;
//         _acceptedOffersMap = acceptedOffersMap; // Store the map for accepted offers
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   // New method specifically for accepted offers with status update functionality
//   // Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//   //   if (offers.isEmpty) {
//   //     return _buildEmptyState('No accepted offers', 'accepted');
//   //   }

//   //   return RefreshIndicator(
//   //     onRefresh: _loadOfferData,
//   //     color: JobConstants.primaryColor,
//   //     child: ListView.builder(
//   //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   //       itemCount: offers.length,
//   //       itemBuilder: (context, index) {
//   //         final request = offers[index];
//   //         final requestId = request.id;
          
//   //         // Get the accepted offer document for this request
//   //         final acceptedOffer = _acceptedOffersMap[requestId];
          
//   //         if (acceptedOffer == null) {
//   //           // Fallback to regular JobCardWidget if no accepted offer data found
//   //           return JobCardWidget(
//   //             request: request,
//   //             hasSentOffer: true,
//   //             isOfferAccepted: true,
//   //             onTap: () => showJobDetailsDialog(
//   //               context, request, _auth, _firestore),
//   //           );
//   //         }
          
//   //         // Use the new AcceptedJobCard for accepted offers
//   //         return AcceptedJobCard(
//   //           request: request,
//   //           acceptedOffer: acceptedOffer,
//   //           onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//   //           onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }
//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//   if (offers.isEmpty) {
//     return _buildEmptyState('No accepted offers', 'accepted');
//   }

//   return RefreshIndicator(
//     onRefresh: _loadOfferData,
//     color: JobConstants.primaryColor,
//     child: ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       itemCount: offers.length,
//       itemBuilder: (context, index) {
//         final request = offers[index];
//         final requestId = request.id;
        
//         // First check if we have the accepted offer data
//         if (_acceptedOffersMap.containsKey(requestId)) {
//           // If we have accepted offer data, use AcceptedJobCard
//           final acceptedOffer = _acceptedOffersMap[requestId]!;
//           return AcceptedJobCard(
//             request: request,
//             acceptedOffer: acceptedOffer,
//             onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//             onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//           );
//         } else {
//           // Otherwise, fallback to the standard JobCard
//           print("Warning: No accepted offer data found for request $requestId");
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: true,
//             onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//           );
//         }
//       },
//     ),
//   );
// }
//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// another change
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store accepted offers data keyed by request ID
//   Map<String, DocumentSnapshot> _acceptedOffersMap = {};
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByAcceptedOfferId = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) return;

//       // 1. Get all offers made by this mechanic
//       final offersSnapshot = await _firestore
//           .collection('offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();

//       // Get all request IDs from offers
//       final requestIds = offersSnapshot.docs
//           .map((doc) => doc.data()['requestId'] as String)
//           .toSet();

//       if (requestIds.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // Create a map of offers by their ID for quick lookup
//       final offersById = {
//         for (var doc in offersSnapshot.docs) doc.id: doc
//       };

//       // 2. Get all relevant request documents
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .where(FieldPath.documentId, whereIn: requestIds.toList())
//           .get();

//       // Create a map of request documents by ID for quick lookup
//       final requestDocsMap = {
//         for (var doc in requestsSnapshot.docs) doc.id: doc
//       };

//       // Create a map of offer documents by request ID for quick lookup
//       final offersByRequestId = <String, List<DocumentSnapshot>>{};
//       for (var offerDoc in offersSnapshot.docs) {
//         final requestId = offerDoc.data()['requestId'] as String;
//         offersByRequestId.putIfAbsent(requestId, () => []).add(offerDoc);
//       }

//       // 3. Get all accepted offers for this mechanic
//       final acceptedOffersSnapshot = await _firestore
//           .collection('accepted_offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();

//       // Create a map of accepted offer documents by request ID
//       final Map<String, DocumentSnapshot> acceptedOffersMap = {};
//       for (var doc in acceptedOffersSnapshot.docs) {
//         final data = doc.data();
//         final requestId = data['requestId'] as String;
//         acceptedOffersMap[requestId] = doc;
//       }

//       // 4. Group offers by status
//       final pendingOffers = <DocumentSnapshot>[];
//       final acceptedOffers = <DocumentSnapshot>[];
//       final completedOffers = <DocumentSnapshot>[];
//       // Map to store which offer was accepted for each request
//       final offersByAcceptedOfferId = <String, DocumentSnapshot>{};

//       for (final requestId in requestIds) {
//         final request = requestDocsMap[requestId];
//         if (request == null) continue;

//         final data = request.data();
//         final status = data['status'] as String? ?? 'pending';
//         final acceptedOfferId = data['acceptedOfferId'] as String?;

//         // Check if this mechanic's offer was accepted
//         final mechanicOfferAccepted = offersByRequestId[requestId]?.any(
//           (offerDoc) => offerDoc.id == acceptedOfferId
//         ) ?? false;

//         // If the mechanic's offer was accepted, store it in our map
//         if (mechanicOfferAccepted && acceptedOfferId != null && offersById.containsKey(acceptedOfferId)) {
//           offersByAcceptedOfferId[requestId] = offersById[acceptedOfferId]!;
//         }

//         if (status == 'completed') {
//           if (mechanicOfferAccepted) {
//             completedOffers.add(request);
//           }
//         } else if (mechanicOfferAccepted) {
//           acceptedOffers.add(request);
//         } else {
//           pendingOffers.add(request);
//         }
//       }

//       setState(() {
//         _pendingOffers = pendingOffers;
//         _acceptedOffers = acceptedOffers;
//         _completedOffers = completedOffers;
//         _acceptedOffersMap = acceptedOffersMap; // Store the map for accepted offers
//         _offersByAcceptedOfferId = offersByAcceptedOfferId; // Store accepted offers by offer ID
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Find the offer document to use - try multiple sources
//           DocumentSnapshot? offerToUse;
          
//           // 1. Check if we have it in accepted_offers collection
//           if (_acceptedOffersMap.containsKey(requestId)) {
//             offerToUse = _acceptedOffersMap[requestId];
//           }
//           // 2. Check if we have the accepted offer by ID
//           else if (_offersByAcceptedOfferId.containsKey(requestId)) {
//             offerToUse = _offersByAcceptedOfferId[requestId];
//           }
          
//           if (offerToUse != null) {
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerToUse,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // If we get here, we need to fetch the offer on demand
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   // Helper method to fetch an offer document
//   Future<DocumentSnapshot?> _fetchOfferDocument(String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       return await _firestore.collection('offers').doc(offerId).get();
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// here change
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByAcceptedOfferId = {};
  
//   // Define status categories for better classification
//   final Set<String> _completedStatuses = {'completed', 'Completed'};
//   final Set<String> _acceptedStatuses = {
//     'In Progress', 
//     'in progress', 
//     'ready for pickup', 
//     'Ready for pickup', 
//     'accepted', 
//     'Accepted'
//   };

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) return;

//       // Get all maintenance requests
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .get();
      
//       // Maps to store our categorized offers
//       Map<String, DocumentSnapshot> offersByRequestId = {};
//       List<DocumentSnapshot> pendingRequests = [];
//       List<DocumentSnapshot> acceptedRequests = [];
//       List<DocumentSnapshot> completedRequests = [];
      
//       // Process each request and check if this mechanic has an offer in its subcollection
//       for (var requestDoc in requestsSnapshot.docs) {
//         final requestId = requestDoc.id;
        
//         // Get the offers subcollection for this request
//         final offersSnapshot = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .where('mechanicId', isEqualTo: currentMechanicId)
//             .get();
        
//         // If no offers from this mechanic, skip this request
//         if (offersSnapshot.docs.isEmpty) continue;
        
//         // Get the request data
//         final requestData = requestDoc.data();
//         final status = requestData['status'] as String? ?? 'pending';
//         final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
//         // Check if this mechanic's offer was accepted
//         final mechanicOfferAccepted = offersSnapshot.docs.any(
//           (offerDoc) => offerDoc.id == acceptedOfferId
//         );
        
//         // If accepted, store the offer for later use
//         if (mechanicOfferAccepted && acceptedOfferId != null) {
//           final acceptedOfferDoc = offersSnapshot.docs.firstWhere(
//             (doc) => doc.id == acceptedOfferId,
//             orElse: () => offersSnapshot.docs.first,
//           );
//           offersByRequestId[requestId] = acceptedOfferDoc;
//           _offersByAcceptedOfferId[requestId] = acceptedOfferDoc;
//         } else if (offersSnapshot.docs.isNotEmpty) {
//           // Store the first offer for pending requests
//           offersByRequestId[requestId] = offersSnapshot.docs.first;
//         }
        
//         // Categorize the request based on status
//         if (_completedStatuses.contains(status)) {
//           if (mechanicOfferAccepted) {
//             completedRequests.add(requestDoc);
//           }
//         } else if (mechanicOfferAccepted || _acceptedStatuses.contains(status)) {
//           acceptedRequests.add(requestDoc);
//         } else {
//           pendingRequests.add(requestDoc);
//         }
//       }
      
//       setState(() {
//         _pendingOffers = pendingRequests;
//         _acceptedOffers = acceptedRequests;
//         _completedOffers = completedRequests;
//         _offersByAcceptedOfferId = offersByRequestId; // Store for quick lookup
//         _isLoading = false;
//       });
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Try to get the offer from our map first
//           if (_offersByAcceptedOfferId.containsKey(requestId)) {
//             final offerDoc = _offersByAcceptedOfferId[requestId]!;
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerDoc,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // Otherwise, fetch it on demand from the subcollection
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(requestId, acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       // First try the subcollection
//       DocumentSnapshot offerDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .doc(offerId)
//           .get();
          
//       if (offerDoc.exists) {
//         return offerDoc;
//       }
      
//       // Fall back to the old collection if needed (for backward compatibility)
//       return await _firestore.collection('offers').doc(offerId).get();
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//here 2
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByAcceptedOfferId = {};
  
//   // Define status categories for better classification - using normalized lowercase values
//   final Set<String> _completedStatuses = {'completed'};
//   final Set<String> _acceptedStatuses = {
//     'in progress', 
//     'ready for pickup', 
//     'parts ordered', 
//     'accepted'
//   };

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Helper method to normalize status strings
//   String _normalizeStatus(String? status) {
//     if (status == null) return 'pending';
//     return status.toLowerCase().trim();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) return;

//       // Get all maintenance requests
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .get();
      
//       // Maps to store our categorized offers
//       Map<String, DocumentSnapshot> offersByRequestId = {};
//       List<DocumentSnapshot> pendingRequests = [];
//       List<DocumentSnapshot> acceptedRequests = [];
//       List<DocumentSnapshot> completedRequests = [];
      
//       // Process each request and check if this mechanic has an offer in its subcollection
//       for (var requestDoc in requestsSnapshot.docs) {
//         final requestId = requestDoc.id;
        
//         // Get the offers subcollection for this request
//         final offersSnapshot = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .where('mechanicId', isEqualTo: currentMechanicId)
//             .get();
        
//         // If no offers from this mechanic, skip this request
//         if (offersSnapshot.docs.isEmpty) continue;
        
//         // Get the request data
//         final requestData = requestDoc.data();
//         final String normalizedStatus = _normalizeStatus(requestData['status'] as String?);
//         final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
//         // Check if this mechanic's offer was accepted
//         final mechanicOfferAccepted = offersSnapshot.docs.any(
//           (offerDoc) => offerDoc.id == acceptedOfferId
//         );
        
//         // Store the relevant offer for later use
//         if (mechanicOfferAccepted && acceptedOfferId != null) {
//           // Get the specific accepted offer document
//           final acceptedOfferDoc = offersSnapshot.docs.firstWhere(
//             (doc) => doc.id == acceptedOfferId,
//             orElse: () => offersSnapshot.docs.first,
//           );
//           offersByRequestId[requestId] = acceptedOfferDoc;
//         } else if (offersSnapshot.docs.isNotEmpty) {
//           // Store the first offer for pending requests
//           offersByRequestId[requestId] = offersSnapshot.docs.first;
//         }
        
//         // Categorize based on status and whether this mechanic's offer was accepted
//         if (_completedStatuses.contains(normalizedStatus)) {
//           if (mechanicOfferAccepted) {
//             completedRequests.add(requestDoc);
//           }
//         } else if (mechanicOfferAccepted || _acceptedStatuses.contains(normalizedStatus)) {
//           // If this mechanic's offer was accepted OR the status is in the accepted statuses
//           if (mechanicOfferAccepted) {
//             acceptedRequests.add(requestDoc);
//           }
//         } else {
//           // Pending requests are those without accepted offers
//           pendingRequests.add(requestDoc);
//         }
//       }
      
//       setState(() {
//         _pendingOffers = pendingRequests;
//         _acceptedOffers = acceptedRequests;
//         _completedOffers = completedRequests;
//         _offersByAcceptedOfferId = offersByRequestId; // Store for quick lookup
//         _isLoading = false;
//       });
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Try to get the offer from our map first
//           if (_offersByAcceptedOfferId.containsKey(requestId)) {
//             final offerDoc = _offersByAcceptedOfferId[requestId]!;
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerDoc,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // Otherwise, fetch it on demand from the subcollection
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(requestId, acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       // First try the subcollection
//       DocumentSnapshot offerDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .doc(offerId)
//           .get();
          
//       if (offerDoc.exists) {
//         // Cache this offer document for future use
//         _offersByAcceptedOfferId[requestId] = offerDoc;
//         return offerDoc;
//       }
      
//       // Fall back to the old collection if needed (for backward compatibility)
//       final legacyOfferDoc = await _firestore.collection('offers').doc(offerId).get();
//       if (legacyOfferDoc.exists) {
//         _offersByAcceptedOfferId[requestId] = legacyOfferDoc;
//         return legacyOfferDoc;
//       }
      
//       return null;
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// here good

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByRequestId = {};
  
//   // Define status categories for better classification - using normalized lowercase values
//   final Set<String> _completedStatuses = {'completed'};
//   final Set<String> _acceptedStatuses = {
//     'in progress', 
//     'ready for pickup', 
//     'parts ordered', 
//     'accepted'
//   };
//   final Set<String> _pendingStatuses = {'pending', 'awaiting_acceptance'};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Helper method to normalize status strings
//   String _normalizeStatus(String? status) {
//     if (status == null) return 'pending';
//     return status.toLowerCase().trim();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//       // Clear previous data
//       _pendingOffers = [];
//       _acceptedOffers = [];
//       _completedOffers = [];
//       _offersByRequestId = {};
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       print('Loading data for mechanic: $currentMechanicId');

//       // First, query all maintenance requests where this mechanic has been assigned
//       final acceptedRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .where('acceptedMechanicId', isEqualTo: currentMechanicId)
//           .get();
      
//       print('Found ${acceptedRequestsQuery.docs.length} requests assigned to this mechanic');
      
//       // Process assigned requests first
//       for (var requestDoc in acceptedRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
//         final String normalizedStatus = _normalizeStatus(requestData['status'] as String?);
//         final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
//         print('Processing assigned request: $requestId with status: $normalizedStatus');
        
//         // Fetch the accepted offer document if available
//         if (acceptedOfferId != null) {
//           DocumentSnapshot? offerDoc = await _fetchOfferDocument(requestId, acceptedOfferId);
//           if (offerDoc != null) {
//             _offersByRequestId[requestId] = offerDoc;
//           }
//         }
        
//         // Categorize by status
//         if (_completedStatuses.contains(normalizedStatus)) {
//           _completedOffers.add(requestDoc);
//         } else {
//           // All non-completed accepted requests go to the accepted tab
//           _acceptedOffers.add(requestDoc);
//         }
//       }
      
//       // Then, find all requests where the mechanic has made an offer but it's not yet accepted
//       final allRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .get();
      
//       for (var requestDoc in allRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
        
//         // Skip requests we've already processed (those assigned to this mechanic)
//         if (requestData.containsKey('acceptedMechanicId') && 
//             requestData['acceptedMechanicId'] == currentMechanicId) {
//           continue;
//         }
        
//         // Check if this mechanic has made an offer for this request
//         final offersQuery = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .where('mechanicId', isEqualTo: currentMechanicId)
//             .get();
        
//         if (offersQuery.docs.isEmpty) continue; // No offers from this mechanic
        
//         // Store the first offer document for reference
//         _offersByRequestId[requestId] = offersQuery.docs.first;
        
//         // This is a pending offer (mechanic made an offer but it's not accepted yet)
//         _pendingOffers.add(requestDoc);
//       }
      
//       setState(() {
//         _isLoading = false;
//       });
      
//       print('Loaded: ${_pendingOffers.length} pending, ${_acceptedOffers.length} accepted, ${_completedOffers.length} completed');
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Try to get the offer from our map first
//           if (_offersByRequestId.containsKey(requestId)) {
//             final offerDoc = _offersByRequestId[requestId]!;
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerDoc,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // Otherwise, fetch it on demand from the subcollection
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(requestId, acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       // First try the subcollection
//       DocumentSnapshot offerDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .doc(offerId)
//           .get();
          
//       if (offerDoc.exists) {
//         // Cache this offer document for future use
//         _offersByRequestId[requestId] = offerDoc;
//         return offerDoc;
//       }
      
//       // Fall back to the old collection if needed (for backward compatibility)
//       final legacyOfferDoc = await _firestore.collection('offers').doc(offerId).get();
//       if (legacyOfferDoc.exists) {
//         _offersByRequestId[requestId] = legacyOfferDoc;
//         return legacyOfferDoc;
//       }
      
//       return null;
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// here good?
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByRequestId = {};
  
//   // Define status categories for better classification - using normalized lowercase values
//   final Set<String> _completedStatuses = {'completed'};
//   // Add "ready for pickup" only to _acceptedStatuses, not to both
//   final Set<String> _acceptedStatuses = {
//     'in progress', 
//     'ready for pickup', 
//     'parts ordered', 
//     'accepted'
//   };
//   final Set<String> _pendingStatuses = {'pending', 'awaiting_acceptance'};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Helper method to normalize status strings
//   String _normalizeStatus(String? status) {
//     if (status == null) return 'pending';
//     return status.toLowerCase().trim();
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//       // Clear previous data
//       _pendingOffers = [];
//       _acceptedOffers = [];
//       _completedOffers = [];
//       _offersByRequestId = {};
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       print('Loading data for mechanic: $currentMechanicId');

//       // First, query all maintenance requests where this mechanic has been assigned
//       final acceptedRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .where('acceptedMechanicId', isEqualTo: currentMechanicId)
//           .get();
      
//       print('Found ${acceptedRequestsQuery.docs.length} requests assigned to this mechanic');
      
//       // Process assigned requests first
//       for (var requestDoc in acceptedRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
//         final String normalizedStatus = _normalizeStatus(requestData['status'] as String?);
//         final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
//         print('Processing assigned request: $requestId with status: $normalizedStatus');
        
//         // Fetch the accepted offer document if available
//         if (acceptedOfferId != null) {
//           DocumentSnapshot? offerDoc = await _fetchOfferDocument(requestId, acceptedOfferId);
//           if (offerDoc != null) {
//             _offersByRequestId[requestId] = offerDoc;
//           }
//         }
        
//         // Fixed: Properly categorize by normalized status
//         if (_completedStatuses.contains(normalizedStatus)) {
//           _completedOffers.add(requestDoc);
//         } else if (_acceptedStatuses.contains(normalizedStatus)) {
//           // All non-completed accepted requests go to the accepted tab
//           _acceptedOffers.add(requestDoc);
//         } else {
//           // If it doesn't match any other category, it goes to pending
//           _pendingOffers.add(requestDoc);
//         }
//       }
      
//       // Then, find all requests where the mechanic has made an offer but it's not yet accepted
//       final allRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .get();
      
//       for (var requestDoc in allRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
        
//         // Skip requests we've already processed (those assigned to this mechanic)
//         if (requestData.containsKey('acceptedMechanicId') && 
//             requestData['acceptedMechanicId'] == currentMechanicId) {
//           continue;
//         }
        
//         // Check if this mechanic has made an offer for this request
//         final offersQuery = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .where('mechanicId', isEqualTo: currentMechanicId)
//             .get();
        
//         if (offersQuery.docs.isEmpty) continue; // No offers from this mechanic
        
//         // Store the first offer document for reference
//         _offersByRequestId[requestId] = offersQuery.docs.first;
        
//         // This is a pending offer (mechanic made an offer but it's not accepted yet)
//         _pendingOffers.add(requestDoc);
//       }
      
//       setState(() {
//         _isLoading = false;
//       });
      
//       print('Loaded: ${_pendingOffers.length} pending, ${_acceptedOffers.length} accepted, ${_completedOffers.length} completed');
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Try to get the offer from our map first
//           if (_offersByRequestId.containsKey(requestId)) {
//             final offerDoc = _offersByRequestId[requestId]!;
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerDoc,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // Otherwise, fetch it on demand from the subcollection
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(requestId, acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       // First try the subcollection
//       DocumentSnapshot offerDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .doc(offerId)
//           .get();
          
//       if (offerDoc.exists) {
//         // Cache this offer document for future use
//         _offersByRequestId[requestId] = offerDoc;
//         return offerDoc;
//       }
      
//       // Fall back to the old collection if needed (for backward compatibility)
//       final legacyOfferDoc = await _firestore.collection('offers').doc(offerId).get();
//       if (legacyOfferDoc.exists) {
//         _offersByRequestId[requestId] = legacyOfferDoc;
//         return legacyOfferDoc;
//       }
      
//       return null;
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   // Fixed: Added support for changing "Ready for Pickup" status and better validation
//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ),
//         ),
//       );
      
//       // Get the current request data to verify status
//       DocumentSnapshot requestDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .get();
          
//       Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
//       String currentStatus = requestData['status'] as String? ?? 'pending';
//       String normalizedCurrentStatus = _normalizeStatus(currentStatus);
//       String normalizedNewStatus = _normalizeStatus(newStatus);
      
//       // Debug output
//       print('Updating job status from: $currentStatus ($normalizedCurrentStatus) to: $newStatus ($normalizedNewStatus)');
      
//       // Define valid transitions - use normalized values
//       Map<String, List<String>> validTransitions = {
//         'pending': ['in progress', 'parts ordered'],
//         'accepted': ['in progress', 'parts ordered'],
//         'in progress': ['parts ordered', 'ready for pickup'],
//         'parts ordered': ['in progress', 'ready for pickup'],
//         'ready for pickup': ['completed'],
//       };
      
//       // Check if this is a valid status transition
//       bool isValidTransition = false;
      
//       if (validTransitions.containsKey(normalizedCurrentStatus)) {
//         isValidTransition = validTransitions[normalizedCurrentStatus]!.contains(normalizedNewStatus);
//       }
      
//       // Special case: Allow changing from 'Ready for Pickup' back to other statuses
//       if (normalizedCurrentStatus == 'ready for pickup' && 
//           (normalizedNewStatus == 'in progress' || normalizedNewStatus == 'parts ordered')) {
//         isValidTransition = true;
//       }
      
//       if (!isValidTransition) {
//         // Close loading dialog
//         Navigator.pop(context);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Cannot change status from $currentStatus to $newStatus'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
      
//       // Update the request with new status
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus, // Keep original casing
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       // Close loading dialog
//       Navigator.pop(context);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       // Close loading dialog if it's open
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
      
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// work good 1000!!

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import 'widgets/accepted_job_card.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';
// import 'mechanic_jobs_screen.dart';

// class MechanicOffersScreen extends StatefulWidget {
//   const MechanicOffersScreen({super.key});

//   @override
//   State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
// }

// class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 1; // This screen is at index 1 now in navbar
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _pendingOffers = [];
//   List<DocumentSnapshot> _acceptedOffers = [];
//   List<DocumentSnapshot> _completedOffers = [];
//   // Map to store offer documents by request ID
//   Map<String, DocumentSnapshot> _offersByRequestId = {};
  
//   // Define status categories for better classification - using normalized lowercase values
//   final Set<String> _completedStatuses = {'completed'};
//   final Set<String> _acceptedStatuses = {
//     'in progress', 
//     'ready for pickup', 
//     'parts ordered', 
//     'accepted'
//   };
//   final Set<String> _pendingStatuses = {'pending', 'awaiting_acceptance'};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadOfferData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Helper method to normalize status strings
//   String _normalizeStatus(String? status) {
//     if (status == null) return 'pending';
//     return status.toLowerCase().trim();
//   }

//   // Check for "Ready for Pickup" jobs in the wrong category
//   void _fixMiscategorizedJobs() {
//     // Create a new list to hold pending offers that actually belong in pending
//     List<DocumentSnapshot> correctPendingOffers = [];
//     List<DocumentSnapshot> misplacedOffers = [];
    
//     // Check all pending offers
//     for (var request in _pendingOffers) {
//       final data = request.data() as Map<String, dynamic>;
//       final status = data['status'] as String? ?? '';
//       final normalizedStatus = _normalizeStatus(status);
      
//       // If this is a "Ready for Pickup" or any accepted status, move it
//       if (normalizedStatus == 'ready for pickup' || _acceptedStatuses.contains(normalizedStatus)) {
//         misplacedOffers.add(request);
//       } else {
//         correctPendingOffers.add(request);
//       }
//     }
    
//     // Only update state if we found misplaced offers
//     if (misplacedOffers.isNotEmpty) {
//       setState(() {
//         _pendingOffers = correctPendingOffers;
//         _acceptedOffers = [..._acceptedOffers, ...misplacedOffers];
//       });
      
//       print('Fixed categorization: Moved ${misplacedOffers.length} offers from Pending to Accepted');
//     }
//   }

//   Future<void> _loadOfferData() async {
//     setState(() {
//       _isLoading = true;
//       // Clear previous data
//       _pendingOffers = [];
//       _acceptedOffers = [];
//       _completedOffers = [];
//       _offersByRequestId = {};
//     });

//     try {
//       final String currentMechanicId = _auth.currentUser?.uid ?? '';
//       if (currentMechanicId.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       print('Loading data for mechanic: $currentMechanicId');

//       // First, query all maintenance requests where this mechanic has been assigned
//       final acceptedRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .where('acceptedMechanicId', isEqualTo: currentMechanicId)
//           .get();
      
//       print('Found ${acceptedRequestsQuery.docs.length} requests assigned to this mechanic');
      
//       // Process assigned requests first
//       for (var requestDoc in acceptedRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
//         String status = requestData['status'] as String? ?? 'pending';
//         final String normalizedStatus = _normalizeStatus(status);
//         final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
//         print('Processing request: $requestId with status: "$status" (normalized: "$normalizedStatus")');
        
//         // Fetch the accepted offer document if available
//         if (acceptedOfferId != null) {
//           DocumentSnapshot? offerDoc = await _fetchOfferDocument(requestId, acceptedOfferId);
//           if (offerDoc != null) {
//             _offersByRequestId[requestId] = offerDoc;
//           }
//         }
        
//         // Explicitly handle "Ready for Pickup" status
//         if (normalizedStatus == 'ready for pickup') {
//           _acceptedOffers.add(requestDoc);
//           print('Added to ACCEPTED (Ready for Pickup): $requestId');
//         }
//         // Handle other statuses
//         else if (_completedStatuses.contains(normalizedStatus)) {
//           _completedOffers.add(requestDoc);
//           print('Added to COMPLETED: $requestId');
//         } 
//         else if (_acceptedStatuses.contains(normalizedStatus)) {
//           _acceptedOffers.add(requestDoc);
//           print('Added to ACCEPTED: $requestId');
//         } 
//         else {
//           _pendingOffers.add(requestDoc);
//           print('Added to PENDING: $requestId');
//         }
//       }
      
//       // Then, find all requests where the mechanic has made an offer but it's not yet accepted
//       final allRequestsQuery = await _firestore
//           .collection('maintenance_requests')
//           .get();
      
//       for (var requestDoc in allRequestsQuery.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
        
//         // Skip requests we've already processed (those assigned to this mechanic)
//         if (requestData.containsKey('acceptedMechanicId') && 
//             requestData['acceptedMechanicId'] == currentMechanicId) {
//           continue;
//         }
        
//         // Check if this mechanic has made an offer for this request
//         final offersQuery = await _firestore
//             .collection('maintenance_requests')
//             .doc(requestId)
//             .collection('offers')
//             .where('mechanicId', isEqualTo: currentMechanicId)
//             .get();
        
//         if (offersQuery.docs.isEmpty) continue; // No offers from this mechanic
        
//         // Store the first offer document for reference
//         _offersByRequestId[requestId] = offersQuery.docs.first;
        
//         // This is a pending offer (mechanic made an offer but it's not accepted yet)
//         _pendingOffers.add(requestDoc);
//       }
      
//       // After loading data, fix any miscategorized jobs
//       _fixMiscategorizedJobs();
      
//       setState(() {
//         _isLoading = false;
//       });
      
//       print('Loaded: ${_pendingOffers.length} pending, ${_acceptedOffers.length} accepted, ${_completedOffers.length} completed');
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'My Offers',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: JobConstants.primaryColor,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: JobConstants.primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending (${_pendingOffers.length})',
//                   icon: const Icon(Icons.hourglass_empty),
//                 ),
//                 Tab(
//                   text: 'Accepted (${_acceptedOffers.length})',
//                   icon: const Icon(Icons.check_circle_outline),
//                 ),
//                 Tab(
//                   text: 'Completed (${_completedOffers.length})',
//                   icon: const Icon(Icons.done_all),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(
//                     color: JobConstants.primaryColor,
//                   ))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildOffersList(_pendingOffers, 'pending'),
//                       _buildAcceptedOffersList(_acceptedOffers), // Special list for accepted offers
//                       _buildOffersList(_completedOffers, 'completed'),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No $type offers', type);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           return JobCardWidget(
//             request: request,
//             hasSentOffer: true,
//             isOfferAccepted: type == 'accepted' || type == 'completed',
//             onTap: () => showJobDetailsDialog(
//               context, request, _auth, _firestore),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
//     if (offers.isEmpty) {
//       return _buildEmptyState('No accepted offers', 'accepted');
//     }

//     return RefreshIndicator(
//       onRefresh: _loadOfferData,
//       color: JobConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: offers.length,
//         itemBuilder: (context, index) {
//           final request = offers[index];
//           final requestId = request.id;
//           final requestData = request.data() as Map<String, dynamic>;
//           final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
//           // Try to get the offer from our map first
//           if (_offersByRequestId.containsKey(requestId)) {
//             final offerDoc = _offersByRequestId[requestId]!;
//             return AcceptedJobCard(
//               request: request,
//               acceptedOffer: offerDoc,
//               onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//             );
//           }
          
//           // Otherwise, fetch it on demand from the subcollection
//           return FutureBuilder<DocumentSnapshot?>(
//             future: _fetchOfferDocument(requestId, acceptedOfferId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Card(
//                   margin: EdgeInsets.only(bottom: 12),
//                   child: SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()),
//                   ),
//                 );
//               }
              
//               if (snapshot.hasData && snapshot.data != null) {
//                 return AcceptedJobCard(
//                   request: request,
//                   acceptedOffer: snapshot.data!,
//                   onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//                   onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
//                 );
//               }
              
//               // Fall back to simple JobCard if we couldn't find an offer document
//               return JobCardWidget(
//                 request: request,
//                 hasSentOffer: true,
//                 isOfferAccepted: true,
//                 onTap: () => showJobDetailsDialog(context, request, _auth, _firestore),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
  
//   Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
//     if (offerId == null) return null;
    
//     try {
//       // First try the subcollection
//       DocumentSnapshot offerDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .collection('offers')
//           .doc(offerId)
//           .get();
          
//       if (offerDoc.exists) {
//         // Cache this offer document for future use
//         _offersByRequestId[requestId] = offerDoc;
//         return offerDoc;
//       }
      
//       // Fall back to the old collection if needed (for backward compatibility)
//       final legacyOfferDoc = await _firestore.collection('offers').doc(offerId).get();
//       if (legacyOfferDoc.exists) {
//         _offersByRequestId[requestId] = legacyOfferDoc;
//         return legacyOfferDoc;
//       }
      
//       return null;
//     } catch (e) {
//       print('Error fetching offer document: $e');
//       return null;
//     }
//   }

//   // Fixed: Modified to allow changing status 
//   Future<void> _updateJobStatus(String requestId, String newStatus) async {
//     try {
//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ),
//         ),
//       );
      
//       // Get the current request data
//       DocumentSnapshot requestDoc = await _firestore
//           .collection('maintenance_requests')
//           .doc(requestId)
//           .get();
          
//       Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
//       String currentStatus = requestData['status'] as String? ?? 'pending';
      
//       // Debug output
//       print('Updating job status: $currentStatus -> $newStatus');
      
//       // Update the request with new status
//       await _firestore.collection('maintenance_requests').doc(requestId).update({
//         'status': newStatus,
//         'statusUpdatedAt': FieldValue.serverTimestamp(),
//       });
      
//       // Close loading dialog
//       Navigator.pop(context);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Refresh data
//       _loadOfferData();
//     } catch (e) {
//       // Close loading dialog if it's open
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
      
//       print('Error updating job status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildEmptyState(String message, String type) {
//     IconData icon;
//     String actionText;
    
//     switch (type) {
//       case 'pending':
//         icon = Icons.hourglass_empty;
//         actionText = 'Browse Jobs';
//         break;
//       case 'accepted':
//         icon = Icons.check_circle_outline;
//         actionText = 'Browse Jobs';
//         break;
//       case 'completed':
//         icon = Icons.done_all;
//         actionText = 'View History';
//         break;
//       default:
//         icon = Icons.assignment_outlined;
//         actionText = 'Browse Jobs';
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon, 
//             size: 64, 
//             color: Colors.grey[400]
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type == 'pending' 
//                 ? 'Send offers to jobs to see them here'
//                 : type == 'accepted'
//                     ? 'When customers accept your offers, they\'ll appear here'
//                     : 'Your job history will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               if (type == 'pending' || type == 'accepted') {
//                 // Navigate to Jobs screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
//                 );
//               } else {
//                 // Just refresh this screen for history
//                 _loadOfferData();
//               }
//             },
//             icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
//             label: Text(actionText),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//               side: const BorderSide(color: JobConstants.primaryColor),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/mechanic_navbar.dart';
import './widgets/job_card.dart';
import 'widgets/accepted_job_card.dart';
import './dialogs/jop_details_dialogs.dart';
import 'utils/constants.dart';
import 'mechanic_jobs_screen.dart';

class MechanicOffersScreen extends StatefulWidget {
  const MechanicOffersScreen({super.key});

  @override
  State<MechanicOffersScreen> createState() => _MechanicOffersScreenState();
}

class _MechanicOffersScreenState extends State<MechanicOffersScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 1; // This screen is at index 1 now in navbar
  late TabController _tabController;
  bool _isLoading = true;
  List<DocumentSnapshot> _pendingOffers = [];
  List<DocumentSnapshot> _acceptedOffers = [];
  List<DocumentSnapshot> _completedOffers = [];
  // Map to store offer documents by request ID
  Map<String, DocumentSnapshot> _offersByRequestId = {};
  
  // Define status categories for better classification - using normalized lowercase values
  final Set<String> _completedStatuses = {'completed'};
  final Set<String> _acceptedStatuses = {
    'in progress', 
    'ready for pickup', 
    'parts ordered', 
    'accepted'
  };
  final Set<String> _pendingStatuses = {'pending', 'awaiting_acceptance'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOfferData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to normalize status strings
  String _normalizeStatus(String? status) {
    if (status == null) return 'pending';
    return status.toLowerCase().trim();
  }

  // Check for "Ready for Pickup" jobs in the wrong category
  void _fixMiscategorizedJobs() {
    // Create a new list to hold pending offers that actually belong in pending
    List<DocumentSnapshot> correctPendingOffers = [];
    List<DocumentSnapshot> misplacedOffers = [];
    
    // Check all pending offers
    for (var request in _pendingOffers) {
      final data = request.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      final normalizedStatus = _normalizeStatus(status);
      
      // If this is a "Ready for Pickup" or any accepted status, move it
      if (normalizedStatus == 'ready for pickup' || _acceptedStatuses.contains(normalizedStatus)) {
        misplacedOffers.add(request);
      } else {
        correctPendingOffers.add(request);
      }
    }
    
    // Only update state if we found misplaced offers
    if (misplacedOffers.isNotEmpty) {
      setState(() {
        _pendingOffers = correctPendingOffers;
        _acceptedOffers = [..._acceptedOffers, ...misplacedOffers];
      });
      
      print('Fixed categorization: Moved ${misplacedOffers.length} offers from Pending to Accepted');
    }
  }

  Future<void> _loadOfferData() async {
    setState(() {
      _isLoading = true;
      // Clear previous data
      _pendingOffers = [];
      _acceptedOffers = [];
      _completedOffers = [];
      _offersByRequestId = {};
    });

    try {
      final String currentMechanicId = _auth.currentUser?.uid ?? '';
      if (currentMechanicId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Loading data for mechanic: $currentMechanicId');

      // First, query all maintenance requests where this mechanic has been assigned
      final acceptedRequestsQuery = await _firestore
          .collection('maintenance_requests')
          .where('acceptedMechanicId', isEqualTo: currentMechanicId)
          .get();
      
      print('Found ${acceptedRequestsQuery.docs.length} requests assigned to this mechanic');
      
      // Process assigned requests first
      for (var requestDoc in acceptedRequestsQuery.docs) {
        final requestId = requestDoc.id;
        final requestData = requestDoc.data();
        String status = requestData['status'] as String? ?? 'pending';
        final String normalizedStatus = _normalizeStatus(status);
        final acceptedOfferId = requestData['acceptedOfferId'] as String?;
        
        print('Processing request: $requestId with status: "$status" (normalized: "$normalizedStatus")');
        
        // Fetch the accepted offer document if available
        if (acceptedOfferId != null) {
          DocumentSnapshot? offerDoc = await _fetchOfferDocument(requestId, acceptedOfferId);
          if (offerDoc != null) {
            _offersByRequestId[requestId] = offerDoc;
          }
        }
        
        // Explicitly handle "Ready for Pickup" status
        if (normalizedStatus == 'ready for pickup') {
          _acceptedOffers.add(requestDoc);
          print('Added to ACCEPTED (Ready for Pickup): $requestId');
        }
        // Handle other statuses
        else if (_completedStatuses.contains(normalizedStatus)) {
          _completedOffers.add(requestDoc);
          print('Added to COMPLETED: $requestId');
        } 
        else if (_acceptedStatuses.contains(normalizedStatus)) {
          _acceptedOffers.add(requestDoc);
          print('Added to ACCEPTED: $requestId');
        } 
        else {
          _pendingOffers.add(requestDoc);
          print('Added to PENDING: $requestId');
        }
      }
      
      // Then, find all requests where the mechanic has made an offer but it's not yet accepted
      final allRequestsQuery = await _firestore
          .collection('maintenance_requests')
          .get();
      
      for (var requestDoc in allRequestsQuery.docs) {
        final requestId = requestDoc.id;
        final requestData = requestDoc.data();
        
        // Skip requests we've already processed (those assigned to this mechanic)
        if (requestData.containsKey('acceptedMechanicId') && 
            requestData['acceptedMechanicId'] == currentMechanicId) {
          continue;
        }
        
        // Check if this mechanic has made an offer for this request
        // First, check in the subcollection
        final offersQuery = await _firestore
            .collection('maintenance_requests')
            .doc(requestId)
            .collection('offers')
            .where('mechanicId', isEqualTo: currentMechanicId)
            .get();
        
        if (offersQuery.docs.isNotEmpty) {
          // Store the first offer document for reference
          _offersByRequestId[requestId] = offersQuery.docs.first;
          // This is a pending offer (mechanic made an offer but it's not accepted yet)
          _pendingOffers.add(requestDoc);
          continue;
        }
        
        // If not found in subcollection, check in root 'offers' collection (legacy support)
        final legacyOffersQuery = await _firestore
            .collection('offers')
            .where('requestId', isEqualTo: requestId)
            .where('mechanicId', isEqualTo: currentMechanicId)
            .get();
            
        if (legacyOffersQuery.docs.isNotEmpty) {
          // Store the offer document for reference
          _offersByRequestId[requestId] = legacyOffersQuery.docs.first;
          // This is a pending offer
          _pendingOffers.add(requestDoc);
        }
      }
      
      // After loading data, fix any miscategorized jobs
      _fixMiscategorizedJobs();
      
      setState(() {
        _isLoading = false;
      });
      
      print('Loaded: ${_pendingOffers.length} pending, ${_acceptedOffers.length} accepted, ${_completedOffers.length} completed');
      
    } catch (e) {
      print('Error loading offer data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(
        pageName: 'My Offers',
        color: JobConstants.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: JobConstants.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: JobConstants.primaryColor,
              tabs: [
                Tab(
                  text: 'Pending (${_pendingOffers.length})',
                  icon: const Icon(Icons.hourglass_empty),
                ),
                Tab(
                  text: 'Accepted (${_acceptedOffers.length})',
                  icon: const Icon(Icons.check_circle_outline),
                ),
                Tab(
                  text: 'Completed (${_completedOffers.length})',
                  icon: const Icon(Icons.done_all),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: JobConstants.primaryColor,
                  ))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOffersList(_pendingOffers, 'pending'),
                      _buildAcceptedOffersList(_acceptedOffers),
                      _buildOffersList(_completedOffers, 'completed'),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MechanicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildOffersList(List<DocumentSnapshot> offers, String type) {
    if (offers.isEmpty) {
      return _buildEmptyState('No $type offers', type);
    }

    return RefreshIndicator(
      onRefresh: _loadOfferData,
      color: JobConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final request = offers[index];
          final existingOffer = _offersByRequestId[request.id];
          return JobCardWidget(
            request: request,
            hasSentOffer: true,
            isOfferAccepted: type == 'accepted' || type == 'completed',
            onTap: () => showJobDetailsDialog(
              context, 
              request, 
              _auth, 
              _firestore,
              existingOffer: existingOffer  // Pass existing offer if available
            ),
          );
        },
      ),
    );
  }

  Widget _buildAcceptedOffersList(List<DocumentSnapshot> offers) {
    if (offers.isEmpty) {
      return _buildEmptyState('No accepted offers', 'accepted');
    }

    return RefreshIndicator(
      onRefresh: _loadOfferData,
      color: JobConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final request = offers[index];
          final requestId = request.id;
          final requestData = request.data() as Map<String, dynamic>;
          final acceptedOfferId = requestData['acceptedOfferId'] as String?;
          
          // Try to get the offer from our map first
          if (_offersByRequestId.containsKey(requestId)) {
            final offerDoc = _offersByRequestId[requestId]!;
            return AcceptedJobCard(
              request: request,
              acceptedOffer: offerDoc,
              onTap: () => showJobDetailsDialog(
                context, 
                request, 
                _auth, 
                _firestore,
                existingOffer: offerDoc  // Pass existing offer
              ),
              onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
            );
          }
          
          // Otherwise, fetch it on demand from the subcollection
          return FutureBuilder<DocumentSnapshot?>(
            future: _fetchOfferDocument(requestId, acceptedOfferId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              
              if (snapshot.hasData && snapshot.data != null) {
                return AcceptedJobCard(
                  request: request,
                  acceptedOffer: snapshot.data!,
                  onTap: () => showJobDetailsDialog(
                    context, 
                    request, 
                    _auth, 
                    _firestore,
                    existingOffer: snapshot.data  // Pass existing offer
                  ),
                  onStatusChange: (newStatus) => _updateJobStatus(requestId, newStatus),
                );
              }
              
              // Fall back to simple JobCard if we couldn't find an offer document
              return JobCardWidget(
                request: request,
                hasSentOffer: true,
                isOfferAccepted: true,
                onTap: () => showJobDetailsDialog(
                  context, 
                  request, 
                  _auth, 
                  _firestore
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<DocumentSnapshot?> _fetchOfferDocument(String requestId, String? offerId) async {
    if (offerId == null) return null;
    
    try {
      // First try the subcollection
      DocumentSnapshot offerDoc = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .collection('offers')
          .doc(offerId)
          .get();
          
      if (offerDoc.exists) {
        // Cache this offer document for future use
        _offersByRequestId[requestId] = offerDoc;
        return offerDoc;
      }
      
      // Fall back to the old collection if needed (for backward compatibility)
      final legacyOfferDoc = await _firestore.collection('offers').doc(offerId).get();
      if (legacyOfferDoc.exists) {
        _offersByRequestId[requestId] = legacyOfferDoc;
        return legacyOfferDoc;
      }
      
      return null;
    } catch (e) {
      print('Error fetching offer document: $e');
      return null;
    }
  }

  // Fixed: Modified to allow changing status 
  Future<void> _updateJobStatus(String requestId, String newStatus) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: JobConstants.primaryColor,
          ),
        ),
      );
      
      // Get the current request data
      DocumentSnapshot requestDoc = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .get();
          
      Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
      String currentStatus = requestData['status'] as String? ?? 'pending';
      
      // Debug output
      print('Updating job status: $currentStatus -> $newStatus');
      
      // Update the request with new status
      await _firestore.collection('maintenance_requests').doc(requestId).update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job status updated to ${JobConstants.filterDisplayNames[newStatus] ?? newStatus}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh data
      _loadOfferData();
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Error updating job status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update job status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState(String message, String type) {
    IconData icon;
    String actionText;
    
    switch (type) {
      case 'pending':
        icon = Icons.hourglass_empty;
        actionText = 'Browse Jobs';
        break;
      case 'accepted':
        icon = Icons.check_circle_outline;
        actionText = 'Browse Jobs';
        break;
      case 'completed':
        icon = Icons.done_all;
        actionText = 'View History';
        break;
      default:
        icon = Icons.assignment_outlined;
        actionText = 'Browse Jobs';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 64, 
            color: Colors.grey[400]
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            type == 'pending' 
                ? 'Send offers to jobs to see them here'
                : type == 'accepted'
                    ? 'When customers accept your offers, they\'ll appear here'
                    : 'Your job history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              if (type == 'pending' || type == 'accepted') {
                // Navigate to Jobs screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MechanicJobsScreen()),
                );
              } else {
                // Just refresh this screen for history
                _loadOfferData();
              }
            },
            icon: Icon(type == 'completed' ? Icons.refresh : Icons.work_outline),
            label: Text(actionText),
            style: OutlinedButton.styleFrom(
              foregroundColor: JobConstants.primaryColor,
              side: const BorderSide(color: JobConstants.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}