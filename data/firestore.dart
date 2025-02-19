import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gym_application_1/models/exercise.dart';
import 'package:flutter_gym_application_1/models/workout.dart';

class FirestoreDB{
  // Get main collection
  final CollectionReference workouts = 
    FirebaseFirestore.instance.collection('workouts');
    
  //Add workout
  Future<void> addWorkout(String workoutName)  {
    return  workouts.add(
      {
       'name':workoutName,
       'timestamp': Timestamp.now(), 
      }
    );
  }

  // Add Exercise
  Future<void> addExercise(String workoutId,Exercise exercise) async {
    await workouts 
        .doc(workoutId)         
        .collection("exercises")
        .add(exercise.toFirestore());
}

  // Read Wokrout
 Stream<List<Workout>> getWorkouts(DateTime date) {
    Timestamp startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    return workouts
        .where("timestamp", isGreaterThanOrEqualTo: startOfDay) // Start of day
        .where("timestamp", isLessThanOrEqualTo: endOfDay) // End of day
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
        });
}
  
  //Read Exercise
 Stream<List<Exercise>> getExercises(String docID) {
    return workouts
        .doc(docID)
        .collection('exercises')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromFirestore(doc.data(), doc.id)) // Pass Firestore `doc.id`
            .toList());
  }


  // Update Workout
  Future<void> updateWorkout(String docID, String workoutName) {
    return workouts.doc(docID).update(
      {
        'name': workoutName,
        'timestamp': Timestamp.now(),
      }
    );
  }


  // Update Exercise
Future<void> updateExercise(String workoutId, String exerciseId, Exercise updatedExercise) {
    return workouts
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId) // Use Firestore ID
        .update(updatedExercise.toFirestore());
  }
    
    Future<void> toggleExerciseCompletion(String docID, String exerciseId, bool isCompleted) {
    return workouts
        .doc(docID)
        .collection('exercises')
        .doc(exerciseId) // Use Firestore ID
        .update({'isCompleted': isCompleted});
  }

  //Delete workout and exercises
  Future<void> deleteWorkout(String docID)  async{
    try {

      var subcollectionRef = workouts.doc(docID).collection('exercises');
      var querySnapshot = await subcollectionRef.get();
      if (querySnapshot.docs.isEmpty) {
        return workouts.doc(docID).delete();
      }
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }catch (e) {
      print(" Error deleting subcollection: $e");
    }
  }

// Delete single exercise
  Future<void> deleteExercise(String workoutId, String exerciseId) {
    return workouts
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId) 
        .delete();
  }

}

