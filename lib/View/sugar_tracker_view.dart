import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';
import 'package:sugarmate_thesis/Model/sugar_provider.dart';
import 'package:sugarmate_thesis/View/add_sugar_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sugar Intake Calendar'),
      ),
      body: Consumer<SugarProvider>(
        builder: (context, sugarProvider, child) {
          Map<DateTime, List<SugarIntake>> events = {};
          for (SugarIntake intake in sugarProvider.history) {
            DateTime dateOnly = DateTime(intake.date.year, intake.date.month, intake.date.day);
            if (!events.containsKey(dateOnly)) {
              events[dateOnly] = [];
            }
            events[dateOnly]!.add(intake);
          }

          List<SugarIntake> _getEventsForDay(DateTime day) {
            DateTime normalizedDay = DateTime(day.year, day.month, day.day);
            return events[normalizedDay] ?? [];
          }

          return Column(
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
                              color: Colors.tealAccent.withOpacity(0.5), // Semi-transparent red
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
                lastDay: DateTime.utc(2026, 12, 31),
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
                    color: Colors.teal, // Changes the focused day color to red
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.teal, // Custom color for selected day
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
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Delete the sugar intake
                              //sugarProvider.removeSugarIntake(sugarProvider.history.indexOf(intake));
                            _showDeleteConfirmationDialog(context, sugarProvider, intake);
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total sugars: ${_getEventsForDay(_selectedDay).fold(0, (sum, item) => sum + item.sugarAmount.toInt())}g",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  void _showDeleteConfirmationDialog(BuildContext context, SugarProvider sugarProvider, SugarIntake intake) {
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
      btnOkOnPress: () {
        sugarProvider.removeSugarIntake(sugarProvider.history.indexOf(intake));
        _showDeleteDialog(context);
      },
    ).show();
  }

  void _showDeleteDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Deletion Complete",
      desc: "The data has been deleted",
      btnOkText: "Okay",
      btnOkColor: Colors.green,
      btnOkOnPress: () {
      },
    ).show();
  }

}