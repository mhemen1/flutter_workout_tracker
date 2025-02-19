import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final String name;
  final Timestamp timestamp;

  Workout({required this.id, required this.name, required this.timestamp});

  /// Convert Firestore Document to Workout Object
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data["name"] ?? "No Name",
      timestamp: data["timestamp"] ?? Timestamp.now(),
    );
  }
}