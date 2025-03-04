import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bars/app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Use existing userData instead of loading again
    _nameController.text = widget.userData['username'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phoneNumber'] ?? '';
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      String userId = _auth.currentUser!.uid;
      Map<String, dynamic> updates = {};
      
      // Only update fields that have changed
      if (_nameController.text.trim() != widget.userData['username']) {
        updates['username'] = _nameController.text.trim();
      }
      
      if (_phoneController.text.trim() != widget.userData['phoneNumber']) {
        updates['phoneNumber'] = _phoneController.text.trim();
      }

      String newEmail = _emailController.text.trim();
      if (newEmail != widget.userData['email']) {
        // Handle email update separately
        User? user = _auth.currentUser;
        if (user != null) {
          try {
            await user.verifyBeforeUpdateEmail(newEmail);
            updates['email'] = newEmail;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email sent. Please verify before logging in.'),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating email: $e')),
            );
            setState(() => _isUpdating = false);
            return;
          }
        }
      }

      // Only update Firestore if there are changes
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // No changes made
        if (mounted) {
          Navigator.pop(context, false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(pageName: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(Icons.person, 'Full Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField(Icons.email, 'Email', _emailController,
                  isEmail: true),
              const SizedBox(height: 16),
              _buildTextField(
                  Icons.phone, 'Phone Number', _phoneController,
                  isPhone: true),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
   Widget _buildTextField(
      IconData icon, String label, TextEditingController controller,
      {bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label';
        if (isEmail &&
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (isPhone && !RegExp(r'^\d{10,}$').hasMatch(value)) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _updateProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2,
      ),
      child: _isUpdating
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
  // Rest of the widget building code remains the same...

