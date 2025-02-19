import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_gym_application_1/data/firestore.dart";
import "package:flutter_gym_application_1/models/workout.dart";
import "package:flutter_gym_application_1/pages/exercise_page.dart";
import "package:intl/intl.dart";
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';


class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key,required this.selectedDate});
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  final newWorkoutNameController = TextEditingController();
  final FirestoreDB _firestoreDB = FirestoreDB();


  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dateTime);  
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> SnackBarEmptyWarn() {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" Please fill all fields!")));
  }
  void createNewWorkout(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create new workout"),
        content: TextField(
          controller: newWorkoutNameController,
        ),
        actions: [
          //save
          ElevatedButton(onPressed: save,
          child: Text("Save"),
          ),

          // cancel
          MaterialButton(onPressed: cancel,
          child: Text("Cancel"),
          )
        ],
      ),
      );

  }


  //go to workout page
  void goToWorkoutPage(String workoutName) {
    Navigator.push(
      context,MaterialPageRoute(
      builder: (context) => ExercisePage(
      workoutName: workoutName,
      ),
    ));

}

  void save() {
    //get workout name from text controller
    String newWorkoutName = newWorkoutNameController.text;
    // add workout to workoutdata list
    if (newWorkoutName.isEmpty) { 
        SnackBarEmptyWarn();
        return; 
      }
    _firestoreDB.addWorkout(newWorkoutName);
    // pop dialog
    Navigator.pop(context);
    clearController();
  }

  void cancel() {
    Navigator.pop(context);
    clearController();
  }

  // clear controller
  void clearController() {
    newWorkoutNameController.clear();
  }
   


  void editWorkout(BuildContext context, Workout workout) {
    TextEditingController nameController = TextEditingController(text: workout.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Workout"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "New Workout Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  _firestoreDB.updateWorkout(workout.id, newName);
                }
                else {
                  SnackBarEmptyWarn();
                  return; 
                }

                Navigator.pop(context); 
              },
              child: Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        backgroundColor: const Color.fromARGB(255, 38, 36, 54),
        appBar: AppBar(title: const Text('Workout Tracker'),
        ) ,
        floatingActionButton: FloatingActionButton(
          onPressed: createNewWorkout,
          child: const Icon(Icons.add),
          ),
        body: StreamBuilder<List<Workout>>(
        stream: _firestoreDB.getWorkouts(widget.selectedDate),
  
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); 
          }

          if (snapshot.hasError) {
            return Center(child: Text(" Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(" No workouts found"));
          }

          List<Workout> workouts = snapshot.data!;

           return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              Workout workout = workouts[index];

               return Slidable(
                key: Key(workout.id),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _firestoreDB.deleteWorkout(workout.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${workout.name} deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                  child: Card(
                    elevation: 2, // Slight shadow effect
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(workout.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(formatTimestamp(workout.timestamp)),
                      leading: Icon(Icons.fitness_center, color: Colors.blue),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              editWorkout(context, workout); 
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                            onPressed: () {
                              goToWorkoutPage(workout.id);
                            },
                          ),
                        ],
                      ),
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
}
