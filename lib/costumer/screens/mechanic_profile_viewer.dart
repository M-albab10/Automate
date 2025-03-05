import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:automate/bars/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/profile_header.dart';
import 'widgets/rating_card.dart';
import 'widgets/profile_info.dart';
import 'widgets/chat_button.dart';
import 'widgets/rating_section.dart';
import '../models/mechanic_data.dart';

class MechanicProfileViewer extends StatefulWidget {
  final String mechanicId;
  final String mechanicName;

  const MechanicProfileViewer({
    Key? key,
    required this.mechanicId,
    required this.mechanicName,
  }) : super(key: key);

  @override
  State<MechanicProfileViewer> createState() => _MechanicProfileViewerState();
}

class _MechanicProfileViewerState extends State<MechanicProfileViewer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? mechanicData;
  bool isLoading = true;
  double _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  double _overallRating = 0.0;
  int _ratingsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMechanicData();
    _loadRatingsData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadMechanicData() async {
    try {
      // Try to fetch from Mechanic collection first
      DocumentSnapshot mechanicDoc =
          await _firestore.collection('Mechanic').doc(widget.mechanicId).get();

      if (mechanicDoc.exists) {
        setState(() {
          mechanicData = mechanicDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
        return;
      }

      // If not found, try the users collection
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.mechanicId).get();

      if (userDoc.exists) {
        setState(() {
          mechanicData = userDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
        return;
      }

      // If still not found, create a basic profile from available info
      setState(() {
        mechanicData = {
          'fullName': widget.mechanicName,
          'email': 'Not available'
        };
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mechanic profile: $e')),
        );
        setState(() {
          isLoading = false;
          mechanicData = {
            'fullName': widget.mechanicName,
            'email': 'Not available'
          };
        });
      }
    }
  }

  Future<void> _loadRatingsData() async {
    try {
      // Query the ratings subcollection to calculate average rating
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('Mechanic')
          .doc(widget.mechanicId)
          .collection('ratings')
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        setState(() {
          _overallRating = 0.0;
          _ratingsCount = 0;
        });
        return;
      }

      double sum = 0;
      for (var doc in ratingsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        sum += (data['rating'] ?? 0).toDouble();
      }

      setState(() {
        _ratingsCount = ratingsSnapshot.docs.length;
        _overallRating = sum / _ratingsCount;
      });
    } catch (e) {
      print('Error calculating ratings: $e');
    }
  }

  // Removed _navigateToChat method as it's now handled in ChatButton widget

  Future<void> _submitRating() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    try {
      // Get current user ID
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to rate')),
        );
        return;
      }

      String userId = currentUser.uid;
      String userEmail = currentUser.email ?? 'Anonymous';

      // Add rating to the mechanic's subcollection
      await _firestore
          .collection('Mechanic')
          .doc(widget.mechanicId)
          .collection('ratings')
          .add({
        'userId': userId,
        'userEmail': userEmail,
        'rating': _userRating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reset the form
      setState(() {
        _userRating = 0;
        _reviewController.clear();
      });

      // Refresh ratings data
      _loadRatingsData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your rating!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  String _getBestNameOption(Map<String, dynamic>? data) {
    if (data == null) return widget.mechanicName;

    return data['fullName'] ??
        data['displayName'] ??
        data['name'] ??
        data['userName'] ??
        widget.mechanicName;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: AppBarWidget(
          pageName: 'Mechanic Profile',
          implyLeading: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final MechanicData mechanic = MechanicData.fromMap(
      mechanicData ?? {},
      defaultName: widget.mechanicName,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(
        pageName: 'Mechanic Profile',
        implyLeading: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ProfileHeader(name: mechanic.name, rating: _overallRating),
              const SizedBox(height: 16),
              RatingCard(rating: _overallRating, count: _ratingsCount),
              const SizedBox(height: 16),
              ProfileInfo(mechanic: mechanic),
              const SizedBox(height: 20),
              ChatButton(
                mechanicName: mechanic.name,
                mechanicId: widget.mechanicId,
              ),
              const SizedBox(height: 20),
              RatingSection(
                mechanicId: widget.mechanicId,
                userRating: _userRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _userRating = rating;
                  });
                },
                reviewController: _reviewController,
                submitRating: _submitRating,
                firestore: _firestore,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
