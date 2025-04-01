// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';
// // import 'package:diacritic/diacritic.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Jobs',
//         color: Color.fromARGB(255, 208, 63, 2),
//       ),
//       body: Column(
//         children: [
//           SearchFilterWidget(
//             onFilterChanged: (filter) =>
//                 setState(() => _selectedFilter = filter),
//             onSearchChanged: (query) => setState(() => _searchQuery = query),
//             selectedFilter: _selectedFilter,
//           ),
//           Expanded(child: _buildJobsList()),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//     Widget _buildJobsList() {
//     final currentUserId = _auth.currentUser?.uid ?? '';

//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }

//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';

//         return StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('maintenance_requests').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No maintenance requests available');
//             }

//             // First filter the requests based on mechanic's city
//             var initialFiltered = _filterRequests(snapshot.data!.docs, mechanicCity);

//             return FutureBuilder<List<DocumentSnapshot>>(
//               future: _filterInProgressRequests(initialFiltered),
//               builder: (context, asyncSnapshot) {
//                 if (asyncSnapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final filteredRequests = asyncSnapshot.data ?? [];

//                 if (filteredRequests.isEmpty) {
//                   return _buildEmptyState('No requests available in your city');
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredRequests.length,
//                   itemBuilder: (context, index) => JobCardWidget(
//                     request: filteredRequests[index],
//                     onTap: () => showJobDetailsDialog(
//                         context, filteredRequests[index], _auth, _firestore),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }



//   Future<List<DocumentSnapshot>> _filterInProgressRequests(
//       List<DocumentSnapshot> requests) async {
//     final currentUserId = _auth.currentUser?.uid ?? '';
//     List<DocumentSnapshot> result = [];

//     for (var doc in requests) {
//       final data = doc.data() as Map<String, dynamic>;
//       final status = data['status'] ?? 'pending';

//       // If the request is in progress, check if this mechanic made an offer
//       if (status == 'In Progress') {
//         // Query to check if this mechanic has an offer for this request
//         final offerQuery = await _firestore
//             .collection('offers')
//             .where('requestId', isEqualTo: doc.id)
//             .where('mechanicId', isEqualTo: currentUserId)
//             .get();

//         // Only include if the mechanic has made an offer
//         if (offerQuery.docs.isNotEmpty) {
//           result.add(doc);
//         }
//       } else {
//         // For all other statuses, include the request
//         result.add(doc);
//       }
//     }

//     return result;
//   }

// //   //there is a problem in comparing city names
// //   String normalizeCity(String city) {
// //   return removeDiacritics(city.trim().toLowerCase());
// // }



//     List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//     return requests.where((doc) {
//       final requestCity = (doc['city'] ?? '').toLowerCase();
      
//       // Filter by mechanic's city
//       if (requestCity != mechanicCity.toLowerCase()) {
//         return false;
//       }

//       // Filter by status if not 'All'
//       if (_selectedFilter != 'All' && doc['status'] != _selectedFilter) {
//         return false;
//       }

//       // Apply search filter
//       if (_searchQuery.isNotEmpty) {
//         var searchLower = _searchQuery.toLowerCase();
//         String carInfo = (doc['car'] ?? '').toLowerCase();
//         String cityInfo = (doc['city'] ?? '').toLowerCase();
//         String problemInfo = (doc['problemDescription'] ?? '').toLowerCase();

//         return carInfo.contains(searchLower) ||
//             cityInfo.contains(searchLower) ||
//             problemInfo.contains(searchLower);
//       }

//       return true;
//     }).toList();
//   }



//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// first change

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedStatus = 'all';
//   String _searchQuery = '';
//   late TabController _tabController;
  
//   // Define all possible statuses
//   final List<String> _statuses = [
//     'all',
//     'pending',
//     'parts ordered',
//     'in progress',
//     'ready for pickup'
//   ];
  
//   // Define tab indices to status mapping
//   final Map<int, String> _tabToStatus = {
//     0: 'all',
//     1: 'pending',
//     2: 'parts ordered',
//     3: 'in progress',
//     4: 'ready for pickup',
//   };
  
//   @override
//   void initState() {
//     super.initState();
//     // Create tab controller with 5 tabs (All + 4 statuses)
//     _tabController = TabController(length: 5, vsync: this);
//     _tabController.addListener(_handleTabChange);
//   }
  
//   void _handleTabChange() {
//     if (_tabController.indexIsChanging) {
//       setState(() {
//         _selectedStatus = _tabToStatus[_tabController.index] ?? 'all';
//       });
//     }
//   }
  
//   @override
//   void dispose() {
//     _tabController.removeListener(_handleTabChange);
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Jobs'),
//         backgroundColor: const Color.fromARGB(255, 208, 63, 2),
//         elevation: 0,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white70,
//             tabs: const [
//               Tab(text: 'All Jobs'),
//               Tab(text: 'Pending'),
//               Tab(text: 'Parts Ordered'),
//               Tab(text: 'In Progress'),
//               Tab(text: 'Ready for Pickup'),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Streamlined search bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search jobs...',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.zero,
//               ),
//               onChanged: (query) => setState(() => _searchQuery = query),
//             ),
//           ),
          
//           // Job listings
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // All Jobs Tab
//                 _buildFilteredJobList('all'),
                
//                 // Pending Tab
//                 _buildFilteredJobList('pending'),
                
//                 // Parts Ordered Tab
//                 _buildFilteredJobList('parts ordered'),
                
//                 // In Progress Tab
//                 _buildFilteredJobList('in progress'),
                
//                 // Ready for Pickup Tab
//                 _buildFilteredJobList('ready for pickup'),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }
  
//   Widget _buildFilteredJobList(String status) {
//     final currentUserId = _auth.currentUser?.uid ?? '';
    
//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
        
//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }
        
//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';
        
//         // Query based on status
//         Query<Map<String, dynamic>> query = _firestore.collection('maintenance_requests');
        
//         // Filter by city first
//         query = query.where('city', isEqualTo: mechanicCity);
        
//         // Filter by status if not 'all'
//         if (status != 'all') {
//           query = query.where('status', isEqualTo: status);
//         }
        
//         return StreamBuilder<QuerySnapshot>(
//           stream: query.snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
            
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No ${status == "all" ? "" : status} jobs available');
//             }
            
//             // Apply search filter if needed
//             var filteredDocs = snapshot.data!.docs;
//             if (_searchQuery.isNotEmpty) {
//               filteredDocs = filteredDocs.where((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final searchLower = _searchQuery.toLowerCase();
//                 final car = (data['car'] ?? '').toString().toLowerCase();
//                 final problem = (data['problemDescription'] ?? '').toString().toLowerCase();
                
//                 return car.contains(searchLower) || problem.contains(searchLower);
//               }).toList();
//             }
            
//             if (filteredDocs.isEmpty) {
//               return _buildEmptyState('No matching jobs found');
//             }
            
//             return _buildJobCards(filteredDocs);
//           },
//         );
//       },
//     );
//   }
  
//   Widget _buildJobCards(List<QueryDocumentSnapshot> docs) {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       itemCount: docs.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: JobCardWidget(
//             request: docs[index],
//             onTap: () => showJobDetailsDialog(
//               context, docs[index], _auth, _firestore
//             ),
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//second change
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Jobs',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           SearchFilterWidget(
//             onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
//             onSearchChanged: (query) => setState(() => _searchQuery = query),
//             selectedFilter: _selectedFilter,
//           ),
//           Expanded(child: _buildJobsList()),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildJobsList() {
//     final currentUserId = _auth.currentUser?.uid ?? '';

//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ));
//         }

//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }

//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';

//         return StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('maintenance_requests').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator(
//                 color: JobConstants.primaryColor,
//               ));
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No maintenance requests available');
//             }

//             var filteredRequests = _filterRequests(snapshot.data!.docs, mechanicCity);

//             if (filteredRequests.isEmpty) {
//               final statusDisplay = _selectedFilter == 'All' 
//                   ? '' 
//                   : JobConstants.filterDisplayNames[_selectedFilter] ?? _selectedFilter;
//               return _buildEmptyState('No ${statusDisplay.toLowerCase()} requests available');
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               itemCount: filteredRequests.length,
//               itemBuilder: (context, index) => _buildJobCard(filteredRequests[index]),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildJobCard(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () => showJobDetailsDialog(context, doc, _auth, _firestore),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Status and date
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: statusColor.withAlpha(25),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       statusDisplay,
//                       style: TextStyle(
//                         color: statusColor,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   if (data['dateCreated'] is Timestamp)
//                     Text(
//                       _formatDate(data['dateCreated']),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                 ],
//               ),
              
//               const SizedBox(height: 12),
              
//               // Vehicle info
//               Text(
//                 car,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
              
//               const SizedBox(height: 8),
              
//               // Problem description
//               Text(
//                 problemDescription,
//                 style: const TextStyle(fontSize: 14),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
              
//               const SizedBox(height: 8),
              
//               // View details button
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => showJobDetailsDialog(context, doc, _auth, _firestore),
//                   style: TextButton.styleFrom(
//                     foregroundColor: JobConstants.primaryColor,
//                     minimumSize: Size.zero,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: const Text('View Details'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//     return requests.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final requestCity = (data['city'] ?? '').toLowerCase();
//       final status = data['status'] ?? 'pending';
      
//       // Filter by mechanic's city
//       if (requestCity != mechanicCity.toLowerCase()) {
//         return false;
//       }

//       // Filter by status if not 'All'
//       if (_selectedFilter != 'All' && status != _selectedFilter) {
//         return false;
//       }

//       // Apply search filter
//       if (_searchQuery.isNotEmpty) {
//         final searchLower = _searchQuery.toLowerCase();
//         final carInfo = (data['car'] ?? '').toString().toLowerCase();
//         final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();

//         return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
//       }

//       return true;
//     }).toList();
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.assignment_outlined, 
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
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () => setState(() {}),
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//3rd change

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Jobs',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           SearchFilterWidget(
//             onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
//             onSearchChanged: (query) => setState(() => _searchQuery = query),
//             selectedFilter: _selectedFilter,
//           ),
//           Expanded(child: _buildJobsList()),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildJobsList() {
//     final currentUserId = _auth.currentUser?.uid ?? '';

//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ));
//         }

//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }

//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';

//         return StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('maintenance_requests').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator(
//                 color: JobConstants.primaryColor,
//               ));
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No maintenance requests available');
//             }

//             var filteredRequests = _filterRequests(snapshot.data!.docs, mechanicCity);

//             if (filteredRequests.isEmpty) {
//               final statusDisplay = _selectedFilter == 'All' 
//                   ? '' 
//                   : JobConstants.filterDisplayNames[_selectedFilter] ?? _selectedFilter;
//               return _buildEmptyState('No ${statusDisplay.toLowerCase()} requests available');
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               itemCount: filteredRequests.length,
//               itemBuilder: (context, index) => JobCardWidget(
//                 request: filteredRequests[index],
//                 onTap: () => showJobDetailsDialog(
//                   context, filteredRequests[index], _auth, _firestore),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//     return requests.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final requestCity = (data['city'] ?? '').toLowerCase();
//       final status = data['status'] ?? 'pending';
      
//       // Filter by mechanic's city
//       if (requestCity != mechanicCity.toLowerCase()) {
//         return false;
//       }

//       // Filter by status if not 'All'
//       if (_selectedFilter != 'All' && status != _selectedFilter) {
//         return false;
//       }

//       // Apply search filter
//       if (_searchQuery.isNotEmpty) {
//         final searchLower = _searchQuery.toLowerCase();
//         final carInfo = (data['car'] ?? '').toString().toLowerCase();
//         final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();

//         return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
//       }

//       return true;
//     }).toList();
//   }

//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.assignment_outlined, 
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
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () => setState(() {}),
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// 4th change
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';
  
//   // For tracking offer status
//   Set<String> _yourOfferRequestIds = {}; // Jobs you've offered on
//   Set<String> _acceptedOfferRequestIds = {}; // Jobs where your offer was accepted
//   bool _offersLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadOfferData();
//   }

//   Future<void> _loadOfferData() async {
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     if (currentMechanicId.isEmpty) return;

//     try {
//       // 1. Get all offers by this mechanic
//       final offersSnapshot = await _firestore
//           .collection('offers')
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get();
          
//       // Track which requests you've offered on
//       final yourOfferRequestIds = offersSnapshot.docs
//           .map((doc) => doc.data()['requestId'] as String)
//           .toSet();
          
//       // Get IDs of your offers
//       final yourOfferIds = offersSnapshot.docs.map((doc) => doc.id).toSet();
      
//       // 2. Get requests with accepted offers
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .where('acceptedOfferId', whereIn: yourOfferIds.isEmpty ? [''] : yourOfferIds.toList())
//           .get();
      
//       // Create set of request IDs where your offer was accepted
//       final acceptedOfferRequestIds = requestsSnapshot.docs
//           .map((doc) => doc.id)
//           .toSet();
      
//       setState(() {
//         _yourOfferRequestIds = yourOfferRequestIds;
//         _acceptedOfferRequestIds = acceptedOfferRequestIds;
//         _offersLoaded = true;
//       });
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _offersLoaded = true; // Mark as loaded even on error
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Jobs',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           SearchFilterWidget(
//             onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
//             onSearchChanged: (query) => setState(() => _searchQuery = query),
//             selectedFilter: _selectedFilter,
//           ),
//           Expanded(child: _buildJobsList()),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildJobsList() {
//     final currentUserId = _auth.currentUser?.uid ?? '';

//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting || !_offersLoaded) {
//           return const Center(child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ));
//         }

//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }

//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';

//         return StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('maintenance_requests').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator(
//                 color: JobConstants.primaryColor,
//               ));
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No maintenance requests available');
//             }

//             var filteredRequests = _filterRequests(snapshot.data!.docs, mechanicCity);

//             if (filteredRequests.isEmpty) {
//               final statusDisplay = _selectedFilter == 'All' 
//                   ? '' 
//                   : JobConstants.filterDisplayNames[_selectedFilter] ?? _selectedFilter;
//               return _buildEmptyState('No ${statusDisplay.toLowerCase()} requests available');
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               itemCount: filteredRequests.length,
//               itemBuilder: (context, index) {
//                 final request = filteredRequests[index];
//                 return JobCardWidget(
//                   request: request,
//                   hasSentOffer: _yourOfferRequestIds.contains(request.id),
//                   isOfferAccepted: _acceptedOfferRequestIds.contains(request.id),
//                   onTap: () => showJobDetailsDialog(
//                     context, request, _auth, _firestore),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   // List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//   //   return requests.where((doc) {
//   //     final data = doc.data() as Map<String, dynamic>;
//   //     final requestCity = (data['city'] ?? '').toLowerCase();
//   //     final status = data['status'] ?? 'pending';
      
//   //     // Filter by mechanic's city
//   //     if (requestCity != mechanicCity.toLowerCase()) {
//   //       return false;
//   //     }

//   //     // Filter by status if not 'All'
//   //     if (_selectedFilter != 'All' && status != _selectedFilter) {
//   //       return false;
//   //     }

//   //     // Apply search filter
//   //     if (_searchQuery.isNotEmpty) {
//   //       final searchLower = _searchQuery.toLowerCase();
//   //       final carInfo = (data['car'] ?? '').toString().toLowerCase();
//   //       final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();

//   //       return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
//   //     }

//   //     return true;
//   //   }).toList();
//   // }
//   List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//   final currentUserId = _auth.currentUser?.uid ?? '';
  
//   return requests.where((doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final requestCity = (data['city'] ?? '').toLowerCase();
//     final status = data['status'] ?? 'pending';
//     final acceptedOfferId = data['acceptedOfferId'];
    
//     // First, filter by mechanic's city
//     if (requestCity != mechanicCity.toLowerCase()) {
//       return false;
//     }
    
//     // Don't show jobs that have been accepted by other mechanics
//     if (acceptedOfferId != null) {
//       // Check if we need to verify this is our offer
//       // You'll need to add this check to see if the accepted offer is yours
//       final isYourOfferAccepted = _acceptedOfferRequestIds.contains(doc.id);
      
//       // Only show job if it's your accepted offer
//       if (!isYourOfferAccepted) {
//         return false;
//       }
//     }
    
//     // Filter by status if not 'All'
//     if (_selectedFilter != 'All' && status != _selectedFilter) {
//       return false;
//     }
    
//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       final searchLower = _searchQuery.toLowerCase();
//       final carInfo = (data['car'] ?? '').toString().toLowerCase();
//       final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();
      
//       return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
//     }
    
//     return true;
//   }).toList();
// }
//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.assignment_outlined, 
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
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               _loadOfferData(); // Refresh offer data too
//               setState(() {});
//             },
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// 5th change but goooood

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:automate/bars/app_bar.dart';
// import '../bars/mechanic_navbar.dart';
// import './widgets/job_card.dart';
// import './widgets/search_filter.dart';
// import './dialogs/jop_details_dialogs.dart';
// import 'utils/constants.dart';

// class MechanicJobsScreen extends StatefulWidget {
//   const MechanicJobsScreen({super.key});

//   @override
//   State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
// }

// class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _currentIndex = 0;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';
  
//   // For tracking offer status
//   Set<String> _yourOfferRequestIds = {}; // Jobs you've offered on
//   Set<String> _acceptedOfferRequestIds = {}; // Jobs where your offer was accepted
//   Map<String, DocumentSnapshot> _existingOffers = {}; // Store offer documents for editing
//   bool _offersLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadOfferData();
//   }

//   Future<void> _loadOfferData() async {
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     if (currentMechanicId.isEmpty) return;

//     try {
//       Set<String> yourOfferRequestIds = {};
//       Set<String> acceptedOfferRequestIds = {};
//       Map<String, DocumentSnapshot> existingOffers = {};
      
//       // Get all maintenance requests
//       final requestsSnapshot = await _firestore
//           .collection('maintenance_requests')
//           .get();
          
//       // For each request, check if you have an offer in its subcollection
//       for (var requestDoc in requestsSnapshot.docs) {
//         final requestId = requestDoc.id;
//         final requestData = requestDoc.data();
        
//         // Check if this mechanic has been assigned to this request
//         if (requestData.containsKey('acceptedMechanicId') && 
//             requestData['acceptedMechanicId'] == currentMechanicId) {
//           acceptedOfferRequestIds.add(requestId);
//           yourOfferRequestIds.add(requestId); // If it's accepted, you must have sent an offer
          
//           // Get the accepted offer if available
//           if (requestData.containsKey('acceptedOfferId')) {
//             String offerId = requestData['acceptedOfferId'];
//             try {
//               DocumentSnapshot offerDoc = await _firestore
//                   .collection('maintenance_requests')
//                   .doc(requestId)
//                   .collection('offers')
//                   .doc(offerId)
//                   .get();
                  
//               if (offerDoc.exists) {
//                 existingOffers[requestId] = offerDoc;
//               }
//             } catch (e) {
//               print('Error fetching accepted offer: $e');
//             }
//           }
          
//           continue; // Skip checking subcollection since we already know it's your offer
//         }
        
//         // If not accepted yet, check subcollection for your offers
//         try {
//           final offersQuery = await _firestore
//               .collection('maintenance_requests')
//               .doc(requestId)
//               .collection('offers')
//               .where('mechanicId', isEqualTo: currentMechanicId)
//               .get();
              
//           if (offersQuery.docs.isNotEmpty) {
//             yourOfferRequestIds.add(requestId);
//             existingOffers[requestId] = offersQuery.docs.first;
//           }
//         } catch (e) {
//           print('Error checking offers for request $requestId: $e');
//         }
//       }
      
//       setState(() {
//         _yourOfferRequestIds = yourOfferRequestIds;
//         _acceptedOfferRequestIds = acceptedOfferRequestIds;
//         _existingOffers = existingOffers;
//         _offersLoaded = true;
//       });
      
//       print('Found ${yourOfferRequestIds.length} requests with your offers');
//       print('Found ${acceptedOfferRequestIds.length} requests with accepted offers');
      
//     } catch (e) {
//       print('Error loading offer data: $e');
//       setState(() {
//         _offersLoaded = true; // Mark as loaded even on error
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: const AppBarWidget(
//         pageName: 'Jobs',
//         color: JobConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           SearchFilterWidget(
//             onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
//             onSearchChanged: (query) => setState(() => _searchQuery = query),
//             selectedFilter: _selectedFilter,
//           ),
//           Expanded(child: _buildJobsList()),
//         ],
//       ),
//       bottomNavigationBar: MechanicBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//     );
//   }

//   Widget _buildJobsList() {
//     final currentUserId = _auth.currentUser?.uid ?? '';

//     return FutureBuilder<DocumentSnapshot>(
//       future: _firestore.collection('Mechanic').doc(currentUserId).get(),
//       builder: (context, mechanicSnapshot) {
//         if (mechanicSnapshot.connectionState == ConnectionState.waiting || !_offersLoaded) {
//           return const Center(child: CircularProgressIndicator(
//             color: JobConstants.primaryColor,
//           ));
//         }

//         if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
//           return _buildEmptyState('Mechanic profile not found');
//         }

//         final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
//         final mechanicCity = mechanicData['location'] ?? '';

//         return StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('maintenance_requests').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator(
//                 color: JobConstants.primaryColor,
//               ));
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return _buildEmptyState('No maintenance requests available');
//             }

//             var filteredRequests = _filterRequests(snapshot.data!.docs, mechanicCity);

//             if (filteredRequests.isEmpty) {
//               final statusDisplay = _selectedFilter == 'All' 
//                   ? '' 
//                   : JobConstants.filterDisplayNames[_selectedFilter] ?? _selectedFilter;
//               return _buildEmptyState('No ${statusDisplay.toLowerCase()} requests available');
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               itemCount: filteredRequests.length,
//               itemBuilder: (context, index) {
//                 final request = filteredRequests[index];
//                 final existingOffer = _existingOffers[request.id];
                
//                 return JobCardWidget(
//                   request: request,
//                   hasSentOffer: _yourOfferRequestIds.contains(request.id),
//                   isOfferAccepted: _acceptedOfferRequestIds.contains(request.id),
//                   onTap: () => showJobDetailsDialog(
//                     context, 
//                     request, 
//                     _auth, 
//                     _firestore,
//                     existingOffer: existingOffer, // Pass existing offer if available
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
//     final currentUserId = _auth.currentUser?.uid ?? '';
    
//     return requests.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final requestCity = (data['city'] ?? '').toLowerCase();
//       final status = data['status'] ?? 'pending';
//       final acceptedOfferId = data['acceptedOfferId'];
      
//       // First, filter by mechanic's city
//       if (requestCity != mechanicCity.toLowerCase()) {
//         return false;
//       }
      
//       // Don't show jobs that have been accepted by other mechanics
//       if (acceptedOfferId != null) {
//         // Check if we need to verify this is our offer
//         final isYourOfferAccepted = _acceptedOfferRequestIds.contains(doc.id);
        
//         // Only show job if it's your accepted offer
//         if (!isYourOfferAccepted) {
//           return false;
//         }
//       }
      
//       // Filter by status if not 'All'
//       if (_selectedFilter != 'All' && status != _selectedFilter) {
//         return false;
//       }
      
//       // Apply search filter
//       if (_searchQuery.isNotEmpty) {
//         final searchLower = _searchQuery.toLowerCase();
//         final carInfo = (data['car'] ?? '').toString().toLowerCase();
//         final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();
        
//         return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
//       }
      
//       return true;
//     }).toList();
//   }

//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.assignment_outlined, 
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
//           const SizedBox(height: 24),
//           OutlinedButton.icon(
//             onPressed: () {
//               _loadOfferData(); // Refresh offer data
//               setState(() {});
//             },
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: JobConstants.primaryColor,
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
import './widgets/search_filter.dart';
import './dialogs/jop_details_dialogs.dart';
import 'utils/constants.dart';

class MechanicJobsScreen extends StatefulWidget {
  const MechanicJobsScreen({super.key});

  @override
  State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
}

class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  
  // For tracking offer status
  Set<String> _yourOfferRequestIds = {}; // Jobs you've offered on
  Map<String, DocumentSnapshot> _existingOffers = {}; // Store offer documents for editing
  bool _offersLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  Future<void> _loadOfferData() async {
    final String currentMechanicId = _auth.currentUser?.uid ?? '';
    if (currentMechanicId.isEmpty) return;

    try {
      Set<String> yourOfferRequestIds = {};
      Map<String, DocumentSnapshot> existingOffers = {};
      
      // Get all maintenance requests
      final requestsSnapshot = await _firestore
          .collection('maintenance_requests')
          .get();
          
      // For each request, check if you have an offer in its subcollection
      for (var requestDoc in requestsSnapshot.docs) {
        final requestId = requestDoc.id;
        final requestData = requestDoc.data();
        
        // Skip if this request already has an accepted offer (from anyone)
        if (requestData.containsKey('acceptedMechanicId') || 
            requestData.containsKey('acceptedOfferId')) {
          continue;
        }
        
        // Check subcollection for your offers (if no accepted offers)
        try {
          final offersQuery = await _firestore
              .collection('maintenance_requests')
              .doc(requestId)
              .collection('offers')
              .where('mechanicId', isEqualTo: currentMechanicId)
              .get();
              
          if (offersQuery.docs.isNotEmpty) {
            yourOfferRequestIds.add(requestId);
            existingOffers[requestId] = offersQuery.docs.first;
          }
        } catch (e) {
          print('Error checking offers for request $requestId: $e');
        }
      }
      
      setState(() {
        _yourOfferRequestIds = yourOfferRequestIds;
        _existingOffers = existingOffers;
        _offersLoaded = true;
      });
      
      print('Found ${yourOfferRequestIds.length} requests with your offers (not yet accepted)');
      
    } catch (e) {
      print('Error loading offer data: $e');
      setState(() {
        _offersLoaded = true; // Mark as loaded even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(
        pageName: 'Jobs',
        color: JobConstants.primaryColor,
      ),
      body: Column(
        children: [
          SearchFilterWidget(
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            selectedFilter: _selectedFilter,
          ),
          Expanded(child: _buildJobsList()),
        ],
      ),
      bottomNavigationBar: MechanicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildJobsList() {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('Mechanic').doc(currentUserId).get(),
      builder: (context, mechanicSnapshot) {
        if (mechanicSnapshot.connectionState == ConnectionState.waiting || !_offersLoaded) {
          return const Center(child: CircularProgressIndicator(
            color: JobConstants.primaryColor,
          ));
        }

        if (!mechanicSnapshot.hasData || !mechanicSnapshot.data!.exists) {
          return _buildEmptyState('Mechanic profile not found');
        }

        final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
        final mechanicCity = mechanicData['location'] ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('maintenance_requests').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(
                color: JobConstants.primaryColor,
              ));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState('No maintenance requests available');
            }

            var filteredRequests = _filterRequests(snapshot.data!.docs, mechanicCity);

            if (filteredRequests.isEmpty) {
              final statusDisplay = _selectedFilter == 'All' 
                  ? '' 
                  : JobConstants.filterDisplayNames[_selectedFilter] ?? _selectedFilter;
              return _buildEmptyState('No ${statusDisplay.toLowerCase()} requests available');
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                final existingOffer = _existingOffers[request.id];
                
                return JobCardWidget(
                  request: request,
                  hasSentOffer: _yourOfferRequestIds.contains(request.id),
                  isOfferAccepted: false, // Always false in this screen
                  onTap: () => showJobDetailsDialog(
                    context, 
                    request, 
                    _auth, 
                    _firestore,
                    existingOffer: existingOffer, // Pass existing offer if available
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests, String mechanicCity) {
    return requests.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final requestCity = (data['city'] ?? '').toLowerCase();
      final status = data['status'] ?? 'pending';
      
      // First, filter by mechanic's city
      if (requestCity != mechanicCity.toLowerCase()) {
        return false;
      }
      
      // Don't show requests that have any accepted offers (from anyone)
      if (data.containsKey('acceptedMechanicId') || data.containsKey('acceptedOfferId')) {
        return false;
      }
      
      // Filter by status if not 'All'
      if (_selectedFilter != 'All' && status != _selectedFilter) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final carInfo = (data['car'] ?? '').toString().toLowerCase();
        final problemInfo = (data['problemDescription'] ?? '').toString().toLowerCase();
        
        return carInfo.contains(searchLower) || problemInfo.contains(searchLower);
      }
      
      return true;
    }).toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined, 
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
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _loadOfferData(); // Refresh offer data
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: JobConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}