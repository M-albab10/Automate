// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/car_service.dart';
// import '../bars/navbar.dart';
// import '../bars/app_bar.dart';
// import 'add_car_screen.dart';

// class CarScreen extends StatefulWidget {
//   const CarScreen({super.key});

//   @override
//   State<CarScreen> createState() => _CarScreenState();
// }

// class _CarScreenState extends State<CarScreen> {
//   final CarService _carService = CarService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBarWidget(pageName: 'My Cars'),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _carService.getUserCars(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error here?: ${snapshot.error}'),
//             );
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           final cars = snapshot.data?.docs ?? [];

//           if (cars.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.directions_car_outlined,
//                     size: 64,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No cars added yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Tap the + button to add your first car',
//                     style: TextStyle(
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Swipe left to delete a car',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Icon(
//                         Icons.swipe_left_sharp,
//                         size: 24,
//                         color: Colors.grey[400],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: cars.length,
//                     itemBuilder: (context, index) {
//                       final carDoc = cars[index];
//                       final car = carDoc.data() as Map<String, dynamic>;
//                       final carId = carDoc.id;

//                       return Dismissible(
//                         key: Key(carId),
//                         background: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           child: const Icon(
//                             Icons.delete,
//                             color: Colors.white,
//                           ),
//                         ),
//                         direction: DismissDirection.endToStart,
//                         confirmDismiss: (DismissDirection direction) async {
//                           return await showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text('Delete Car'),
//                                 content: const Text(
//                                     'Are you sure you want to delete this car?'),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     child: const Text('Cancel'),
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(false),
//                                   ),
//                                   TextButton(
//                                     child: const Text(
//                                       'Delete',
//                                       style: TextStyle(color: Colors.red),
//                                     ),
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(true),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         onDismissed: (direction) async {
//                           try {
//                             await _carService.deleteCar(carId);
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Car removed'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error removing car: $e'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                         child: Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.only(bottom: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: InkWell(
//                             onTap: () {
//                               _showCarDetails(context, car);
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.all(10.0),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 100,
//                                     height: 80,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: Colors.grey[200],
//                                     ),
//                                     child: Image.asset(
//                                       'assets/images/car.png',
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           '${car['make']} ${car['model']} ${car['year']}',
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 5),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text('Color: ${car['color']}'),
//                                                 Text(
//                                                     'Engine: ${car['engineVolume']}L'),
//                                               ],
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                     'VIN: ${car['vin'].toString().substring(0, 6)}...'),
//                                                 Text(
//                                                     'Cylinders: ${car['cylinders']}'),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddCarScreen()),
//           );

//           if (result != null && mounted) {
//             try {
//               await _carService.addCar(result);
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Car added successfully')),
//                 );
//               }
//             } catch (e) {
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error adding car: $e')),
//                 );
//               }
//             }
//           }
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 0,
//         onTap: (index) {
//           // Handle navigation
//         },
//       ),
//     );
//   }

//   void _showCarDetails(BuildContext context, Map<String, dynamic> car) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 50,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               '${car['make']} ${car['model']} ${car['year']}',
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildDetailRow('Make', car['make'].toString()),
//             _buildDetailRow('Model', car['model'].toString()),
//             _buildDetailRow('Year', car['year'].toString()),
//             _buildDetailRow('Color', car['color'].toString()),
//             _buildDetailRow('VIN', car['vin'].toString()),
//             _buildDetailRow(
//                 'Engine Volume', '${car['engineVolume'].toString()}L'),
//             _buildDetailRow('Cylinders', car['cylinders'].toString()),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure to import this
import '../services/car_service.dart';
import '../bars/navbar.dart';
import '../bars/app_bar.dart';
import 'add_car_screen.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final CarService _carService = CarService();

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      appBar: const AppBarWidget(pageName: 'My Cars'),
      body: !isLoggedIn 
        ? _buildNotLoggedInView()
        : StreamBuilder<QuerySnapshot>(
            stream: _carService.getUserCars(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final cars = snapshot.data?.docs ?? [];

              if (cars.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cars added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first car',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Swipe left to delete a car',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.swipe_left_sharp,
                            size: 24,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          final carDoc = cars[index];
                          final car = carDoc.data() as Map<String, dynamic>;
                          final carId = carDoc.id;

                          return Dismissible(
                            key: Key(carId),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (DismissDirection direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Car'),
                                    content: const Text(
                                        'Are you sure you want to delete this car?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              try {
                                await _carService.deleteCar(carId);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Car removed'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error removing car: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showCarDetails(context, car);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey[200],
                                        ),
                                        child: Image.asset(
                                          'assets/images/car.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${car['make']} ${car['model']} ${car['year']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Color: ${car['color']}'),
                                                    Text(
                                                        'Engine: ${car['engineVolume']}L'),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'VIN: ${car['vin'].toString().substring(0, 6)}...'),
                                                    Text(
                                                        'Cylinders: ${car['cylinders']}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: isLoggedIn ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );

          if (result != null && mounted) {
            try {
              await _carService.addCar(result);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Car added successfully')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding car: $e')),
                );
              }
            }
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  // New method to show a message when user is not logged in
  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Please log in to view your cars',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login page
              // You might want to replace this with your actual login navigation
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  void _showCarDetails(BuildContext context, Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${car['make']} ${car['model']} ${car['year']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Make', car['make'].toString()),
            _buildDetailRow('Model', car['model'].toString()),
            _buildDetailRow('Year', car['year'].toString()),
            _buildDetailRow('Color', car['color'].toString()),
            _buildDetailRow('VIN', car['vin'].toString()),
            _buildDetailRow(
                'Engine Volume', '${car['engineVolume'].toString()}L'),
            _buildDetailRow('Cylinders', car['cylinders'].toString()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}