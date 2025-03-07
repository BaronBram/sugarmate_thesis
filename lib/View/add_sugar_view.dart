import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sugarmate_thesis/Controller/sugar_controller.dart';
import 'package:sugarmate_thesis/Model/sugar_provider.dart';

class FoodSearchView extends StatefulWidget {
  final DateTime selectedDate;

  FoodSearchView({super.key, required this.selectedDate});

  @override
  _FoodSearchViewState createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final SugarController _controller = SugarController();
  String _searchQuery = "";

  /// Menghasilkan stream berdasarkan query pencarian
  Stream<QuerySnapshot> _getFoodStream(String query) {
    if (query.isEmpty) {
      return FirebaseFirestore.instance.collection('food').snapshots();
    }
    return FirebaseFirestore.instance
        .collection('food')
        .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('name', isLessThan: query.toLowerCase() + 'z')
        .limit(10)
        .snapshots();
  }


  void _addSugarIntake(double sugarAmount, String foodName, int servingAmount) {
    //double? sugarAmount = double.tryParse(_sugarInputController.text);
    if (sugarAmount >= 0) {
      Provider.of<SugarProvider>(context, listen: false).addSugarIntake(sugarAmount, foodName, servingAmount, widget.selectedDate);
      Navigator.of(context).pop(servingAmount);
      //Navigator.pop(context, sugarAmount); // Return the sugar amount
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Masukkan jumlah gula yang valid!")),
      );
    }
  }

  // void _addSugarIntake(double sugarAmount) async {
  //   await _controller.addSugarIntake(sugarAmount);
  //   Navigator.pop(context); // Kembali ke halaman tracker setelah menambah
  // }

  void _showAddSugarIntakeDialog(BuildContext context, String foodName, double sugarPerServing) {
    int servings = 1; // Default to 1 serving

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: 'How many servings of $foodName?',
      body: Column(
        children: [
          Text('Each serving contains ${sugarPerServing.toStringAsFixed(1)}g of sugar.'),
          SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter number of servings',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              servings = int.tryParse(value) ?? 1; // Default to 1 if input is invalid
            },
          ),
        ],
      ),
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnOkText: "Add",
      btnOkOnPress: () {
        double totalSugar = servings * sugarPerServing;
        _addSugarIntake(totalSugar, foodName, servings);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Food & Calculate Sugar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Update query pencarian secara otomatis
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Enter food name",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:  _getFoodStream(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No results found"));
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final food = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(food['name']),
                        subtitle: Text("${food['sugar']}g sugar per serving"),
                        onTap: () => _showAddSugarIntakeDialog(context, food['name'], (food['sugar'] as num).toDouble()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// void _addSugarIntake() {
//   double? sugarAmount = double.tryParse(_sugarInputController.text);
//   if (sugarAmount != null && sugarAmount > 0) {
//     Navigator.pop(context, sugarAmount); // Return the sugar amount
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Masukkan jumlah gula yang valid!")),
//     );
//   }
// }

