import 'package:cloud_firestore/cloud_firestore.dart';

class SugarIntake {
  final double sugarAmount;
  final DateTime date;
  final String foodName;
  final int servingAmount;
  final String? userEmail;


  SugarIntake({required this.sugarAmount, required this.date, required this.foodName, required this.servingAmount, required this.userEmail});

  Map<String, dynamic> toJson() => {
    'sugarAmount': sugarAmount,
    'date': date,
    'foodName': foodName,
    'servingAmount': servingAmount,
    'userEmail': userEmail
  };

  factory SugarIntake.fromJson(Map<String, dynamic> json) => SugarIntake(
    sugarAmount: json['sugarAmount'],
    date: json['date'],
    foodName: json['foodName'],
    servingAmount: json['servingAmount'],
    userEmail: json['userEmail']
  );

  factory SugarIntake.fromFirestore(Map<String, dynamic> data) {
    return SugarIntake(
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(), // Konversi String ke DateTime
      sugarAmount: (data['sugarAmount'] as num).toDouble(),
      foodName: data['foodName'],
      servingAmount: (data['servingAmount'] as num).toInt(),
      userEmail: data['userEmail'],
    );
  }
  
}