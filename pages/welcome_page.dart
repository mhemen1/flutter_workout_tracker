import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WelcomePage extends StatefulWidget {
   const WelcomePage({super.key});
   @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  DateTime? selectedDate;

  /// Function to Show Date Picker
  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      Navigator.pushNamed(context,'/workouts',arguments: pickedDate);
    }
  }

  /// Navigate to Workouts Page with Today's Date
  void _goToTodayWorkouts() {
    DateTime today = DateTime.now();
    Navigator.pushNamed(
      context,
      '/workouts',
      arguments: today,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 36, 54),
       appBar: AppBar(title: Center(child: const Text('Workout Tracker'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/fitness.png', 
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: _goToTodayWorkouts,
              child: Text("Today"),
            ),

            SizedBox(height: 20),

            if (selectedDate != null)
              Text(
                "Selected Date: ${DateFormat('MMM dd, yyyy').format(selectedDate!)}",
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(121, 172, 170, 170)),
              ),

            SizedBox(height: 10),

            
            TextButton(
              onPressed: () => _pickDate(context),
              child: Text(
                "View Before",
                style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
