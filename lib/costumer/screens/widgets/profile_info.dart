import 'package:flutter/material.dart';
import '../../models/mechanic_data.dart';
import '../utils/decorations.dart';

class ProfileInfo extends StatelessWidget {
  final MechanicData mechanic;

  const ProfileInfo({
    Key? key,
    required this.mechanic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: containerDecoration(),
      child: Column(
        children: [
          _buildInfoItem(Icons.person, 'Name', mechanic.name),
          const Divider(),
          _buildInfoItem(Icons.phone, 'Phone', mechanic.phone),
          const Divider(),
          _buildInfoItem(Icons.email, 'Email', mechanic.email),
          const Divider(),
          _buildInfoItem(Icons.work, 'Workshop', mechanic.workshop),
          const Divider(),
          _buildInfoItem(Icons.location_on, 'Location', mechanic.location),
          if (mechanic.specialties.isNotEmpty) ...[
            const Divider(),
            _buildSpecialties(mechanic.specialties),
          ],
          if (mechanic.description.isNotEmpty) ...[
            const Divider(),
            _buildDescription(mechanic.description),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 208, 63, 2)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialties(List<String> specialties) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle,
                  color: Color.fromARGB(255, 208, 63, 2)),
              const SizedBox(width: 16),
              Text('Specialties',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specialties
                .map((specialty) => Chip(
                      label: Text(specialty),
                      backgroundColor: const Color.fromARGB(255, 208, 63, 2)
                          .withAlpha(25),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 208, 63, 2)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color.fromARGB(255, 208, 63, 2)),
              const SizedBox(width: 16),
              Text('About',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
