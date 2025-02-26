import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:automate/bars/app_bar.dart';
import '../bars/navbar.dart';
import '../costumer/maintenance_request_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteRequest(String requestId) async {
    await _firestore.collection('maintenance_requests').doc(requestId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(pageName: 'Maintenance'),
      body: StreamBuilder(
        stream: _firestore
            .collection('maintenance_requests')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No requests added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first request!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.car_repair, color: Colors.white),
                  ),
                  title: Text(
                    "Request ID: ${request.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['status'] ?? 'Pending',
                        style: TextStyle(
                          color: request['status'] == 'Pending'
                              ? Colors.blue
                              : request['status'] == 'Fixed'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                      Text("Car: ${request['car']}"),
                      Text("City: ${request['city']}"),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteRequest(request.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MaintenanceRequestScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Orders tab index
        onTap: (index) {},
      ),
    );
  }
}
