class SugarIntake {
  final double sugarAmount;
  final DateTime date;
  final String foodName;
  final int servingAmount;


  SugarIntake({required this.sugarAmount, required this.date, required this.foodName, required this.servingAmount});

  Map<String, dynamic> toJson() => {
    'sugarAmount': sugarAmount,
    'date': date,
    'foodName': foodName,
    'servingAmount': servingAmount
  };

  factory SugarIntake.fromJson(Map<String, dynamic> json) => SugarIntake(
    sugarAmount: json['sugarAmount'],
    date: json['date'],
    foodName: json['foodName'],
    servingAmount: json['servingAmount'],
  );
}