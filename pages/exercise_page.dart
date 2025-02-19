
import 'package:flutter/material.dart';
import 'package:flutter_gym_application_1/data/firestore.dart';
import 'package:flutter_gym_application_1/models/exercise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class ExercisePage extends StatefulWidget {
  final String workoutName;

  const ExercisePage({super.key,required this.workoutName});

  @override
  State<ExercisePage>  createState() => _ExercisePageState();
}


class _ExercisePageState extends State<ExercisePage> {
  final FirestoreDB firestoreService = FirestoreDB();

  void createExercise() {
    TextEditingController nameController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController repsController = TextEditingController();
    TextEditingController setsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Exercise Name")),
              TextField(controller: weightController, decoration: InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              TextField(controller: repsController, decoration: InputDecoration(labelText: "Reps"), keyboardType: TextInputType.number),
              TextField(controller: setsController, decoration: InputDecoration(labelText: "Sets"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                String weight = weightController.text.trim();
                String reps = repsController.text.trim();
                String sets = setsController.text.trim();

                if (name.isEmpty || weight.isEmpty || reps.isEmpty || sets.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(" Please fill all fields!")),
                  );
                  return; 
                }

                // Create Exercise Object
                Exercise newExercise = Exercise(
                  id: '', // Firestore will generate this
                  name: name,
                  weight: weight,
                  reps: reps,
                  sets:sets,
                  isCompleted: false,
                );

                // Save to Firestore
                firestoreService.addExercise(widget.workoutName, newExercise);

                // Close dialog
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
  
  
  void _editExerciseDialog(Exercise exercise) {
    TextEditingController nameController = TextEditingController(text: exercise.name);
    TextEditingController weightController = TextEditingController(text: exercise.weight.toString());
    TextEditingController repsController = TextEditingController(text: exercise.reps.toString());
    TextEditingController setsController = TextEditingController(text: exercise.sets.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Exercise Name")),
              TextField(controller: weightController, decoration: InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              TextField(controller: repsController, decoration: InputDecoration(labelText: "Reps"), keyboardType: TextInputType.number),
              TextField(controller: setsController, decoration: InputDecoration(labelText: "Sets"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if(nameController.text.isNotEmpty & weightController.text.isNotEmpty & repsController.text.isNotEmpty & setsController.text.isNotEmpty) {
                  Exercise updatedExercise = Exercise(
                    id: exercise.id, 
                    name: nameController.text,
                    weight:weightController.text,
                    reps: repsController.text,
                    sets: setsController.text,
                    isCompleted: exercise.isCompleted,
                  );

                  firestoreService.updateExercise(widget.workoutName, exercise.id, updatedExercise);
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(String exerciseId) {
    firestoreService.deleteExercise(widget.workoutName, exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 36, 54),
      appBar: AppBar(title: Text("Exercises")),
      floatingActionButton: FloatingActionButton(
          onPressed: createExercise,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: firestoreService.getExercises(widget.workoutName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("⚠️ No exercises found"));
          }

          List<Exercise> exercises = snapshot.data!;

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              Exercise exercise = exercises[index];

              return Slidable(
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _deleteExercise(exercise.id),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: exercise.isCompleted ? Colors.green[100] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
                    ],
                  ),
                child: ListTile(
                  title: Text(
                    exercise.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                    children: [
                      _buildChip("${exercise.weight}kg", Colors.blue),
                      SizedBox(width: 5),
                      _buildChip("${exercise.reps} reps", Colors.green),
                      SizedBox(width: 5),
                      _buildChip("${exercise.sets} sets", Colors.orange),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _editExerciseDialog(exercise),
                      ),
                      AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child)
                      ),
                      Checkbox(
                        value: exercise.isCompleted,
                        onChanged: (bool? value) {
                          firestoreService.toggleExerciseCompletion(widget.workoutName, exercise.id, value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
