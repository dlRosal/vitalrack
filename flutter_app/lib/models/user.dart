// flutter_app/lib/models/user.dart
class User {
  final String id;
  final String email;
  final String? name;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  // Si guardas “username” en tu backend, cámbialo aquí; 
  // yo usaré “name” como nombre de usuario.

  User({
    required this.id,
    required this.email,
    this.name,
    this.gender,
    this.age,
    this.height,
    this.weight,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}
