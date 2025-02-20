import 'package:automate/bars/app_bar.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../bars/mechanic_navbar.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicProfileScreen extends StatefulWidget {
  const MechanicProfileScreen({super.key});

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? mechanicData;
  bool isLoading = true;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadMechanicData();
  }

  Future<void> _loadMechanicData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Mechanic')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            mechanicData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = mechanicData?['fullName'] ?? 'Loading...';
    final String phone = mechanicData?['phoneNumber'] ?? 'Loading...';
    final String email = mechanicData?['email'] ?? 'Loading...';
    final String workshop = mechanicData?['workshopName'] ?? 'Loading...';
    final String location = mechanicData?['location'] ?? 'Loading...';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AppBarWidget(pageName: 'Mechanic Profile'),
      body: RefreshIndicator(
        onRefresh: _loadMechanicData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildProfileHeader(name),
                const SizedBox(height: 16),
                _buildProfileInfo(name, phone, email, workshop, location),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
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

  Widget _buildProfileHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/default_avatar.png'),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String name, String phone, String email, String workshop, String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _containerDecoration(),
      child: Column(
        children: [
          _buildInfoItem(Icons.person, 'Name', name),
          const Divider(),
          _buildInfoItem(Icons.phone, 'Phone', phone),
          const Divider(),
          _buildInfoItem(Icons.email, 'Email', email),
          const Divider(),
          _buildInfoItem(Icons.work, 'Workshop', workshop),
          const Divider(),
          _buildInfoItem(Icons.location_on, 'Location', location),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
          style: _buttonStyle(Colors.red),
          child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 2,
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(13),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
