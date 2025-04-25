// lib/models/session.dart
class Entry {
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;

  Entry({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      exerciseName: json['exerciseName'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}

class Session {
  final String id;
  final String routineId;
  final DateTime date;
  final List<Entry> entries;
  final int duration;
  final String? notes;

  Session({
    required this.id,
    required this.routineId,
    required this.date,
    required this.entries,
    required this.duration,
    this.notes,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'] as String,
      routineId: json['routineId'] as String,
      date: DateTime.parse(json['date'] as String),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => Entry.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'routineId': routineId,
      'date': date.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'duration': duration,
      if (notes != null) 'notes': notes,
    };
  }
}
