import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../screens/mechanic_profile_viewer.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OfferCard({
    Key? key,
    required this.offer,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMechanicHeader(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceAndStatus(),
                const SizedBox(height: 16),
                _buildServiceType(),
                const SizedBox(height: 16),
                _buildTimeNeeded(),
                const SizedBox(height: 12),
                _buildRepairsNeeded(),
                if (offer.description.isNotEmpty &&
                    offer.description != 'No description provided')
                  _buildAdditionalDetails(),
                if (offer.status == 'Pending') _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 208, 63, 2).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color.fromARGB(255, 208, 63, 2),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToMechanicProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        offer.mechanicName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color.fromARGB(255, 208, 63, 2),
                      ),
                    ],
                  ),
                  if (offer.mechanicEmail.isNotEmpty)
                    Text(
                      offer.mechanicEmail,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndStatus() {
    Color statusColor;
    switch (offer.status) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Cost:',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              'SAR ${offer.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 208, 63, 2),
              ),
            ),
          ],
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
            offer.status,
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

  Widget _buildServiceType() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 208, 63, 2).withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color.fromARGB(255, 208, 63, 2).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            offer.serviceType == 'Labor Only' ? Icons.build : Icons.inventory_2,
            size: 16,
            color: const Color.fromARGB(255, 208, 63, 2),
          ),
          const SizedBox(width: 6),
          Text(
            offer.serviceType,
            style: const TextStyle(
              color: Color.fromARGB(255, 208, 63, 2),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeNeeded() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        const Text(
          'Time Needed:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          offer.estimatedTime,
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRepairsNeeded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.build, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Repairs Needed:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            offer.repairsNeeded,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Details:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            offer.description,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 208, 63, 2),
              ),
              child: const Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMechanicProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MechanicProfileViewer(
          mechanicId: offer.mechanicId,
          mechanicName: offer.mechanicName,
        ),
      ),
    );
  }
}
