// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/constants.dart';
// import 'package:intl/intl.dart';

// class AcceptedJobCard extends StatelessWidget {
//   final DocumentSnapshot request;
//   final DocumentSnapshot acceptedOffer;
//   final VoidCallback onTap;
//   final Function(String) onStatusChange;

//   const AcceptedJobCard({
//     Key? key,
//     required this.request,
//     required this.acceptedOffer,
//     required this.onTap,
//     required this.onStatusChange,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final requestData = request.data() as Map<String, dynamic>;
//     final offerData = acceptedOffer.data() as Map<String, dynamic>;
    
//     // Job details
//     final car = requestData['car'] ?? 'Unknown vehicle';
//     final problemDescription = requestData['problemDescription'] ?? 'No description';
//     final status = requestData['status'] ?? 'pending';
//     final price = offerData['price'] ?? '0';
    
//     // Status display configuration
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: statusColor.withAlpha(178), width: 1.5),
//       ),
//       child: Column(
//         children: [
//           // Status Banner
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: statusColor,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _getStatusIcon(status),
//                   const SizedBox(width: 8),
//                   Text(
//                     statusDisplay,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
              
//           // Main content
//           InkWell(
//             onTap: onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Car info row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               car,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 2),
//                             if (offerData['acceptedAt'] != null)
//                               Text(
//                                 'Accepted: ${_formatDate(offerData['acceptedAt'])}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       // Price container
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.green[200]!),
//                         ),
//                         child: Text(
//                           '\$${price.toString()}',
//                           style: TextStyle(
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 12),
//                   const Divider(height: 1),
//                   const SizedBox(height: 12),
                  
//                   // Problem description
//                   Text(
//                     'Problem:',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     problemDescription,
//                     style: const TextStyle(
//                       fontSize: 14,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Status Change Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Update Status:',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildStatusButtons(context, status),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusButtons(BuildContext context, String currentStatus) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           _buildStatusButton(context, currentStatus, 'pending', 'Pending'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'parts ordered', 'Parts Ordered'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'in progress', 'In Progress'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'ready for pickup', 'Ready for Pickup'),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusButton(BuildContext context, String currentStatus, String statusKey, String label) {
//     final isCurrentStatus = currentStatus == statusKey;
//     final statusColor = JobConstants.statusColors[statusKey] ?? Colors.grey;
    
//     return OutlinedButton(
//       onPressed: isCurrentStatus 
//           ? null // Disable for current status
//           : () => _confirmStatusChange(context, currentStatus, statusKey),
//       style: OutlinedButton.styleFrom(
//         backgroundColor: isCurrentStatus ? statusColor.withAlpha(37) : Colors.transparent,
//         foregroundColor: isCurrentStatus ? statusColor : Colors.grey[700],
//         side: BorderSide(
//           color: isCurrentStatus ? statusColor : Colors.grey[400]!,
//           width: isCurrentStatus ? 1.5 : 1.0,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   void _confirmStatusChange(BuildContext context, String currentStatus, String newStatus) {
//     final currentLabel = JobConstants.filterDisplayNames[currentStatus] ?? currentStatus;
//     final newLabel = JobConstants.filterDisplayNames[newStatus] ?? newStatus;
    
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Update to "$newLabel"?'),
//         content: Text('Change job status from "$currentLabel" to "$newLabel"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onStatusChange(newStatus);
//               Navigator.of(ctx).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: JobConstants.primaryColor,
//             ),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getStatusIcon(String status) {
//     IconData iconData;
//     switch (status) {
//       case 'pending':
//         iconData = Icons.access_time;
//         break;
//       case 'parts ordered':
//         iconData = Icons.shopping_cart;
//         break;
//       case 'in progress':
//         iconData = Icons.build;
//         break;
//       case 'ready for pickup':
//         iconData = Icons.check_circle;
//         break;
//       default:
//         iconData = Icons.info;
//     }
//     return Icon(iconData, color: Colors.white, size: 18);
//   }

//   String _formatDate(dynamic timestamp) {
//     if (timestamp == null) return 'N/A';
    
//     if (timestamp is Timestamp) {
//       final date = timestamp.toDate();
//       return DateFormat('MMM d, yyyy').format(date);
//     }
    
//     return 'N/A';
//   }
// }



//here good

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/constants.dart';
// import 'package:intl/intl.dart';

// class AcceptedJobCard extends StatelessWidget {
//   final DocumentSnapshot request;
//   final DocumentSnapshot acceptedOffer;
//   final VoidCallback onTap;
//   final Function(String) onStatusChange;

//   const AcceptedJobCard({
//     Key? key,
//     required this.request,
//     required this.acceptedOffer,
//     required this.onTap,
//     required this.onStatusChange,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final requestData = request.data() as Map<String, dynamic>;
//     final offerData = acceptedOffer.data() as Map<String, dynamic>;
    
//     // Job details
//     final car = requestData['car'] ?? 'Unknown vehicle';
//     final status = requestData['status'] ?? 'pending';
//     final price = offerData['price'] ?? '0';
    
//     // Status display configuration
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: statusColor.withAlpha(178), width: 1.5),
//       ),
//       child: Column(
//         children: [
//           // Status Banner
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: statusColor,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _getStatusIcon(status),
//                   const SizedBox(width: 8),
//                   Text(
//                     statusDisplay,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
              
//           // Main content - more compact now
//           InkWell(
//             onTap: onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Car info row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               car,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             if (offerData['acceptedAt'] != null)
//                               Text(
//                                 'Accepted: ${_formatDate(offerData['acceptedAt'])}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       // Price container
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.green[200]!),
//                         ),
//                         child: Text(
//                           '\$${price.toString()}',
//                           style: TextStyle(
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 12),
                  
//                   // Status Change Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Update Status:',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildStatusButtons(context, status),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusButtons(BuildContext context, String currentStatus) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           _buildStatusButton(context, currentStatus, 'pending', 'Pending'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'parts ordered', 'Parts Ordered'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'in progress', 'In Progress'),
//           const SizedBox(width: 8),
//           _buildStatusButton(context, currentStatus, 'ready for pickup', 'Ready for Pickup'),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusButton(BuildContext context, String currentStatus, String statusKey, String label) {
//     final isCurrentStatus = currentStatus == statusKey;
//     final statusColor = JobConstants.statusColors[statusKey] ?? Colors.grey;
    
//     return OutlinedButton(
//       onPressed: isCurrentStatus 
//           ? null // Disable for current status
//           : () => _confirmStatusChange(context, currentStatus, statusKey),
//       style: OutlinedButton.styleFrom(
//         backgroundColor: isCurrentStatus ? statusColor.withAlpha(37) : Colors.transparent,
//         foregroundColor: isCurrentStatus ? statusColor : Colors.grey[700],
//         side: BorderSide(
//           color: isCurrentStatus ? statusColor : Colors.grey[400]!,
//           width: isCurrentStatus ? 1.5 : 1.0,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   void _confirmStatusChange(BuildContext context, String currentStatus, String newStatus) {
//     final currentLabel = JobConstants.filterDisplayNames[currentStatus] ?? currentStatus;
//     final newLabel = JobConstants.filterDisplayNames[newStatus] ?? newStatus;
    
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Update to "$newLabel"?'),
//         content: Text('Change job status from "$currentLabel" to "$newLabel"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onStatusChange(newStatus);
//               Navigator.of(ctx).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: JobConstants.primaryColor,
//             ),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getStatusIcon(String status) {
//     IconData iconData;
//     switch (status) {
//       case 'pending':
//         iconData = Icons.access_time;
//         break;
//       case 'parts ordered':
//         iconData = Icons.shopping_cart;
//         break;
//       case 'in progress':
//         iconData = Icons.build;
//         break;
//       case 'ready for pickup':
//         iconData = Icons.check_circle;
//         break;
//       default:
//         iconData = Icons.info;
//     }
//     return Icon(iconData, color: Colors.white, size: 18);
//   }

//   String _formatDate(dynamic timestamp) {
//     if (timestamp == null) return 'N/A';
    
//     if (timestamp is Timestamp) {
//       final date = timestamp.toDate();
//       return DateFormat('MMM d, yyyy').format(date);
//     }
    
//     return 'N/A';
//   }
// }
// here good?

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/constants.dart';
// import 'package:intl/intl.dart';

// class AcceptedJobCard extends StatelessWidget {
//   final DocumentSnapshot request;
//   final DocumentSnapshot acceptedOffer;
//   final VoidCallback onTap;
//   final Function(String) onStatusChange;

//   const AcceptedJobCard({
//     Key? key,
//     required this.request,
//     required this.acceptedOffer,
//     required this.onTap,
//     required this.onStatusChange,
//   }) : super(key: key);
  
//   // Helper method to normalize status strings
//   String _normalizeStatus(String? status) {
//     if (status == null) return 'pending';
//     return status.toLowerCase().trim();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final requestData = request.data() as Map<String, dynamic>;
//     final offerData = acceptedOffer.data() as Map<String, dynamic>;
    
//     // Job details
//     final car = requestData['car'] ?? 'Unknown vehicle';
//     final status = requestData['status'] ?? 'pending';
//     final normalizedStatus = _normalizeStatus(status);
//     final price = offerData['price'] ?? '0';
    
//     // Status display configuration
//     final statusColor = JobConstants.statusColors[normalizedStatus] ??
//                         JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[normalizedStatus] ?? 
//                           JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: statusColor.withAlpha(178), width: 1.5),
//       ),
//       child: Column(
//         children: [
//           // Status Banner
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: statusColor,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _getStatusIcon(normalizedStatus),
//                   const SizedBox(width: 8),
//                   Text(
//                     statusDisplay,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
              
//           // Main content - more compact now
//           InkWell(
//             onTap: onTap,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Car info row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               car,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             if (offerData['acceptedAt'] != null)
//                               Text(
//                                 'Accepted: ${_formatDate(offerData['acceptedAt'])}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       // Price container
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.green[200]!),
//                         ),
//                         child: Text(
//                           '\$${price.toString()}',
//                           style: TextStyle(
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 12),
                  
//                   // Status Change Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Update Status:',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildStatusButtons(context, normalizedStatus),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusButtons(BuildContext context, String currentStatus) {
//     // Get valid next statuses based on current status
//     List<String> validNextStatuses = _getValidNextStatuses(currentStatus);
    
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: _buildStatusButtonsList(context, currentStatus, validNextStatuses),
//       ),
//     );
//   }
  
//   List<Widget> _buildStatusButtonsList(BuildContext context, String currentStatus, List<String> validStatuses) {
//     List<Widget> buttons = [];
    
//     // Define all possible statuses in order
//     final allStatuses = [
//       // 'pending',

//       'parts ordered',
//       'in progress',
//       'ready for pickup'
//     ];
    
//     // Only show status buttons that are valid transitions
//     for (var status in allStatuses) {
//       final isValid = validStatuses.contains(status);
//       final isCurrentStatus = currentStatus == status;
      
//       buttons.add(
//         _buildStatusButton(
//           context, 
//           currentStatus, 
//           status, 
//           JobConstants.filterDisplayNames[status] ?? status,
//           isEnabled: isValid || isCurrentStatus
//         )
//       );
      
//       if (status != allStatuses.last) {
//         buttons.add(const SizedBox(width: 8));
//       }
//     }
    
//     return buttons;
//   }

//   List<String> _getValidNextStatuses(String currentStatus) {
//     switch (currentStatus) {
//       case 'pending':
//         return ['in progress', 'parts ordered'];
//       case 'in progress':
//         return ['parts ordered', 'ready for pickup'];
//       case 'parts ordered':
//         return ['in progress', 'ready for pickup'];
//       case 'ready for pickup':
//         return ['in progress', 'parts ordered']; // Allow going back from ready for pickup
//       default:
//         return [];
//     }
//   }

//   Widget _buildStatusButton(
//     BuildContext context, 
//     String currentStatus, 
//     String statusKey, 
//     String label, 
//     {bool isEnabled = true}
//   ) {
//     final isCurrentStatus = currentStatus == statusKey;
//     final statusColor = JobConstants.statusColors[statusKey] ?? Colors.grey;
    
//     return OutlinedButton(
//       onPressed: isCurrentStatus || !isEnabled
//           ? null // Disable for current status or invalid transitions
//           : () => _confirmStatusChange(context, currentStatus, statusKey),
//       style: OutlinedButton.styleFrom(
//         backgroundColor: isCurrentStatus ? statusColor.withAlpha(37) : Colors.transparent,
//         foregroundColor: isCurrentStatus ? statusColor : isEnabled ? Colors.grey[700] : Colors.grey[400],
//         side: BorderSide(
//           color: isCurrentStatus ? statusColor : isEnabled ? Colors.grey[400]! : Colors.grey[300]!,
//           width: isCurrentStatus ? 1.5 : 1.0,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   void _confirmStatusChange(BuildContext context, String currentStatus, String newStatus) {
//     final currentLabel = JobConstants.filterDisplayNames[currentStatus] ?? currentStatus;
//     final newLabel = JobConstants.filterDisplayNames[newStatus] ?? newStatus;
    
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Update to "$newLabel"?'),
//         content: Text('Change job status from "$currentLabel" to "$newLabel"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onStatusChange(newStatus);
//               Navigator.of(ctx).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: JobConstants.primaryColor,
//             ),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getStatusIcon(String status) {
//     IconData iconData;
//     switch (status) {
//       case 'pending':
//         iconData = Icons.access_time;
//         break;
//       case 'parts ordered':
//         iconData = Icons.shopping_cart;
//         break;
//       case 'in progress':
//         iconData = Icons.build;
//         break;
//       case 'ready for pickup':
//         iconData = Icons.check_circle;
//         break;
//       default:
//         iconData = Icons.info;
//     }
//     return Icon(iconData, color: Colors.white, size: 18);
//   }

//   String _formatDate(dynamic timestamp) {
//     if (timestamp == null) return 'N/A';
    
//     if (timestamp is Timestamp) {
//       final date = timestamp.toDate();
//       return DateFormat('MMM d, yyyy').format(date);
//     }
    
//     return 'N/A';
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class AcceptedJobCard extends StatelessWidget {
  final DocumentSnapshot request;
  final DocumentSnapshot acceptedOffer;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const AcceptedJobCard({
    Key? key,
    required this.request,
    required this.acceptedOffer,
    required this.onTap,
    required this.onStatusChange,
  }) : super(key: key);
  
  // Helper method to normalize status strings
  String _normalizeStatus(String? status) {
    if (status == null) return 'pending';
    return status.toLowerCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    final requestData = request.data() as Map<String, dynamic>;
    final offerData = acceptedOffer.data() as Map<String, dynamic>;
    
    // Job details
    final car = requestData['car'] ?? 'Unknown vehicle';
    final status = requestData['status'] ?? 'pending';
    final normalizedStatus = _normalizeStatus(status);
    final price = offerData['price'] ?? '0';
    
    // Status display configuration
    final statusColor = JobConstants.statusColors[normalizedStatus] ?? 
                      JobConstants.statusColors[status] ?? Colors.grey;
    final statusDisplay = JobConstants.filterDisplayNames[normalizedStatus] ?? 
                        JobConstants.filterDisplayNames[status] ?? status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: statusColor.withAlpha(178), width: 1.5),
      ),
      child: Column(
        children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getStatusIcon(normalizedStatus),
                  const SizedBox(width: 8),
                  Text(
                    statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
              
          // Main content - more compact now
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car info row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (offerData['acceptedAt'] != null)
                              Text(
                                'Accepted: ${_formatDate(offerData['acceptedAt'])}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          '\$${price.toString()}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status Change Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Status:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusButtons(context, normalizedStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context, String currentStatus) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatusButton(context, currentStatus, 'pending', 'Pending'),
          const SizedBox(width: 8),
          _buildStatusButton(context, currentStatus, 'parts ordered', 'Parts Ordered'),
          const SizedBox(width: 8),
          _buildStatusButton(context, currentStatus, 'in progress', 'In Progress'),
          const SizedBox(width: 8),
          _buildStatusButton(context, currentStatus, 'ready for pickup', 'Ready for Pickup'),
          const SizedBox(width: 8),
          _buildStatusButton(context, currentStatus, 'completed', 'Completed'),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String currentStatus, String statusKey, String label) {
    final isCurrentStatus = currentStatus == statusKey;
    final statusColor = JobConstants.statusColors[statusKey] ?? Colors.grey;
    
    return OutlinedButton(
      onPressed: isCurrentStatus 
          ? null // Disable for current status
          : () => _confirmStatusChange(context, currentStatus, statusKey),
      style: OutlinedButton.styleFrom(
        backgroundColor: isCurrentStatus ? statusColor.withAlpha(37) : Colors.transparent,
        foregroundColor: isCurrentStatus ? statusColor : Colors.grey[700],
        side: BorderSide(
          color: isCurrentStatus ? statusColor : Colors.grey[400]!,
          width: isCurrentStatus ? 1.5 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _confirmStatusChange(BuildContext context, String currentStatus, String newStatus) {
    final currentLabel = JobConstants.filterDisplayNames[currentStatus] ?? currentStatus;
    final newLabel = JobConstants.filterDisplayNames[newStatus] ?? newStatus;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update to "$newLabel"?'),
        content: Text('Change job status from "$currentLabel" to "$newLabel"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onStatusChange(newStatus);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JobConstants.primaryColor,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    switch (status) {
      case 'pending':
        iconData = Icons.access_time;
        break;
      case 'parts ordered':
        iconData = Icons.shopping_cart;
        break;
      case 'in progress':
        iconData = Icons.build;
        break;
      case 'ready for pickup':
        iconData = Icons.check_circle;
        break;
      case 'completed':
        iconData = Icons.done_all;
        break;
      default:
        iconData = Icons.info;
    }
    return Icon(iconData, color: Colors.white, size: 18);
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMM d, yyyy').format(date);
    }
    
    return 'N/A';
  }
}