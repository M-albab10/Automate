//design 1
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utils/constants.dart';
// import '../utils/formatters.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;
  
//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Map<String, dynamic> data = request.data() as Map<String, dynamic>;
//     String status = data['status'] ?? 'Pending';
//     Color statusColor = JobConstants.statusColors[status] ?? Colors.grey;
    
//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('offers')
//           .where('requestId', isEqualTo: request.id)
//           .where('mechanicId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//           .get(),
//       builder: (context, offerSnapshot) {
//         bool hasExistingOffer = offerSnapshot.hasData &&
//             offerSnapshot.data != null &&
//             offerSnapshot.data!.docs.isNotEmpty;

//         return Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withAlpha(13),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(15),
//               onTap: onTap,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildJobCardHeader(request.id, status, statusColor),
//                     const SizedBox(height: 8),
//                     _buildInfoRow(Icons.directions_car, data['car'] ?? 'N/A'),
//                     const SizedBox(height: 4),
//                     _buildInfoRow(Icons.error_outline, data['problemDescription'] ?? 'Not specified'),
//                     const SizedBox(height: 4),
//                     _buildInfoRow(Icons.location_on, data['city'] ?? 'Location not specified'),
//                     const SizedBox(height: 4),
//                     _buildInfoRow(
//                       Icons.calendar_today,
//                       data['timestamp'] != null
//                           ? DateFormatter.formatTimestamp(data['timestamp'])
//                           : 'Date not available'
//                     ),
//                     const SizedBox(height: 16),
//                     _buildActionButton(hasExistingOffer),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }

//   Widget _buildJobCardHeader(String requestId, String status, Color statusColor) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "Request ID: ${requestId.substring(0, 8)}...",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 4,
//           ),
//           decoration: BoxDecoration(
//             color: statusColor.withAlpha(25),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             status,
//             style: TextStyle(
//               color: statusColor,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton(bool hasExistingOffer) {
//     return Align(
//       alignment: Alignment.center,
//       child: ElevatedButton.icon(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: hasExistingOffer 
//               ? Colors.blue 
//               : JobConstants.primaryColor,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         ),
//         icon: Icon(
//           hasExistingOffer ? Icons.edit : Icons.handshake,
//           color: Colors.white
//         ),
//         label: Text(
//           hasExistingOffer ? 'Edit Your Offer' : 'Make an Offer!',
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

//design 2

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final data = request.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Status and date
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       statusDisplay,
//                       style: TextStyle(
//                         color: statusColor,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   if (data['dateCreated'] is Timestamp)
//                     Text(
//                       _formatDate(data['dateCreated']),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                 ],
//               ),
              
//               const SizedBox(height: 12),
              
//               // Vehicle info
//               Text(
//                 car,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
              
//               const SizedBox(height: 8),
              
//               // Problem description
//               Text(
//                 problemDescription,
//                 style: const TextStyle(fontSize: 14),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
              
//               const SizedBox(height: 8),
              
//               // View details button
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: onTap,
//                   style: TextButton.styleFrom(
//                     foregroundColor: JobConstants.primaryColor,
//                     minimumSize: Size.zero,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: const Text('View Details'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
//design 3
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final data = request.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(
//           color: Colors.grey.shade200,
//           width: 1,
//         ),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Status indicator bar
//               Container(
//                 width: 4,
//                 height: 75,
//                 decoration: BoxDecoration(
//                   color: statusColor,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
              
//               const SizedBox(width: 12),
              
//               // Main content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Car name with status pill
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             car,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
                        
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             statusDisplay,
//                             style: TextStyle(
//                               color: statusColor,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 6),
                    
//                     // Problem description
//                     Text(
//                       problemDescription,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[800],
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Date and view button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         if (data['dateCreated'] is Timestamp)
//                           Text(
//                             _formatDate(data['dateCreated']),
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           )
//                         else
//                           const SizedBox.shrink(),
                          
//                         TextButton(
//                           onPressed: onTap,
//                           style: TextButton.styleFrom(
//                             foregroundColor: JobConstants.primaryColor,
//                             minimumSize: Size.zero,
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             textStyle: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13,
//                             ),
//                           ),
//                           child: const Text('View Details'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
// design 4
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     final data = request.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;
    
//     // Check if the current mechanic has responded to this request
//     final bool hasResponded = data['respondedMechanics'] != null && 
//         (data['respondedMechanics'] as List<dynamic>).contains(currentMechanicId);

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       // If mechanic has responded, add a highlight
//       color: hasResponded ? const Color(0xFFF8F8FF) : Colors.white, 
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Stack(
//           children: [
//             // Main content
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Status indicator bar
//                   Container(
//                     width: 4,
//                     height: 90, // Increased height a bit
//                     decoration: BoxDecoration(
//                       color: statusColor,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
                  
//                   const SizedBox(width: 12),
                  
//                   // Main content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Car name with status pill
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 car,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
                            
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: statusColor.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 statusDisplay,
//                                 style: TextStyle(
//                                   color: statusColor,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         const SizedBox(height: 6),
                        
//                         // Problem description
//                         Text(
//                           problemDescription,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF424242), // Darker text instead of grey
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
                        
//                         const SizedBox(height: 10), // Increased spacing
                        
//                         // Date and view button
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             if (data['dateCreated'] is Timestamp)
//                               Text(
//                                 _formatDate(data['dateCreated']),
//                                 style: const TextStyle(
//                                   color: Color(0xFF757575), // Specific grey instead of dynamic
//                                   fontSize: 12,
//                                 ),
//                               )
//                             else
//                               const SizedBox.shrink(),
                              
//                             TextButton(
//                               onPressed: onTap,
//                               style: TextButton.styleFrom(
//                                 foregroundColor: JobConstants.primaryColor,
//                                 minimumSize: Size.zero,
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               child: const Text('View Details'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // "You Responded" indicator
//             if (hasResponded)
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: JobConstants.primaryColor,
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(10),
//                       bottomLeft: Radius.circular(10),
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   child: const Text(
//                     'You Responded',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

//design 5
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     final data = request.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     // We'll use FutureBuilder to check if mechanic has responded
//     return FutureBuilder<QuerySnapshot>(
//       // Check the offers collection for this specific request and mechanic
//       future: _firestore
//           .collection('offers')
//           .where('requestId', isEqualTo: request.id)
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get(),
//       builder: (context, snapshot) {
//         // Determine if mechanic has offered
//         bool hasOffered = false;
//         if (snapshot.connectionState == ConnectionState.done && 
//             snapshot.hasData && 
//             snapshot.data!.docs.isNotEmpty) {
//           hasOffered = true;
//         }

//         return Card(
//           margin: const EdgeInsets.only(bottom: 10),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(10),
//             child: Column(
//               children: [
//                 // Response indicator at the top
//                 if (hasOffered)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF2E7D32), // Dark green
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10),
//                       ),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'You have sent an offer for this job',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                 // Main content
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Status indicator bar
//                       Container(
//                         width: 4,
//                         height: 75,
//                         decoration: BoxDecoration(
//                           color: statusColor,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
                      
//                       const SizedBox(width: 12),
                      
//                       // Main content
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Car name with status pill
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     car,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
                                
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: statusColor.withAlpha(25),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     statusDisplay,
//                                     style: TextStyle(
//                                       color: statusColor,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
                            
//                             const SizedBox(height: 6),
                            
//                             // Problem description
//                             Text(
//                               problemDescription,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
                            
//                             const SizedBox(height: 8),
                            
//                             // Date and view button
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 if (data['dateCreated'] is Timestamp)
//                                   Text(
//                                     _formatDate(data['dateCreated']),
//                                     style: const TextStyle(
//                                       color: Color(0xFF757575),
//                                       fontSize: 12,
//                                     ),
//                                   )
//                                 else
//                                   const SizedBox.shrink(),
                                  
//                                 TextButton.icon(
//                                   onPressed: onTap,
//                                   icon: const Icon(Icons.visibility_outlined, size: 16),
//                                   label: const Text('Details'),
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: JobConstants.primaryColor,
//                                     minimumSize: Size.zero,
//                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                     textStyle: const TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// design 6
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     final data = request.data() as Map<String, dynamic>;
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return FutureBuilder<QuerySnapshot>(
//       future: _firestore
//           .collection('offers')
//           .where('requestId', isEqualTo: request.id)
//           .where('mechanicId', isEqualTo: currentMechanicId)
//           .get(),
//       builder: (context, snapshot) {
//         bool hasOffered = false;
//         if (snapshot.connectionState == ConnectionState.done && 
//             snapshot.hasData && 
//             snapshot.data!.docs.isNotEmpty) {
//           hasOffered = true;
//         }

//         return Card(
//           margin: const EdgeInsets.only(bottom: 10),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(10),
//             child: Column(
//               children: [
//                 // Response indicator at the top
//                 if (hasOffered)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF2E7D32), // Dark green
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10),
//                       ),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'You have sent an offer for this job',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                 // Main content
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Status indicator bar
//                       Container(
//                         width: 4,
//                         height: 75,
//                         decoration: BoxDecoration(
//                           color: statusColor,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
                      
//                       const SizedBox(width: 12),
                      
//                       // Main content
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Car name with status pill
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     car,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
                                
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: statusColor.withAlpha(30), // Using withAlpha instead of withOpacity
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     statusDisplay,
//                                     style: TextStyle(
//                                       color: statusColor,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
                            
//                             const SizedBox(height: 6),
                            
//                             // Problem description
//                             Text(
//                               problemDescription,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
                            
//                             const SizedBox(height: 8),
                            
//                             // Date and view button
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 if (data['dateCreated'] is Timestamp)
//                                   Text(
//                                     _formatDate(data['dateCreated']),
//                                     style: const TextStyle(
//                                       color: Color(0xFF757575),
//                                       fontSize: 12,
//                                     ),
//                                   )
//                                 else
//                                   const SizedBox.shrink(),
                                  
//                                 TextButton.icon(
//                                   onPressed: onTap,
//                                   icon: const Icon(Icons.visibility_outlined, size: 16),
//                                   label: const Text('Details'),
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: JobConstants.primaryColor,
//                                     minimumSize: Size.zero,
//                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                     textStyle: const TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
// //design 7
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../utils/constants.dart';

// class JobCardWidget extends StatelessWidget {
//   final DocumentSnapshot request;
//   final VoidCallback onTap;

//   const JobCardWidget({
//     Key? key,
//     required this.request,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final String currentMechanicId = _auth.currentUser?.uid ?? '';
//     final data = request.data() as Map<String, dynamic>;
    
//     // Job details
//     final car = data['car'] ?? 'Unknown vehicle';
//     final problemDescription = data['problemDescription'] ?? 'No description';
//     final status = data['status'] ?? 'pending';
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;
    
//     // Check if there's an accepted offer for this request
//     final bool hasAcceptedOffer = data.containsKey('acceptedOfferId') && data['acceptedOfferId'] != null;
    
//     return FutureBuilder<DocumentSnapshot?>(
//       // If there's an accepted offer ID, get that offer document
//       future: hasAcceptedOffer 
//           ? _firestore.collection('offers').doc(data['acceptedOfferId']).get() 
//           : Future.value(null),
//       builder: (context, offerSnapshot) {
//         // Default values
//         bool isYourOfferAccepted = false;
        
//         // Check if your offer is the accepted one
//         if (offerSnapshot.connectionState == ConnectionState.done && 
//             offerSnapshot.hasData && 
//             offerSnapshot.data != null && 
//             offerSnapshot.data!.exists) {
          
//           final offerData = offerSnapshot.data!.data() as Map<String, dynamic>;
//           // Check if this offer belongs to current mechanic
//           isYourOfferAccepted = offerData['mechanicId'] == currentMechanicId;
//         }
        
//         // Now check if current mechanic has sent an offer (even if not accepted)
//         return FutureBuilder<QuerySnapshot>(
//           future: _firestore
//               .collection('offers')
//               .where('requestId', isEqualTo: request.id)
//               .where('mechanicId', isEqualTo: currentMechanicId)
//               .limit(1)
//               .get(),
//           builder: (context, offersSnapshot) {
//             bool hasSentOffer = false;
//             if (offersSnapshot.connectionState == ConnectionState.done && 
//                 offersSnapshot.hasData && 
//                 offersSnapshot.data!.docs.isNotEmpty) {
//               hasSentOffer = true;
//             }

//             return Card(
//               margin: const EdgeInsets.only(bottom: 10),
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 side: isYourOfferAccepted 
//                   ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
//                   : BorderSide.none,
//               ),
//               child: InkWell(
//                 onTap: onTap,
//                 borderRadius: BorderRadius.circular(10),
//                 child: Column(
//                   children: [
//                     // Banner for accepted offers or offer sent
//                     if (isYourOfferAccepted || hasSentOffer)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 6),
//                         decoration: BoxDecoration(
//                           color: isYourOfferAccepted 
//                             ? const Color(0xFF2E7D32) // Green for accepted offers
//                             : const Color(0xFFFFA000), // Amber for offers sent but not accepted
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                           ),
//                         ),
//                         child: Center(
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 isYourOfferAccepted 
//                                   ? Icons.check_circle
//                                   : Icons.send,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 isYourOfferAccepted 
//                                   ? 'Your offer was accepted'
//                                   : 'You sent an offer',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
                      
//                     // Main content
//                     Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Status indicator bar
//                           Container(
//                             width: 4,
//                             height: 75,
//                             decoration: BoxDecoration(
//                               color: isYourOfferAccepted 
//                                 ? const Color(0xFF2E7D32) // Green for accepted offer
//                                 : statusColor,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
                          
//                           const SizedBox(width: 12),
                          
//                           // Main content
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Car name with status pill
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         car,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
                                    
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                                       decoration: BoxDecoration(
//                                         color: statusColor.withAlpha(30),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         statusDisplay,
//                                         style: TextStyle(
//                                           color: statusColor,
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 11,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
                                
//                                 const SizedBox(height: 6),
                                
//                                 // Problem description
//                                 Text(
//                                   problemDescription,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
                                
//                                 const SizedBox(height: 8),
                                
//                                 // Date and action button
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     if (data['timestamp'] is Timestamp)
//                                       Text(
//                                         _formatDate(data['timestamp']),
//                                         style: const TextStyle(
//                                           color: Color(0xFF757575),
//                                           fontSize: 12,
//                                         ),
//                                       )
//                                     else
//                                       const SizedBox.shrink(),
                                      
//                                     TextButton.icon(
//                                       onPressed: onTap,
//                                       icon: Icon(
//                                         isYourOfferAccepted 
//                                           ? Icons.build_outlined
//                                           : Icons.visibility_outlined, 
//                                         size: 16
//                                       ),
//                                       label: Text(
//                                         isYourOfferAccepted ? 'Manage Job' : 'Details'
//                                       ),
//                                       style: TextButton.styleFrom(
//                                         foregroundColor: isYourOfferAccepted 
//                                           ? const Color(0xFF2E7D32)
//                                           : JobConstants.primaryColor,
//                                         minimumSize: Size.zero,
//                                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                         textStyle: const TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

//design 8
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class JobCardWidget extends StatelessWidget {
  final DocumentSnapshot request;
  final bool hasSentOffer;
  final bool isOfferAccepted;
  final VoidCallback onTap;

  const JobCardWidget({
    Key? key,
    required this.request,
    required this.onTap,
    this.hasSentOffer = false,
    this.isOfferAccepted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = request.data() as Map<String, dynamic>;
    
    // Job details
    final car = data['car'] ?? 'Unknown vehicle';
    final problemDescription = data['problemDescription'] ?? 'No description';
    final status = data['status'] ?? 'pending';
    final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
    final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isOfferAccepted 
          ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // Banner for accepted offers or offer sent
            if (isOfferAccepted || hasSentOffer)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isOfferAccepted 
                    ? const Color(0xFF2E7D32) // Green for accepted offers
                    : const Color(0xFFFFA000), // Amber for offers sent but not accepted
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOfferAccepted 
                          ? Icons.check_circle
                          : Icons.send,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOfferAccepted 
                          ? 'Your offer was accepted'
                          : 'You sent an offer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Main content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator bar
                  Container(
                    width: 4,
                    height: 75,
                    decoration: BoxDecoration(
                      color: isOfferAccepted 
                        ? const Color(0xFF2E7D32) 
                        : statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car name with status pill
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                car,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusDisplay,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Problem description
                        Text(
                          problemDescription,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Date and action button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (data['timestamp'] is Timestamp)
                              Text(
                                _formatDate(data['timestamp']),
                                style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 12,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                              
                            TextButton.icon(
                              onPressed: onTap,
                              icon: Icon(
                                isOfferAccepted 
                                  ? Icons.build_outlined
                                  : Icons.visibility_outlined, 
                                size: 16
                              ),
                              label: Text(
                                isOfferAccepted ? 'Manage Job' : 'Details'
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: isOfferAccepted 
                                  ? const Color(0xFF2E7D32)
                                  : JobConstants.primaryColor,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}