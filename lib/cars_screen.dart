import 'package:flutter/material.dart';
import 'navbar.dart';
import 'app_bar.dart';

class CarScreen extends StatelessWidget {
  const CarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of cars (replace with dynamic data)
    final List<Map<String, String>> cars = [
      {
        'name': 'Centra 2018 Grey',
        'make': 'Toyota',
        'model': 'Corolla',
        'year': '2023',
        'color': 'Blue'
      },
      {
        'name': 'Centra 2018 Grey',
        'make': 'Toyota',
        'model': 'Corolla',
        'year': '2023',
        'color': 'Blue'
      },
      {
        'name': 'Centra 2018',
        'make': 'Toyota',
        'model': 'Corolla',
        'year': '2023',
        'color': 'Blue'
      },
    ];

    return Scaffold(
      appBar: const AppBarWidget(pageName: 'My cars'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    // Car image
                    Image.asset(
                      'assets/images/car.png', // Replace with actual car image path
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    // Car details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Make: ${car['make']}'),
                                  Text('Model: ${car['model']}'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Year: ${car['year']}'),
                                  Text('Color: ${car['color']}'),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new car
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation tap
        },
      ),
    );
  }
}
