import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class SubmitOfferScreen extends StatefulWidget {
  final String requestId;
  final String mechanicId;
  final bool isEditingExistingOffer;
  final String? existingOfferId;
  final Map<String, dynamic>? existingOfferData; // Holds existing data

  const SubmitOfferScreen({
    Key? key,
    required this.requestId,
    required this.mechanicId,
    required this.isEditingExistingOffer,
    this.existingOfferId,
    this.existingOfferData,
  }) : super(key: key);

  @override
  _SubmitOfferScreenState createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final _repairsNeededController = TextEditingController();
  String _serviceType = 'Parts with Labor';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing an existing offer, prefill the form with its data
    if (widget.isEditingExistingOffer && widget.existingOfferData != null) {
      _priceController.text =
          widget.existingOfferData?['price'].toString() ?? '';
      _descriptionController.text =
          widget.existingOfferData?['description'] ?? '';
      _estimatedTimeController.text =
          widget.existingOfferData?['estimatedTime'] ?? '';
      _repairsNeededController.text =
          widget.existingOfferData?['repairsNeeded'] ?? '';
      _serviceType =
          widget.existingOfferData?['serviceType'] ?? 'Parts with Labor';
    }
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      if (widget.isEditingExistingOffer) {
        // Update existing offer
        await firestore
            .collection('maintenance_requests')
            .doc(widget.requestId)
            .collection('offers')
            .doc(widget.existingOfferId)
            .update({
          'serviceType': _serviceType,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'estimatedTime': _estimatedTimeController.text,
          'repairsNeeded': _repairsNeededController.text,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Submit new offer
        await firestore
            .collection('maintenance_requests')
            .doc(widget.requestId)
            .collection('offers')
            .add({
          'requestId': widget.requestId,
          'mechanicId': widget.mechanicId,
          'serviceType': _serviceType,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'estimatedTime': _estimatedTimeController.text,
          'repairsNeeded': _repairsNeededController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Pending',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEditingExistingOffer
                  ? "Offer updated successfully!"
                  : "Offer submitted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.isEditingExistingOffer ? "Edit Offer" : "Submit Offer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Service Type:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildServiceTypeRadios(),
              const SizedBox(height: 16),
              _buildTextField(_priceController, "Estimated Cost (SAR)",
                  Icons.attach_money, true),
              const SizedBox(height: 16),
              _buildTextField(_estimatedTimeController,
                  "Estimated Time to Finish", Icons.access_time, false),
              const SizedBox(height: 16),
              _buildTextField(_repairsNeededController, "Repairs Needed",
                  Icons.build, false),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, "Additional Details",
                  Icons.description, false),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isEditingExistingOffer
                              ? Colors.blue
                              : Colors.green,
                        ),
                        child: Text(
                            widget.isEditingExistingOffer
                                ? "Edit Offer"
                                : "Submit Offer",
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeRadios() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Parts with Labor'),
          value: 'Parts with Labor',
          groupValue: _serviceType,
          onChanged: (value) => setState(() => _serviceType = value!),
        ),
        RadioListTile<String>(
          title: const Text('Labor Only'),
          value: 'Labor Only',
          groupValue: _serviceType,
          onChanged: (value) => setState(() => _serviceType = value!),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isNumeric) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "This field is required";
        return null;
      },
    );
  }
}
