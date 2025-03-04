// car_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add a new car
  Future<void> addCar(Map<String, dynamic> carData) async {
    if (currentUserId == null) throw Exception('No user logged in');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cars')
          .add({
        ...carData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  // Get all cars for current user
  Stream<QuerySnapshot> getUserCars() {
    if (currentUserId == null) throw Exception('No user logged in');

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cars')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete a car
  Future<void> deleteCar(String carId) async {
    if (currentUserId == null) throw Exception('No user logged in');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cars')
          .doc(carId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }
}
