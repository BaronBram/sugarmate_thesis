import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sugarmate_thesis/Model/sugar_intake.dart';
import 'package:sugarmate_thesis/Model/user_session.dart';

class SugarController {
  List<SugarIntake> _intakeHistory = [];
  String? loggedEmail = UserSession().email;

  // Future<void> loadIntakeHistory() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? data = prefs.getString('sugarHistory');
  //   if (data != null) {
  //     List<dynamic> jsonData = json.decode(data);
  //     _intakeHistory = jsonData.map((e) => SugarIntake.fromJson(e)).toList();
  //   }
  // }

  // Future<void> editSugarIntake(int index, double newSugarAmount, String newFoodName) async {
  //   if (index >= 0 && index < _intakeHistory.length) {
  //     _intakeHistory[index] = SugarIntake(
  //       sugarAmount: newSugarAmount,
  //       date: _intakeHistory[index].date,
  //       foodName: newFoodName
  //     );
  //     await _saveData();
  //   }
  // }
  //
  // Future<void> deleteSugarIntake(int index) async {
  //   if (index >= 0 && index < _intakeHistory.length) {
  //     _intakeHistory.removeAt(index);
  //     await _saveData();
  //   }
  // }

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add sugar intake to Firestore
  Future<void> addSugarIntakeToFirebase(SugarIntake intake) async {
    try {
      // Add the document to Firestore
      DocumentReference docRef = await _firestore.collection('sugar_intake').add(intake.toJson());

      // Update the document with its own document ID
      await docRef.update({'docId': docRef.id});

      print('Sugar intake added successfully with docId: ${docRef.id}');
    } catch (error) {
      print('Failed to add sugar intake: $error');
    }
  }


  Stream<Map<DateTime, List<SugarIntake>>> fetchSugarIntake() {
    return _firestore
        .collection('sugar_intake')
        .where('userEmail', isEqualTo: loggedEmail)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      Map<DateTime, List<SugarIntake>> sugarData = {};

      for (var doc in querySnapshot.docs) {
        SugarIntake intake = SugarIntake.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);

        // Normalisasi ke format tanpa jam
        DateTime normalizedDate = DateTime(intake.date.year, intake.date.month, intake.date.day);

        if (!sugarData.containsKey(normalizedDate)) {
          sugarData[normalizedDate] = [];
        }
        sugarData[normalizedDate]!.add(intake);
      }
      return sugarData;
    });
  }

}

