class Address {
  final String id;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zip;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  // Convert Address to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }

  // Create Address from Firestore Document
  factory Address.fromMap(String id, Map<String, dynamic> map) {
    return Address(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
    );
  }

  // FEATURE: copyWith
  // Allows you to create a modified copy of an address (useful for editing)
  Address copyWith({
    String? id,
    String? name,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zip,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }

  // FEATURE: Display Helper
  String get fullAddress => "$street, $city, $state - $zip";

  @override
  String toString() {
    return "$name, $fullAddress (Ph: $phone)";
  }

  // FEATURE: Equality Checks
  // Essential for selecting addresses in a list (e.g., if (selectedAddress == address))
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Address &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.street == street &&
      other.city == city &&
      other.state == state &&
      other.zip == zip;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      street.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zip.hashCode;
  }
}