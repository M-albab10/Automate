class Offer {
  final String id;
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final String mechanicEmail;
  final double price;
  final String description;
  final String serviceType;
  final String status;
  final String estimatedTime;
  final String repairsNeeded;

  Offer({
    required this.id,
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicEmail,
    required this.price,
    required this.description,
    required this.serviceType,
    required this.status,
    required this.estimatedTime,
    required this.repairsNeeded,
  });

  factory Offer.fromMap(String id, Map<String, dynamic> data) {
    return Offer(
      id: id,
      requestId: data['requestId'] ?? '',
      mechanicId: data['mechanicId'] ?? '',
      mechanicName: data['mechanicName'] ?? '',
      mechanicEmail: data['mechanicEmail'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? 'No description provided',
      serviceType: data['serviceType'] ?? 'Not specified',
      status: data['status'] ?? 'Pending',
      estimatedTime: data['estimatedTime'] ?? 'Not specified',
      repairsNeeded: data['repairsNeeded'] ?? 'Not specified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'mechanicEmail': mechanicEmail,
      'price': price,
      'description': description,
      'serviceType': serviceType,
      'status': status,
      'estimatedTime': estimatedTime,
      'repairsNeeded': repairsNeeded,
    };
  }
}