class MechanicData {
  final String name;
  final String phone;
  final String email;
  final String workshop;
  final String location;
  final List<String> specialties;
  final String description;

  MechanicData({
    required this.name,
    required this.phone,
    required this.email,
    required this.workshop,
    required this.location,
    required this.specialties,
    required this.description,
  });

  factory MechanicData.fromMap(Map<String, dynamic> map, {required String defaultName}) {
    // Get best name option
    final name = map['fullName'] ??
        map['displayName'] ??
        map['name'] ??
        map['userName'] ??
        defaultName;

    // Get other fields with fallbacks
    final phone = map['phoneNumber'] ?? map['phone'] ?? 'Not available';
    final email = map['email'] ?? 'Not available';
    final workshop = map['workshopName'] ?? map['workshop'] ?? 'Not available';
    final location = map['location'] ?? map['address'] ?? map['city'] ?? 'Not available';
    
    // Handle specialties which could be a list or a string
    List<String> specialtiesList = [];
    if (map['specialties'] != null) {
      if (map['specialties'] is List) {
        specialtiesList = (map['specialties'] as List).map((e) => e.toString()).toList();
      } else if (map['specialties'] is String) {
        specialtiesList = [map['specialties']];
      }
    }

    return MechanicData(
      name: name,
      phone: phone,
      email: email,
      workshop: workshop,
      location: location,
      specialties: specialtiesList,
      description: map['description'] ?? '',
    );
  }
}
