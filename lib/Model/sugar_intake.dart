import 'package:cloud_firestore/cloud_firestore.dart';

class SugarIntake {
  final double sugarAmount;
  final DateTime date;
  final String foodName;
  final int servingAmount;
  final String? userEmail;
  String? docId;

  SugarIntake({this.docId, required this.sugarAmount, required this.date, required this.foodName, required this.servingAmount, required this.userEmail});

  Map<String, dynamic> toJson() => {
    'sugarAmount': sugarAmount,
    'date': date,
    'foodName': foodName,
    'servingAmount': servingAmount,
    'userEmail': userEmail
  };

  factory SugarIntake.fromFirestore(String docId, Map<String, dynamic> data) {
    return SugarIntake(
      docId: docId,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(), // Konversi String ke DateTime
      sugarAmount: (data['sugarAmount'] as num).toDouble(),
      foodName: data['foodName'],
      servingAmount: (data['servingAmount'] as num).toInt(),
      userEmail: data['userEmail'],
    );
  }
  
}