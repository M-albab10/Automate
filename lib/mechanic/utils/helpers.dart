import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHelper {
  static String getMechanicName(FirebaseAuth auth) {
    if (auth.currentUser?.displayName != null &&
        auth.currentUser!.displayName!.isNotEmpty) {
      return auth.currentUser!.displayName!;
    } else {
      // Try to extract name from email
      final email = auth.currentUser?.email ?? '';
      final namePart = email.split('@').first;
      // Capitalize first letter
      return namePart.isNotEmpty
          ? namePart.substring(0, 1).toUpperCase() + namePart.substring(1)
          : 'Mechanic';
    }
  }
}

class DialogHelper {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
      BuildContext context, String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
