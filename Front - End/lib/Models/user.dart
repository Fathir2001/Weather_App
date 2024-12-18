class User {
  final String? id;
  final String name;
  final String email;
  final String address;
  final String phoneNumber;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }
}