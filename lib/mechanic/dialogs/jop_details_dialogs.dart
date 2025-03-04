import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/helpers.dart';

void showJobDetailsDialog(
  BuildContext context,
  DocumentSnapshot request,
  FirebaseAuth auth,
  FirebaseFirestore firestore,
) {
  Map<String, dynamic> data = request.data() as Map<String, dynamic>;
  String currentStatus = data['status'] ?? 'Pending';
  String currentUserId = auth.currentUser?.uid ?? '';
  String currentUserEmail = auth.currentUser?.email ?? '';

  // Try to get a name to use
  String mechanicName = UserHelper.getMechanicName(auth);

  // Controllers for offer inputs
  final offerPriceController = TextEditingController();
  final offerDescriptionController = TextEditingController();
  final estimatedTimeController = TextEditingController();
  final repairsNeededController = TextEditingController();

  // For the service type radio buttons
  String serviceType = 'Parts with Labor';

  // Flag for editing
  bool isEditingExistingOffer = false;
  String existingOfferId = '';

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

          // Check if an existing offer was found
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var existingOffer = snapshot.data!.docs.first;
            var offerData = existingOffer.data() as Map<String, dynamic>;

            // Set flag and existing offer ID
            isEditingExistingOffer = true;
            existingOfferId = existingOffer.id;

            // Pre-fill the form with existing data
            offerPriceController.text = offerData['price'].toString();
            offerDescriptionController.text = offerData['description'] ?? '';
            estimatedTimeController.text = offerData['estimatedTime'] ?? '';
            repairsNeededController.text = offerData['repairsNeeded'] ?? '';
            serviceType = offerData['serviceType'] ?? 'Parts with Labor';
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Request Details: ${request.id.substring(0, 8)}...'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailItem('Car', data['car'] ?? 'N/A'),
                    _buildDetailItem('Problem', data['problemDescription'] ?? 'Not specified'),
                    _buildDetailItem('Location', data['city'] ?? 'Not specified'),
                    _buildDetailItem(
                      'Date',
                      data['timestamp'] != null
                          ? DateFormatter.formatTimestamp(data['timestamp'])
                          : 'Not available'
                    ),
                    _buildDetailItem('Current Status', currentStatus),

                    const SizedBox(height: 16),
                    const Divider(thickness: 1),
                    const SizedBox(height: 16),

                    // Make/Edit an offer section
                    Text(
                      isEditingExistingOffer ? 'Edit Your Offer' : 'Make an Offer',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service Type Radio Buttons
                    const Text(
                      'Service Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    _buildServiceTypeRadios(serviceType, (value) {
                      setState(() => serviceType = value);
                    }),
                    const SizedBox(height: 16),

                    // Form fields
                    _buildOfferFields(
                      offerPriceController, 
                      estimatedTimeController, 
                      repairsNeededController, 
                      offerDescriptionController
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JobConstants.primaryColor,
                  ),
                  onPressed: () => _handleOfferSubmission(
                    context,
                    firestore,
                    request.id,
                    isEditingExistingOffer,
                    existingOfferId,
                    offerPriceController,
                    offerDescriptionController,
                    estimatedTimeController,
                    repairsNeededController,
                    serviceType,
                    currentUserId,
                    currentUserEmail,
                    mechanicName
                  ),
                  child: Text(
                    isEditingExistingOffer ? 'Update Offer' : 'Submit Offer',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
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

Widget _buildServiceTypeRadios(String serviceType, Function(String) onChanged) {
  return Column(
    children: [
      RadioListTile<String>(
        title: const Text('Parts with Labor'),
        value: 'Parts with Labor',
        groupValue: serviceType,
        activeColor: JobConstants.primaryColor,
        onChanged: (value) => onChanged(value!),
      ),
      RadioListTile<String>(
        title: const Text('Labor Only'),
        value: 'Labor Only',
        groupValue: serviceType,
        activeColor: JobConstants.primaryColor,
        onChanged: (value) => onChanged(value!),
      ),
    ],
  );
}

Widget _buildOfferFields(
  TextEditingController priceController,
  TextEditingController timeController,
  TextEditingController repairsController,
  TextEditingController detailsController
) {
  return Column(
    children: [
      TextField(
        controller: priceController,
        decoration: const InputDecoration(
          labelText: 'Estimated Cost (SAR)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.attach_money),
        ),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: timeController,
        decoration: const InputDecoration(
          labelText: 'Estimated Time to Finish',
          hintText: 'e.g., "2 hours", "3 days"',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: repairsController,
        decoration: const InputDecoration(
          labelText: 'Repairs Needed',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.build),
          hintText: 'List the repairs needed',
        ),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: detailsController,
        decoration: const InputDecoration(
          labelText: 'Additional Details',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.description),
          hintText: 'Any other details about your offer',
        ),
        maxLines: 3,
      ),
    ],
  );
}

Future<void> _handleOfferSubmission(
  BuildContext context,
  FirebaseFirestore firestore,
  String requestId,
  bool isEditingExistingOffer,
  String existingOfferId,
  TextEditingController priceController,
  TextEditingController descriptionController,
  TextEditingController timeController,
  TextEditingController repairsController,
  String serviceType,
  String currentUserId,
  String currentUserEmail,
  String mechanicName
) async {
  // Validate inputs
  if (priceController.text.isEmpty) {
    DialogHelper.showErrorSnackBar(context, 'Please enter an estimated cost');
    return;
  }

  if (timeController.text.isEmpty) {
    DialogHelper.showErrorSnackBar(context, 'Please enter an estimated time');
    return;
  }

  if (repairsController.text.isEmpty) {
    DialogHelper.showErrorSnackBar(context, 'Please enter repairs needed');
    return;
  }

  // Prepare offer data
  Map<String, dynamic> offerData = {
    'price': double.tryParse(priceController.text) ?? 0,
    'description': descriptionController.text,
    'estimatedTime': timeController.text,
    'repairsNeeded': repairsController.text,
    'serviceType': serviceType,
    'lastUpdated': FieldValue.serverTimestamp(),
  };

  Future<void> operation;
  String successMessage;

  if (isEditingExistingOffer) {
    // Reset status to Pending when offer is updated
    offerData['status'] = 'Pending';

    // Make sure mechanic info is included in the update
    offerData['mechanicName'] = mechanicName;
    offerData['mechanicEmail'] = currentUserEmail;

    // Update existing offer
    operation = firestore
        .collection('offers')
        .doc(existingOfferId)
        .update(offerData);
    successMessage = 'Offer updated successfully';
  } else {
    // Create new offer with mechanic info embedded
    offerData.addAll({
      'requestId': requestId,
      'mechanicId': currentUserId,
      'mechanicEmail': currentUserEmail,
      'mechanicName': mechanicName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
    });
    operation = firestore.collection('offers').add(offerData);
    successMessage = 'Offer submitted successfully';
  }

  try {
    await operation;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      Navigator.pop(context);
    }
  } catch (error) {
    if (context.mounted) {
      DialogHelper.showErrorSnackBar(context, 'Failed to submit offer: $error');
    }
  }
}