import 'package:automate/mechanic/mechanic_offer_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

void showJobDetailsDialog(
  BuildContext context,
  DocumentSnapshot request,
  FirebaseAuth auth,
  FirebaseFirestore firestore,
) {
  Map<String, dynamic> data = request.data() as Map<String, dynamic>;
  String currentStatus = data['status'] ?? 'Pending';
  String currentUserId = auth.currentUser?.uid ?? '';

  // Check if the mechanic already has an offer for this request
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<QuerySnapshot>(
        future: firestore
            .collection('offers')
            .where('requestId', isEqualTo: request.id)
            .where('mechanicId', isEqualTo: currentUserId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          bool isEditingExistingOffer = false;
          String existingOfferId = '';
          Map<String, dynamic>? offerData;

          // Check if an existing offer was found
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var existingOffer = snapshot.data!.docs.first;
            // Set flag and existing offer ID
            existingOfferId = existingOffer.id;
            offerData = existingOffer.data() as Map<String, dynamic>;
            isEditingExistingOffer = true;
          }

          return AlertDialog(
            title: Text('Request Details: ${request.id.substring(0, 8)}...'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('Car', data['car'] ?? 'N/A'),
                  _buildDetailItem(
                      'Problem', data['problemDescription'] ?? 'Not specified'),
                  _buildDetailItem('Location', data['city'] ?? 'Not specified'),
                  _buildDetailItem(
                      'Date',
                      data['timestamp'] != null
                          ? DateFormatter.formatTimestamp(data['timestamp'])
                          : 'Not available'),
                  _buildDetailItem('Current Status', currentStatus),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitOfferScreen(
                          requestId: request.id,
                          mechanicId: currentUserId,
                          isEditingExistingOffer: isEditingExistingOffer,
                          existingOfferId: existingOfferId,
                          existingOfferData:
                              isEditingExistingOffer ? offerData : null,
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditingExistingOffer
                        ? Colors.blue
                        : JobConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(
                    isEditingExistingOffer ? Icons.edit : Icons.handshake,
                    color: Colors.white,
                  ),
                  label: Text(
                    isEditingExistingOffer
                        ? 'Edit Your Offer'
                        : 'Make an Offer!',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(),
      ],
    ),
  );
}
