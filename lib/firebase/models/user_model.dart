class UserModel {
  String name;
  String email;
  String phone;
  String address;
  String city;
  String zipCode;
  String apartmentNumber;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.apartmentNumber,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'apartmentNumber': apartmentNumber,
    };
  }
}