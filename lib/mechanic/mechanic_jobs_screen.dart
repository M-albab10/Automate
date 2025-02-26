import 'package:flutter/material.dart';

import 'package:automate/services/car_service.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/mechanic_navbar.dart';

class MechanicJobsScreen extends StatefulWidget {
  const MechanicJobsScreen({super.key});

  @override
  State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
}

class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
  // final CarService _carService = CarService();
  int _currentIndex = 0; // Jobs is index 0 in mechanic navigation
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> jobs = [
    {
      'customerName': 'Ahmed Mohammed',
      'carModel': 'Toyota Camry 2022',
      'issue': 'Engine check light on',
      'status': 'Pending',
      'date': '26 Feb 2025',
      'location': 'Riyadh, Saudi Arabia',
    },
    {
      'customerName': 'Sara Abdullah',
      'carModel': 'Honda Accord 2023',
      'issue': 'Brake system inspection',
      'status': 'In Progress',
      'date': '26 Feb 2025',
      'location': 'Jeddah, Saudi Arabia',
    },
    {
      'customerName': 'Khalid Hassan',
      'carModel': 'Nissan Altima 2024',
      'issue': 'Regular maintenance',
      'status': 'Completed',
      'date': '25 Feb 2025',
      'location': 'Dammam, Saudi Arabia',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(pageName: 'Jobs'),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
      bottomNavigationBar: MechanicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Jobs',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Pending', 'In Progress', 'Completed']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedFilter == filter,
                        label: Text(filter),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blue,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        Color statusColor;
        switch (job['status']) {
          case 'Pending':
            statusColor = Colors.orange;
            break;
          case 'In Progress':
            statusColor = Colors.blue;
            break;
          case 'Completed':
            statusColor = Colors.green;
            break;
          default:
            statusColor = Colors.grey;
        }

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
              onTap: () {
                // Navigate to job details
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          job['customerName'],
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
                            job['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.directions_car, job['carModel']),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.error_outline, job['issue']),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on, job['location']),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.calendar_today, job['date']),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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