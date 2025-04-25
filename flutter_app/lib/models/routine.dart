// lib/models/routine.dart
class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int restSec;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSec,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSec: json['restSec'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSec': restSec,
    };
  }
}

class Routine {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['_id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}