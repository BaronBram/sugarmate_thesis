import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sugarmate_thesis/Model/sugar_intake.dart';

class SugarController {
  List<SugarIntake> _intakeHistory = [];

  Future<void> loadIntakeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('sugarHistory');
    if (data != null) {
      List<dynamic> jsonData = json.decode(data);
      _intakeHistory = jsonData.map((e) => SugarIntake.fromJson(e)).toList();
    }
  }

  Future<void> addSugarIntake(double sugarAmount) async {
    // final newEntry = SugarIntake(sugarAmount: sugarAmount, date: DateTime.now());
    // _intakeHistory.add(newEntry);
    DateTime now = DateTime.now();

    SugarIntake newIntake = SugarIntake(sugarAmount: sugarAmount, date: now);

    _intakeHistory.add(newIntake);
    print("✅ Data disimpan: ${newIntake.sugarAmount}g pada ${newIntake.date}");
    await _saveData();
  }

  Future<void> editSugarIntake(int index, double newSugarAmount) async {
    if (index >= 0 && index < _intakeHistory.length) {
      _intakeHistory[index] = SugarIntake(
        sugarAmount: newSugarAmount,
        date: _intakeHistory[index].date,
      );
      await _saveData();
    }
  }

  Future<void> deleteSugarIntake(int index) async {
    if (index >= 0 && index < _intakeHistory.length) {
      _intakeHistory.removeAt(index);
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(_intakeHistory.map((e) => e.toJson()).toList());
    await prefs.setString('sugarHistory', jsonData);
  }

  double getDailySugarTotal() {
    DateTime today = DateTime.now();
    return _intakeHistory
        .where((entry) =>
    entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day)
        .fold(0, (sum, entry) => sum + entry.sugarAmount);
  }

  List<SugarIntake> get history => List.unmodifiable(_intakeHistory);
}

