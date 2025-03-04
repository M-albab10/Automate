import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bars/app_bar.dart';
import '../bars/navbar.dart';
import 'screens/mechanic_profile_viewer.dart';
import 'models/offer.dart';
import 'services/offer_service.dart';
import 'widgets/request_details_card.dart';
import 'widgets/offers_list.dart';

class OffersScreen extends StatefulWidget {
  final String requestId;
  final String carModel;
  final String problemDescription;

  const OffersScreen({
    super.key,
    required this.requestId,
    required this.carModel,
    required this.problemDescription,
  });

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final OffersService _offersService = OffersService();

  @override
  void initState() {
    super.initState();
    _offersService.loadOffers(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        pageName: 'Offers for ${widget.carModel}',
        implyLeading: true,
      ),
      body: Column(
        children: [
          RequestDetailsCard(
            carModel: widget.carModel,
            problemDescription: widget.problemDescription,
            requestId: widget.requestId,
          ),
          Expanded(
            child: OffersList(
              requestId: widget.requestId,
              onAcceptOffer: _offersService.acceptOffer,
              onRejectOffer: _offersService.rejectOffer,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}
