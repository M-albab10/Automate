import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/mechanic_navbar.dart';
import './widgets/job_card.dart';
import './widgets/search_filter.dart';
import './dialogs/jop_details_dialogs.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(
        pageName: 'Jobs',
        color: Color.fromARGB(255, 208, 63, 2),
      ),
      body: Column(
        children: [
          SearchFilterWidget(
            onFilterChanged: (filter) =>
                setState(() => _selectedFilter = filter),
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

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('maintenance_requests').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No maintenance requests available');
        }

        // First filter the requests
        var initialFiltered = _filterRequests(snapshot.data!.docs);

        // For in-progress requests, we need to check if this mechanic made an offer
        return FutureBuilder<List<DocumentSnapshot>>(
            future: _filterInProgressRequests(initialFiltered),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredRequests = asyncSnapshot.data ?? [];

              if (filteredRequests.isEmpty) {
                return _buildEmptyState('No requests match your filters');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) => JobCardWidget(
                  request: filteredRequests[index],
                  onTap: () => showJobDetailsDialog(
                      context, filteredRequests[index], _auth, _firestore),
                ),
              );
            });
      },
    );
  }

  Future<List<DocumentSnapshot>> _filterInProgressRequests(
      List<DocumentSnapshot> requests) async {
    final currentUserId = _auth.currentUser?.uid ?? '';
    List<DocumentSnapshot> result = [];

    for (var doc in requests) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'Pending';

      // If the request is in progress, check if this mechanic made an offer
      if (status == 'In Progress') {
        // Query to check if this mechanic has an offer for this request
        final offerQuery = await _firestore
            .collection('offers')
            .where('requestId', isEqualTo: doc.id)
            .where('mechanicId', isEqualTo: currentUserId)
            .get();

        // Only include if the mechanic has made an offer
        if (offerQuery.docs.isNotEmpty) {
          result.add(doc);
        }
      } else {
        // For all other statuses, include the request
        result.add(doc);
      }
    }

    return result;
  }

  List<DocumentSnapshot> _filterRequests(List<DocumentSnapshot> requests) {
    return requests.where((doc) {
      // Filter by status if not 'All'
      if (_selectedFilter != 'All' && doc['status'] != _selectedFilter) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        var searchLower = _searchQuery.toLowerCase();
        String carInfo = (doc['car'] ?? '').toLowerCase();
        String cityInfo = (doc['city'] ?? '').toLowerCase();
        String problemInfo = (doc['problemDescription'] ?? '').toLowerCase();

        return carInfo.contains(searchLower) ||
            cityInfo.contains(searchLower) ||
            problemInfo.contains(searchLower);
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
