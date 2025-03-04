import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class JobCardWidget extends StatelessWidget {
  final DocumentSnapshot request;
  final VoidCallback onTap;
  
  const JobCardWidget({
    Key? key,
    required this.request,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = request.data() as Map<String, dynamic>;
    String status = data['status'] ?? 'Pending';
    Color statusColor = JobConstants.statusColors[status] ?? Colors.grey;
    
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('offers')
          .where('requestId', isEqualTo: request.id)
          .where('mechanicId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, offerSnapshot) {
        bool hasExistingOffer = offerSnapshot.hasData &&
            offerSnapshot.data != null &&
            offerSnapshot.data!.docs.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJobCardHeader(request.id, status, statusColor),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.directions_car, data['car'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.error_outline, data['problemDescription'] ?? 'Not specified'),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on, data['city'] ?? 'Location not specified'),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.calendar_today,
                      data['timestamp'] != null
                          ? DateFormatter.formatTimestamp(data['timestamp'])
                          : 'Date not available'
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(hasExistingOffer),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildJobCardHeader(String requestId, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Request ID: ${requestId.substring(0, 8)}...",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool hasExistingOffer) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasExistingOffer 
              ? Colors.blue 
              : JobConstants.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: Icon(
          hasExistingOffer ? Icons.edit : Icons.handshake,
          color: Colors.white
        ),
        label: Text(
          hasExistingOffer ? 'Edit Your Offer' : 'Make an Offer!',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}