import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugarmate_thesis/Controller/sugar_controller.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';
import 'package:sugarmate_thesis/View/add_sugar_view.dart';
import 'package:sugarmate_thesis/auth/auth_service.dart';
import 'package:sugarmate_thesis/auth/login_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<SugarIntake>> _events = {};
  final SugarController _sugarController = SugarController();
  StreamSubscription? _sugarSubscription;

  void _listenToSugarData() {
    _sugarSubscription = _sugarController.fetchSugarIntake().listen((data) {
      setState(() {
        _events = data;
      });
    });
  }

  List<SugarIntake> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _listenToSugarData();
  }

  @override
  void dispose() {
    _sugarSubscription?.cancel();
    super.dispose();
  }

  Future<void> deleteSugarIntake(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('sugar_intake').doc(docId).delete();
      print("Sugar intake deleted successfully");
    } catch (e) {
      print("Error deleting sugar intake: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(

      appBar: AppBar(
        title: Text('Sugar Intake Calendar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _showSignOutConfirmationDialog(context, auth);
            },
          ),
        ],
      ),

      body: Column(
        children: [
          TableCalendar(
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 35, // Adjust marker size
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.5), // Semi-transparent red
                          shape: BoxShape.circle, // Makes it circular
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox(); // No marker if no event
              },
            ),

            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            enabledDayPredicate: (day) {
              return day.isBefore(DateTime.now().add(Duration(days: 1))); // Disable future days
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
            },

            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.purple, // Changes the focused day color to red
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple, // Custom color for selected day
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white, // Text color for today
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  key: ValueKey(_selectedDay.toString()), // Add a key here
                  itemCount: _getEventsForDay(_selectedDay).length,
                  itemBuilder: (context, index) {
                    SugarIntake intake = _getEventsForDay(_selectedDay)[index];
                    return ListTile(
                      title: Text('${intake.foodName} - ${intake.servingAmount} servings'),
                      subtitle: Text('${intake.sugarAmount} grams of sugar '),
                      trailing: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,

                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateServingDialog(context, intake, () {
                                  setState(() {}); // Refresh UI
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, intake, () {
                                  setState(() {}); // Refresh UI
                                });
                                // Delete the sugar intake
                                //sugarProvider.removeSugarIntake(sugarProvider.history.indexOf(intake));
                                // _showDeleteConfirmationDialog(context, sugarProvider, intake);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Total sugars: ${_getEventsForDay(_selectedDay).fold(0, (sum, item) => sum + item.sugarAmount.toInt())}g",
                    style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodSearchView(selectedDate: _selectedDay,)),
          );
          //_showAddSugarIntakeDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, SugarIntake intake, Function refreshData) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: "Confirm Deletion",
      desc: "Are you sure you want to delete this sugar intake?",
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnOkText: "Delete",
      btnOkColor: Colors.red,
      btnOkOnPress: () async {
        await deleteSugarIntake(intake.docId.toString()); // Delete from Firestore
        refreshData(); // Refresh UI
      },
    ).show();
  }

  void _showSignOutConfirmationDialog(BuildContext context, AuthService auth) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: "Confirm Sign Out",
      desc: "Are you sure you want to sign out?",
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnOkText: "Yes",
      btnOkOnPress: () async {
        await auth.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
    ).show();
  }

  void _showUpdateServingDialog(
      BuildContext context,
      SugarIntake intake,
      Function refreshData,
      ) {
    final TextEditingController _servingController =
    TextEditingController(text: intake.servingAmount.toString());

    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text("Adjust the servings for ${intake.foodName}", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          Text("Each serving has ${intake.sugarPerServing}g sugar", style: GoogleFonts.poppins(color: Colors.black,)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _servingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
              hintText: 'New Serving Amount'
              ),
            ),
          ),
        ],
      ),
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnOkText: "Update",
      btnOkOnPress: () async {
        int? newServing = int.tryParse(_servingController.text);

        if (newServing == null || newServing <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Serving amount must be greater than 0"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (newServing != null && newServing > 0) {
          // double sugarPerServing = intake.sugarPerServing;
          // double newTotalSugar = sugarPerServing * newServing;
          //
          // // Update Firestore
          // await FirebaseFirestore.instance
          //     .collection('sugar_intake')
          //     .doc(intake.docId)
          //     .update({
          //   'servingAmount': newServing,
          //   'sugarAmount': newTotalSugar,
          // });
          // refreshData(); // Refresh UI
          updateSugarData(context, intake, refreshData, newServing);
        }
      },
    ).show();
  }
}

Future<void> updateSugarData(BuildContext context,
    SugarIntake intake,
    Function refreshData, int newServing) async {
  double sugarPerServing = intake.sugarPerServing;
  double newTotalSugar = sugarPerServing * newServing;

  // Update Firestore
  await FirebaseFirestore.instance
      .collection('sugar_intake')
      .doc(intake.docId)
      .update({
    'servingAmount': newServing,
    'sugarAmount': newTotalSugar,
  });
  refreshData(); // Refresh UI
}