class Exercise {
  final String id; 
  final String name;
  final String weight;
  final String reps;
  final String sets;
  bool isCompleted;

  Exercise({
    required this.id, 
    required this.name,
    required this.weight,
    required this.reps,
    required this.sets,
    this.isCompleted=false,

  });
  // Convert Exercise object to a Firestore-friendly Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'isCompleted':isCompleted
    };
  }

  // Create Exercise object from Firestore document
   factory Exercise.fromFirestore(Map<String, dynamic> data, String id) {
    return Exercise(
      id: id, // Firestore ID
      name: data['name'] ?? '',
      weight: data['weight'] ?? 0,
      reps: data['reps'] ?? 0,
      sets: data['sets'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}