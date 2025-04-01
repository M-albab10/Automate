import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OffersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Loads all offers for a specific request from subcollection
  void loadOffers(String requestId) async {
    try {
      QuerySnapshot offersSnapshot = await _firestore
          .collection('maintenance_requests')
          .doc(requestId)
          .collection('offers')
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

  // Gets a stream of offers for a specific request from subcollection
  Stream<QuerySnapshot> getOffersStream(String requestId) {
    return _firestore
        .collection('maintenance_requests')
        .doc(requestId)
        .collection('offers')
        .snapshots();
  }

  //Accepts an offer and rejects all other offers for the same request using subcollection
  Future<void> acceptOffer(
    BuildContext context, String offerId, String requestId) async {
  bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accept Offer'),
          content: const Text(
              'Are you sure you want to accept this offer? Other offers will be removed.'),
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

    // Get all offers for this request from subcollection
    QuerySnapshot offersSnapshot = await _firestore
        .collection('maintenance_requests')
        .doc(requestId)
        .collection('offers')
        .get();

    // Get the accepted offer to save its data
    DocumentSnapshot? acceptedOfferDoc;
    for (var doc in offersSnapshot.docs) {
      if (doc.id == offerId) {
        acceptedOfferDoc = doc;
      }
    }

    if (acceptedOfferDoc == null) {
      throw Exception('Selected offer not found');
    }

    // Update the status of accepted offer
    final acceptedOfferRef = _firestore
        .collection('maintenance_requests')
        .doc(requestId)
        .collection('offers')
        .doc(offerId);
    
    // Add acceptedAt timestamp to the offer
    final offerData = acceptedOfferDoc.data() as Map<String, dynamic>;
    batch.update(acceptedOfferRef, {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // Delete all other offers
    for (var doc in offersSnapshot.docs) {
      if (doc.id != offerId) {
        // Delete this offer
        batch.delete(doc.reference);
      }
    }

    // Update the maintenance request with accepted offer details
    DocumentReference requestRef =
        _firestore.collection('maintenance_requests').doc(requestId);
    
    batch.update(requestRef, {
      'status': 'in progress',
      'acceptedOfferId': offerId,
      'acceptedPrice': offerData['price'],
      'acceptedMechanicId': offerData['mechanicId'],
      'acceptedMechanicName': offerData['mechanicName'],
      'acceptedAt': FieldValue.serverTimestamp(),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offer accepted successfully'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back to the maintenance screen
    Navigator.pop(context);
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  /// Rejects a specific offer using subcollection
  Future<void> rejectOffer(BuildContext context, String offerId, String requestId) async {
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
          .collection('maintenance_requests')
          .doc(requestId)
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