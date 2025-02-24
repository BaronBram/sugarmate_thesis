import 'package:flutter/material.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';

class SugarProvider extends ChangeNotifier {
  List<SugarIntake> _history = [];

  List<SugarIntake> get history => _history;

  void addSugarIntake(double sugarAmount) {
    _history.add(SugarIntake(sugarAmount: sugarAmount, date: DateTime.now()));
    notifyListeners(); // Memperbarui UI
  }

  void removeSugarIntake(int index) {
    _history.removeAt(index);
    notifyListeners(); // Memperbarui UI
  }
}
