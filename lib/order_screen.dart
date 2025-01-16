import 'package:automate/app_bar.dart';
import 'package:flutter/material.dart';
import 'navbar.dart';
import 'profile_screen.dart';
import 'cars_screen.dart';
import 'chat_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orders = [
      {
        'name': 'Muhammad Khan',
        'status': 'Pending',
        'car': 'Fortuner',
        'date': '10/23/2024',
        'image': 'assets/images/car1.png'
      },
      {
        'name': 'Ahmad Khan',
        'status': 'Working on it',
        'car': 'Syeera',
        'date': '10/11/2024',
        'image': 'assets/images/car2.png'
      },
      {
        'name': 'Muhammad Khan',
        'status': 'Fixed',
        'car': 'Centra',
        'date': '07/11/2024',
        'image': 'assets/images/car3.png'
      },
    ];

    return Scaffold(
      appBar: const AppBarWidget(pageName: 'Maintenance'),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(order['image']!),
              ),
              title: Text(
                order['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['status']!,
                    style: TextStyle(
                      color: order['status'] == 'Pending'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  Text(order['car']!),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(order['date']!),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Action for delete
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action to add new request
        },
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Correct index for Orders tab
        onTap: (index) {
          if (index == 1) return; // Prevent navigation if already on Orders

          // Use pushReplacement only if not on the current tab
        },
      ),
    );
  }
}
