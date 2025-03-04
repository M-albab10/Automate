import 'package:flutter/material.dart';

class JobConstants {
  // Primary color used throughout the app
  static const Color primaryColor = Color.fromARGB(255, 208, 63, 2);
  
  // Filter options for job status
  static const List<String> filterOptions = [
    'All', 
    'Pending', 
    'In Progress', 
    'Completed', 
    'Fixed'
  ];
  
  // Status colors for different job states
  static const Map<String, Color> statusColors = {
    'Pending': Colors.orange,
    'In Progress': Colors.blue,
    'Completed': Colors.green,
    'Fixed': Colors.green,
  };
  
  // Service type options
  static const List<String> serviceTypes = [
    'Parts with Labor',
    'Labor Only',
  ];
}