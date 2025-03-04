import 'package:flutter/material.dart';

class RequestDetailsCard extends StatelessWidget {
  final String carModel;
  final String problemDescription;
  final String requestId;

  const RequestDetailsCard({
    Key? key,
    required this.carModel,
    required this.problemDescription,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Request Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.directions_car, 'Car: $carModel'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.error_outline, 'Problem: $problemDescription'),
          const SizedBox(height: 8),
          _buildInfoRow(
              Icons.numbers, 'Request ID: ${requestId.substring(0, 8)}...'),
        ],
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