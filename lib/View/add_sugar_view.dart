import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugarmate_thesis/Controller/sugar_controller.dart';

class FoodSearchView extends StatefulWidget {
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


  void _addSugarIntake(double sugarAmount) {
    //double? sugarAmount = double.tryParse(_sugarInputController.text);
    if (sugarAmount > 0) {
      Navigator.pop(context, sugarAmount); // Return the sugar amount
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
                        onTap: () => _addSugarIntake(food['sugar'].toDouble()),
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