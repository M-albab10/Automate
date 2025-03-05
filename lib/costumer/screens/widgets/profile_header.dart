import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final double rating;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color.fromARGB(255, 208, 63, 2),
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                rating > 0 ? rating.toStringAsFixed(1) : 'New mechanic',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}