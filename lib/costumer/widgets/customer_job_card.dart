// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:automate/mechanic/utils/constants.dart';

// class CustomerJobCard extends StatelessWidget {
//   final DocumentSnapshot request;
//   final DocumentSnapshot? acceptedOffer;
//   final VoidCallback onTap;

//   const CustomerJobCard({
//     Key? key,
//     required this.request,
//     this.acceptedOffer,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final requestData = request.data() as Map<String, dynamic>;
//     final offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
//     // Job details
//     final car = requestData['car'] ?? 'Unknown vehicle';
//     final status = requestData['status'] ?? 'pending';
    
//     // Correctly access the price from the offer
//     final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
    
//     // Status display configuration
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: statusColor.withAlpha(150), width: 1.5),
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
//                       const CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.car_repair, color: Colors.white),
//                       ),
//                       const SizedBox(width: 12),
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
//                           price != 'N/A' ? '\$$price' : 'N/A',
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
                  
//                   // Status tracking timeline
//                   _buildStatusTimeline(context, status),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
//     final statuses = [
//       'pending',
//       'parts ordered', 
//       'in progress', 
//       'ready for pickup'
//     ];
    
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Repair Progress:',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: List.generate(statuses.length, (index) {
//               // Determine if this status is current, completed, or upcoming
//               final status = statuses[index];
//               final statusIndex = statuses.indexOf(currentStatus);
//               final isCompleted = index <= statusIndex;
//               final isCurrent = status == currentStatus;
              
//               // Get color based on status
//               final color = isCompleted 
//                   ? JobConstants.statusColors[status] ?? Colors.grey
//                   : Colors.grey[300]!;
              
//               // Status circle indicator
//               final statusCircle = Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: isCompleted ? color : Colors.white,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: color, width: 2),
//                 ),
//                 child: isCurrent 
//                     ? Center(child: _getStatusIcon(status)) 
//                     : isCompleted 
//                         ? const Icon(Icons.check, color: Colors.white, size: 16)
//                         : null,
//               );
              
//               // Line connector (except for last item)
//               final connector = index < statuses.length - 1 
//                   ? Expanded(
//                       child: Container(
//                         height: 3,
//                         color: index < statusIndex 
//                             ? color
//                             : Colors.grey[300],
//                       ),
//                     )
//                   : const SizedBox();
              
//               return Expanded(
//                 child: Column(
//                   children: [
//                     statusCircle,
//                     const SizedBox(height: 4),
//                     Text(
//                       _getShortStatusName(status),
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: isCurrent ? Colors.black : Colors.grey[600],
//                         fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (index < statuses.length - 1)
//                       Row(
//                         children: [
//                           const SizedBox(width: 12),
//                           connector,
//                           const SizedBox(width: 12),
//                         ],
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getShortStatusName(String status) {
//     switch (status) {
//       case 'pending':
//         return 'Pending';
//       case 'parts ordered':
//         return 'Parts';
//       case 'in progress':
//         return 'In Progress';
//       case 'ready for pickup':
//         return 'Ready';
//       default:
//         return status;
//     }
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
//     return Icon(iconData, color: Colors.white, size: 16);
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
// import 'package:intl/intl.dart';
// import 'package:automate/mechanic/utils/constants.dart';

// class CustomerJobCard extends StatelessWidget {
//   final DocumentSnapshot request;
//   final DocumentSnapshot? acceptedOffer;
//   final VoidCallback onTap;
//   final int offersCount; // Added parameter for offers count

//   const CustomerJobCard({
//     Key? key,
//     required this.request,
//     this.acceptedOffer,
//     required this.onTap,
//     this.offersCount = 0, // Default to 0 if not provided
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final requestData = request.data() as Map<String, dynamic>;
//     final offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
//     // Job details
//     final car = requestData['car'] ?? 'Unknown vehicle';
//     final status = requestData['status'] ?? 'pending';
//     final description = requestData['description'] ?? 'No description provided';
//     final createdAt = requestData['createdAt'];
    
//     // Check if this request has an accepted offer
//     final bool hasAcceptedOffer = acceptedOffer != null;
    
//     // Correctly access the price from the offer
//     final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
    
//     // Status display configuration
//     final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
//     final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: statusColor.withAlpha(150), width: 1.5),
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
//                       const CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.car_repair, color: Colors.white),
//                       ),
//                       const SizedBox(width: 12),
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
//                             if (hasAcceptedOffer && offerData['acceptedAt'] != null)
//                               Text(
//                                 'Accepted: ${_formatDate(offerData['acceptedAt'])}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             if (!hasAcceptedOffer && createdAt != null)
//                               Text(
//                                 'Created: ${_formatDate(createdAt)}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       // Price container or Offers count for unaccepted requests
//                       hasAcceptedOffer
//                       ? Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.green[50],
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: Colors.green[200]!),
//                           ),
//                           child: Text(
//                             price != 'N/A' ? '\$$price' : 'N/A',
//                             style: TextStyle(
//                               color: Colors.green[700],
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         )
//                       : Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: Colors.blue[200]!),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.handyman, size: 14, color: Colors.blue[700]),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '$offersCount ${offersCount == 1 ? 'offer' : 'offers'}',
//                                 style: TextStyle(
//                                   color: Colors.blue[700],
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 10),
                  
//                   // Description for unaccepted requests (truncated)
//                   if (!hasAcceptedOffer)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Issue Description:',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             description,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey[800],
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
                  
//                   // Status tracking timeline only for accepted offers
//                   if (hasAcceptedOffer) ...[
//                     const SizedBox(height: 12),
//                     _buildStatusTimeline(context, status),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
//     final statuses = [
//       'pending',
//       'parts ordered', 
//       'in progress', 
//       'ready for pickup'
//     ];
    
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Repair Progress:',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: List.generate(statuses.length, (index) {
//               // Determine if this status is current, completed, or upcoming
//               final status = statuses[index];
//               final statusIndex = statuses.indexOf(currentStatus);
//               final isCompleted = index <= statusIndex;
//               final isCurrent = status == currentStatus;
              
//               // Get color based on status
//               final color = isCompleted 
//                   ? JobConstants.statusColors[status] ?? Colors.grey
//                   : Colors.grey[300]!;
              
//               // Status circle indicator
//               final statusCircle = Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: isCompleted ? color : Colors.white,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: color, width: 2),
//                 ),
//                 child: isCurrent 
//                     ? Center(child: _getStatusIcon(status)) 
//                     : isCompleted 
//                         ? const Icon(Icons.check, color: Colors.white, size: 16)
//                         : null,
//               );
              
//               // Line connector (except for last item)
//               final connector = index < statuses.length - 1 
//                   ? Expanded(
//                       child: Container(
//                         height: 3,
//                         // Use the same color as the current status circle for connector line
//                         color: index < statusIndex 
//                             ? color // Use the current status circle color
//                             : Colors.grey[300],
//                       ),
//                     )
//                   : const SizedBox();
              
//               return Expanded(
//                 child: Column(
//                   children: [
//                     statusCircle,
//                     const SizedBox(height: 4),
//                     Text(
//                       _getShortStatusName(status),
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: isCurrent ? Colors.black : Colors.grey[600],
//                         fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (index < statuses.length - 1)
//                       Row(
//                         children: [
//                           const SizedBox(width: 12),
//                           connector,
//                           const SizedBox(width: 12),
//                         ],
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getShortStatusName(String status) {
//     switch (status) {
//       case 'pending':
//         return 'Pending';
//       case 'parts ordered':
//         return 'Parts';
//       case 'in progress':
//         return 'In Progress';
//       case 'ready for pickup':
//         return 'Ready';
//       default:
//         return status;
//     }
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
//     return Icon(iconData, color: Colors.white, size: 16);
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
import 'package:intl/intl.dart';
import 'package:automate/mechanic/utils/constants.dart';

class CustomerJobCard extends StatelessWidget {
  final DocumentSnapshot request;
  final DocumentSnapshot? acceptedOffer;
  final VoidCallback onTap;
  final int offersCount; // Parameter for offers count

  const CustomerJobCard({
    Key? key,
    required this.request,
    this.acceptedOffer,
    required this.onTap,
    this.offersCount = 0, // Default to 0 if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requestData = request.data() as Map<String, dynamic>;
    final offerData = acceptedOffer?.data() as Map<String, dynamic>? ?? {};
    
    // Job details
    final car = requestData['car'] ?? 'Unknown vehicle';
    final status = requestData['status'] ?? 'pending';
    // Get the problem description from the correct field (might be 'description' or 'problemDescription')
    final problemDescription = requestData['problemDescription'] ?? 
                               requestData['description'] ?? 
                               'No description provided';
    final createdAt = requestData['createdAt'];
    
    // Check if this request has an accepted offer
    final bool hasAcceptedOffer = acceptedOffer != null;
    
    // Correctly access the price from the offer
    final price = offerData.containsKey('price') ? offerData['price'].toString() : 'N/A';
    
    // Status display configuration
    final statusColor = JobConstants.statusColors[status] ?? Colors.grey;
    final statusDisplay = JobConstants.filterDisplayNames[status] ?? status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: statusColor.withAlpha(150), width: 1.5),
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
                  _getStatusIcon(status),
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
              
          // Main content
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
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.car_repair, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
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
                            if (hasAcceptedOffer && offerData['acceptedAt'] != null)
                              Text(
                                'Accepted: ${_formatDate(offerData['acceptedAt'])}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            if (!hasAcceptedOffer && createdAt != null)
                              Text(
                                'Created: ${_formatDate(createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price container or Offers count for unaccepted requests
                      hasAcceptedOffer
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            price != 'N/A' ? '\$$price' : 'N/A',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.handyman, size: 14, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                '$offersCount ${offersCount == 1 ? 'offer' : 'offers'}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Issue description - only display for cards WITHOUT accepted offers
                  if (!hasAcceptedOffer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Description:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            problemDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  
                  // Status tracking timeline only for accepted offers
                  if (hasAcceptedOffer) ...[
                    const SizedBox(height: 12),
                    _buildStatusTimeline(context, status),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
    final statuses = [
      'pending',
      'parts ordered', 
      'in progress', 
      'ready for pickup'
    ];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair Progress:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(statuses.length, (index) {
              // Determine if this status is current, completed, or upcoming
              final status = statuses[index];
              final statusIndex = statuses.indexOf(currentStatus);
              final isCompleted = index <= statusIndex;
              final isCurrent = status == currentStatus;
              
              // Get color based on status
              final color = isCompleted 
                  ? JobConstants.statusColors[status] ?? Colors.grey
                  : Colors.grey[300]!;
              
              // Status circle indicator
              final statusCircle = Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCurrent 
                    ? Center(child: _getStatusIcon(status)) 
                    : isCompleted 
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              );
              
              // Line connector (except for last item)
              final connector = index < statuses.length - 1 
                  ? Expanded(
                      child: Container(
                        height: 3,
                        // Use the same color as the current status circle for connector line
                        color: index < statusIndex 
                            ? color // Use the current status circle color
                            : Colors.grey[300],
                      ),
                    )
                  : const SizedBox();
              
              return Expanded(
                child: Column(
                  children: [
                    statusCircle,
                    const SizedBox(height: 4),
                    Text(
                      _getShortStatusName(status),
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent ? Colors.black : Colors.grey[600],
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (index < statuses.length - 1)
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          connector,
                          const SizedBox(width: 12),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getShortStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'parts ordered':
        return 'Parts';
      case 'in progress':
        return 'In Progress';
      case 'ready for pickup':
        return 'Ready';
      default:
        return status;
    }
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
      default:
        iconData = Icons.info;
    }
    return Icon(iconData, color: Colors.white, size: 16);
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