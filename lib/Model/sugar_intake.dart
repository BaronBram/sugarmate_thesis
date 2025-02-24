class SugarIntake {
  double sugarAmount;
  DateTime date;

  SugarIntake({required this.sugarAmount, required this.date});

  factory SugarIntake.fromJson(Map<String, dynamic> json) {
    try {
      final sugarAmount = json['sugarAmount'];
      if (sugarAmount is! num) {  // Check if it's a number (int or double)
        throw FormatException('sugarAmount must be a number');
      }

      final dateString = json['date'];
      if (dateString is! String) {
        throw FormatException('date must be a string');
      }

      final date = DateTime.parse(dateString);

      return SugarIntake(
        sugarAmount: sugarAmount.toDouble(), // Ensure it's a double
        date: date,
      );
    } on FormatException catch (e) {
      // Handle parsing errors
      print('Error parsing SugarIntake from JSON: $e');
      // Or throw an exception if you prefer
      throw Exception('date must be a string');
    } catch (e) {
      // Handle other potential errors (e.g., missing keys)
      print('Error parsing SugarIntake from JSON: $e');
      throw Exception('date must be a string');
      // Or throw an exception
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'sugarAmount': sugarAmount,
      'date': date.toString(),
    };
  }
}