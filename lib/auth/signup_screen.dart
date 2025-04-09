
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sugarmate_thesis/View/sugar_tracker_view.dart';
import 'package:sugarmate_thesis/auth/auth_service.dart';
import 'package:sugarmate_thesis/auth/login_screen.dart';
import 'package:sugarmate_thesis/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            Text("Sign Up",
                style: GoogleFonts.poppins(fontSize: MediaQuery.of(context).size.height*0.06, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                  hintText: "Enter Email",
                  label: Text("Email", style: GoogleFonts.poppins(fontSize: MediaQuery.of(context).size.height*0.018, fontWeight: FontWeight.w300)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey, width: 1))
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter Password",
                label: Text("Password", style: GoogleFonts.poppins(fontSize: MediaQuery.of(context).size.height*0.018, fontWeight: FontWeight.w300)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.grey, width: 1)),
              ),

            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: _signup,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Already have an account? ", style: GoogleFonts.poppins()),
              InkWell(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Login", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              )
            ]),
            const Spacer()
          ],
        )
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.pushReplacementNamed(context, '/login');

  _signup() async {

    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all data"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final user = _auth.createUserEmailAndPassword(_email.text, _password.text);
    if (user != null) {
      print("User Created Succesfully");
      goToLogin(context);
    }
  }
}
