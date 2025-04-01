// 
import 'package:flutter/material.dart';

class JobConstants {
  // Primary color used throughout the app
  static const Color primaryColor = Color.fromARGB(255, 208, 63, 2);
  
  // Filter options for job status
  static const List<String> filterOptions = [
    'All', 
    'pending', 
    'parts ordered', 
    'in progress', 
    'ready for pickup'
  ];
  
  // Display names for filter options (capitalized)
  static const Map<String, String> filterDisplayNames = {
    'All': 'All',
    'pending': 'Pending',
    'parts ordered': 'Parts Ordered',
    'in progress': 'In Progress',
    'ready for pickup': 'Ready for Pickup',
  };
  
  // Status colors for different job states
  static const Map<String, Color> statusColors = {
    'pending': Colors.purple,
    
    'parts ordered': Colors.blue,
    'in progress': Colors.orange,
    'ready for pickup': Colors.green,
  };
  
  // Service type options
  static const List<String> serviceTypes = [
    'Parts with Labor',
    'Labor Only',
  ];
}