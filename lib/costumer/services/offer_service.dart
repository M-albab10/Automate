import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/offer.dart';

class OffersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Loads all offers for a specific request
  void loadOffers(String requestId) async {
    try {
      QuerySnapshot offersSnapshot = await _firestore
          .collection('offers')
          .where('requestId', isEqualTo: requestId)
          .get();

      if (offersSnapshot.docs.isEmpty) {
        print('No offers found for request $requestId');
        return;
      }

      print('Found ${offersSnapshot.docs.length} offers for this request');

      for (var offer in offersSnapshot.docs) {
        Map<String, dynamic> offerData = offer.data() as Map<String, dynamic>;
        String mechanicId = offerData['mechanicId'] ?? '';

        if (mechanicId.isNotEmpty) {
          _loadMechanicInfo(mechanicId);
        }
      }
    } catch (e) {
      print('Error loading offers: $e');
    }
  }

  /// Loads and logs mechanic information for debugging
  Future<void> _loadMechanicInfo(String mechanicId) async {
    print('Loading mechanic with ID: $mechanicId');

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(mechanicId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print('User document fields: ${userData.keys.toList()}');

        String bestName = userData['fullName'] ??
            userData['displayName'] ??
            userData['name'] ??
            userData['userName'] ??
            userData['email'] ??
            'Unknown';

        print('Best name to use for mechanic: $bestName');
        // Don't return anything since the method is Future<void>
      } else {
        print('No user document found for mechanic ID: $mechanicId');
      }
    } catch (e) {
      print('Error fetching mechanic data: $e');
    }
  }

  /// Gets a stream of offers for a specific request
  Stream<QuerySnapshot> getOffersStream(String requestId) {
    return _firestore
        .collection('offers')
        .where('requestId', isEqualTo: requestId)
        .snapshots();
  }

  /// Accepts an offer and rejects all other offers for the same request
  Future<void> acceptOffer(
      BuildContext context, String offerId, String requestId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Accept Offer'),
            content: const Text(
                'Are you sure you want to accept this offer? Other offers will be automatically rejected.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 208, 63, 2),
                ),
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Accept', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      WriteBatch batch = _firestore.batch();

      // Get all offers for this request
      QuerySnapshot offersSnapshot = await _firestore
          .collection('offers')
          .where('requestId', isEqualTo: requestId)
          .get();

      // Update status of all offers
      for (var doc in offersSnapshot.docs) {
        if (doc.id == offerId) {
          batch.update(doc.reference, {'status': 'Accepted'});
        } else {
          batch.update(doc.reference, {'status': 'Rejected'});
        }
      }

      // Update the maintenance request status
      DocumentReference requestRef =
          _firestore.collection('maintenance_requests').doc(requestId);
      batch.update(requestRef, {
        'status': 'In Progress',
        'acceptedOfferId': offerId,
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer accepted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Rejects a specific offer
  Future<void> rejectOffer(BuildContext context, String offerId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reject Offer'),
            content: const Text('Are you sure you want to reject this offer?'),
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
                    const Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await _firestore
          .collection('offers')
          .doc(offerId)
          .update({'status': 'Rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Fetches mechanic name from Firestore
  Future<String> getMechanicName(
      String mechanicId, String mechanicEmail) async {
    if (mechanicId.isEmpty) {
      return mechanicEmail.isNotEmpty
          ? mechanicEmail.split('@')[0]
          : 'Unknown Mechanic';
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(mechanicId).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        return userData['displayName'] ??
            userData['fullName'] ??
            userData['name'] ??
            userData['email'] ??
            'Mechanic ${mechanicId.substring(0, 4)}';
      } else {
        return mechanicEmail.isNotEmpty
            ? mechanicEmail.split('@')[0]
            : 'Mechanic ${mechanicId.substring(0, 4)}';
      }
    } catch (e) {
      print('Error fetching mechanic name: $e');
      return mechanicEmail.isNotEmpty
          ? mechanicEmail.split('@')[0]
          : 'Unknown Mechanic';
    }
  }
}
