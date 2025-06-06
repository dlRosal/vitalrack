import 'food.dart';

class Consumption {
  final String id;
  final Food food;
  final int quantity;
  final DateTime consumedAt;

  Consumption({
    required this.id,
    required this.food,
    required this.quantity,
    required this.consumedAt,
  });

  factory Consumption.fromJson(Map<String, dynamic> json) {
    return Consumption(
      id: json['_id'] as String,
      food: Food.fromJson(json['food'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
    );
  }
}