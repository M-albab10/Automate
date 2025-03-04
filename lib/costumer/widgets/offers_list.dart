import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';
import 'offer_card.dart';

class OffersList extends StatelessWidget {
  final String requestId;
  final Function(BuildContext, String, String) onAcceptOffer;
  final Function(BuildContext, String) onRejectOffer;

  const OffersList({
    Key? key,
    required this.requestId,
    required this.onAcceptOffer,
    required this.onRejectOffer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OffersService offersService = OffersService();

    return StreamBuilder(
      stream: offersService.getOffersStream(requestId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoOffersView();
        }

        var offers = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            var offer = offers[index];
            var offerData = offer.data() as Map<String, dynamic>;
            String mechanicId = offerData['mechanicId'] ?? '';
            String mechanicEmail = offerData['mechanicEmail'] ?? '';

            return FutureBuilder<String>(
              future: offersService.getMechanicName(mechanicId, mechanicEmail),
              builder: (context, mechanicSnapshot) {
                if (mechanicSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                String mechanicName = mechanicSnapshot.data ??
                    (offerData['mechanicName'] ?? 'Unknown Mechanic');

                Offer offerModel = Offer.fromMap(offer.id, {
                  ...offerData,
                  'mechanicName': mechanicName,
                });

                return OfferCard(
                  offer: offerModel,
                  onAccept: () => onAcceptOffer(context, offer.id, requestId),
                  onReject: () => onRejectOffer(context, offer.id),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNoOffersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No offers received yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for mechanic offers',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
