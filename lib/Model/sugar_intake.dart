class SugarIntake {
  final double sugarAmount;
  final DateTime date;

  SugarIntake({required this.sugarAmount, required this.date});

  Map<String, dynamic> toJson() => {
    'sugarAmount': sugarAmount,
    'date': date.toIso8601String(),
  };

  factory SugarIntake.fromJson(Map<String, dynamic> json) => SugarIntake(
    sugarAmount: json['sugarAmount'],
    date: DateTime.parse(json['date']),
  );
}