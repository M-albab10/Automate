import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../costumer/order_screen.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() =>
      _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedCar;
  String? selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCars();
  }

  List<String> userCars = [];

  Future<void> _fetchUserCars() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot carDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cars')
        .get();

    setState(() {
      userCars = carDocs.docs
          .map((doc) => "\${doc['make']} \${doc['model']} (\${doc['year']})")
          .toList();
    });
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('maintenance_requests').add({
        'userId': user.uid,
        'problemDescription': _descriptionController.text,
        'car': selectedCar,
        'city': selectedCity,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance Request"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Maintenance Request",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text("Problem Description:"),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Describe the issue...",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a description" : null,
                ),
                const SizedBox(height: 15),
                const Text("Car:"),
                DropdownButtonFormField<String>(
                  value: selectedCar,
                  items: userCars
                      .map((car) =>
                          DropdownMenuItem(value: car, child: Text(car)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCar = value),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (value) =>
                      value == null ? "Please select a car" : null,
                ),
                const SizedBox(height: 15),
                const Text("City:"),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items: ["Riyadh", "Jeddah", "Dammam"]
                      .map((city) =>
                          DropdownMenuItem(value: city, child: Text(city)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCity = value),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (value) =>
                      value == null ? "Please select a city" : null,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _submitRequest,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            "Submit Request",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
