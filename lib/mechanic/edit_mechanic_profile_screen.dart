import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditMechanicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> mechanicData;

  const EditMechanicProfileScreen({Key? key, required this.mechanicData}) : super(key: key);

  @override
  _EditMechanicProfileScreenState createState() => _EditMechanicProfileScreenState();
}

class _EditMechanicProfileScreenState extends State<EditMechanicProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController workshopController;
  String? selectedCity;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.mechanicData['fullName']);
    phoneController = TextEditingController(text: widget.mechanicData['phoneNumber']);
    workshopController = TextEditingController(text: widget.mechanicData['workshopName']);
    selectedCity = widget.mechanicData['location']; 
    _loadCities(); 
  }

  Future<void> _loadCities() async {
    String data = await rootBundle.loadString('assets/saudi_cities.json');
    List<dynamic> jsonList = jsonDecode(data);
    setState(() {
      cities = jsonList.map((city) => city.toString()).toList();
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('Mechanic').doc(user.uid).update({
      'fullName': nameController.text,
      'phoneNumber': phoneController.text,
      'workshopName': workshopController.text,
      'location': selectedCity, // Save the selected city
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: workshopController,
                decoration: const InputDecoration(labelText: "Workshop Name"),
              ),
              const SizedBox(height: 16),
              
              // City Dropdown
              DropdownButtonFormField<String>(
                value: selectedCity,
                items: cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? "Please select a city" : null,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
