import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sugarmate_thesis/Controller/sugar_controller.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';
import 'package:sugarmate_thesis/Model/sugar_provider.dart';
import 'package:sugarmate_thesis/View/add_sugar_view.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TrackerView extends StatefulWidget {
  @override
  _TrackerViewState createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  final SugarController _controller = SugarController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadIntakeHistory();
    setState(() => _isLoading = false);
  }

  void _addNewSugarIntake(double sugarAmount) async {
    await _controller.addSugarIntake(sugarAmount);
    setState(() {}); // Refresh the UI after adding a new entry
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracker Gula')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _controller.history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${_controller.history[index].sugarAmount} g"),
            subtitle: Text("${_controller.history[index].date.toLocal()}"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _controller.deleteSugarIntake(index);
                setState(() {}); // Refresh UI after deletion
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          double? newSugarAmount = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodSearchView(),
            ),
          );

          // If the user entered a valid sugar amount, update the UI
          if (newSugarAmount != null) {
            _addNewSugarIntake(newSugarAmount);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}




