import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/decorations.dart';

class RatingSection extends StatelessWidget {
  final String mechanicId;
  final double userRating;
  final Function(double) onRatingChanged;
  final TextEditingController reviewController;
  final VoidCallback submitRating;
  final FirebaseFirestore firestore;

  const RatingSection({
    Key? key,
    required this.mechanicId,
    required this.userRating,
    required this.onRatingChanged,
    required this.reviewController,
    required this.submitRating,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ratings & Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildExistingRatings(),
          const Divider(height: 32),
          const Text(
            'Add Your Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < userRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  onRatingChanged(index + 1);
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review here...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 208, 63, 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit Rating',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingRatings() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('Mechanic')
          .doc(mechanicId)
          .collection('ratings')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No ratings yet. Be the first to rate!'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            var ratingData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            double rating = (ratingData['rating'] ?? 0).toDouble();
            String review = ratingData['review'] ?? '';
            String userEmail = ratingData['userEmail'] ?? 'Anonymous';
            Timestamp? timestamp = ratingData['timestamp'] as Timestamp?;
            String date = timestamp != null
                ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                : 'Unknown date';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  ...List.generate(
                      5,
                      (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          )),
                  const SizedBox(width: 8),
                  Text(date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By: $userEmail',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
                  if (review.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(review),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}