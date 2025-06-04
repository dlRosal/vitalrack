// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String username;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.gender,
    this.age,
    this.height,
    this.weight,
  });

  /// Deserializa desde el JSON que devuelve GET /auth/me
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: (json['email'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      gender: json['gender'] as String?,
      age: json['age'] != null ? (json['age'] as num).toInt() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }

  /// Para enviar al backend en el PUT, convertimos a JSON
  Map<String, dynamic> toJson() {
    return {
      if (username.isNotEmpty) 'username': username,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
    };
  }
}
