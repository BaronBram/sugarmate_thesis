import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugarmate_thesis/Controller/sugar_controller.dart';
import 'package:sugarmate_thesis/Model/sugar_intake.dart';
import 'package:sugarmate_thesis/Model/user_session.dart';
import 'package:sugarmate_thesis/auth/login_screen.dart';

class FoodSearchView extends StatefulWidget {
  final DateTime selectedDate;

  FoodSearchView({super.key, required this.selectedDate});

  @override
  _FoodSearchViewState createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final SugarController _controller = SugarController();
  String? loggedEmail = UserSession().email;

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

  void _showCompleteDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Insertion Complete",
      desc: "The data has been added",
      btnOkText: "Okay",
      btnOkColor: Colors.green,
      btnOkOnPress: () {
      },
    ).show();
  }

  void _showAddSugarIntakeDialog(BuildContext context, String foodName, double sugarPerServing) {
    int servings = 1; // Default to 1 serving

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: true,
      title: 'How many servings of $foodName?',
      body: Column(
        children: [

          Text('How many servings of $foodName?', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          Text('Each serving contains ${sugarPerServing.toStringAsFixed(1)}g of sugar', style: GoogleFonts.poppins(color: Colors.black,)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of servings',
              ),
              onChanged: (value) {
                servings = int.tryParse(value) ?? 1; // Default to 1 if input is invalid
              },
            ),
          ),
        ],
      ),
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnCancelColor: Colors.grey[700],
      btnOkText: "Add",
      btnOkOnPress: () async {
        double totalSugar = servings * sugarPerServing;
        //_addSugarIntake(totalSugar, foodName, servings);
        SugarIntake intake = SugarIntake(
          foodName: foodName,
          servingAmount: servings,
          sugarAmount: totalSugar,
          date: widget.selectedDate,
          userEmail: loggedEmail,
          sugarPerServing: sugarPerServing,
        );

        // Call controller to add data
       await _controller.addSugarIntakeToFirebase(intake);
        _showCompleteDialog(context);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food List", style: GoogleFonts.poppins(fontWeight: FontWeight.bold),)),
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
                        trailing: const Icon(Icons.arrow_forward_ios),
                        title: Text(food['name'], style: GoogleFonts.poppins(color: Colors.black,)),
                        subtitle: Text("${food['sugar']}g sugar per serving", style: GoogleFonts.poppins()),
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

