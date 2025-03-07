import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';

class SugarProvider extends ChangeNotifier {
  List<SugarIntake> _history = [];

  List<SugarIntake> get history => _history;

  SugarProvider() {
    _loadDataFromSharedPreferences();
  }

  Future<void> _loadDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('sugarHistory');
    if (historyString != null) {
      final List<dynamic> decodedList = jsonDecode(historyString);
      _history = decodedList.map((item) => SugarIntake.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveDataToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodedList = _history.map((item) => item.toJson()).toList();
    final String encodedString = jsonEncode(encodedList);
    await prefs.setString('sugarHistory', encodedString);
  }

  void addSugarIntake(double sugarAmount, String foodName, int servingAmount, DateTime selectedDate) {
    _history.add(SugarIntake(sugarAmount: sugarAmount, date: selectedDate, foodName: foodName, servingAmount: servingAmount));
    _saveDataToSharedPreferences();
    notifyListeners();
  }

  void removeSugarIntake(int index) {
    _history.removeAt(index);
    _saveDataToSharedPreferences();
    notifyListeners();
  }
}