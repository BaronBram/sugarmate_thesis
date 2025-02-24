
import 'package:flutter/material.dart';
import 'package:sugarmate_thesis/auth/auth_service.dart';
import 'package:sugarmate_thesis/auth/login_screen.dart';
import 'package:sugarmate_thesis/home_screen.dart';
import 'package:sugarmate_thesis/widgets/textfield.dart';
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
            Text("Signup",
                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _signup,
              style: ElevatedButton.styleFrom(
              backgroundColor:  const Color(0xFFA3F6D1),
            ),
                child: Text('Sign Up', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),

            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Already have an account? ", style: GoogleFonts.poppins()),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        )
      ),
    );
  }
  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  _signup() async {
    final user = _auth.createUserEmailAndPassword(_email.text, _password.text);
    if (user != null) {
      print("User Created Succesfully");
      goToHome(context);
    }
  }
}
