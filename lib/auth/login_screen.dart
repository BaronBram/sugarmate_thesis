import 'package:flutter/material.dart';
import 'package:sugarmate_thesis/Model/user_session.dart';
import 'package:sugarmate_thesis/View/article_view.dart';
import 'package:sugarmate_thesis/View/main_view.dart';
import 'package:sugarmate_thesis/View/sugar_tracker_view.dart';
import 'package:sugarmate_thesis/auth/auth_service.dart';
import 'package:sugarmate_thesis/auth/signup_screen.dart';
import 'package:sugarmate_thesis/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
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
            Text("Login",
                style: GoogleFonts.poppins(fontSize: MediaQuery.of(context).size.height*0.06, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            // CustomTextField(
            //   hint: "Enter Email",
            //   label: "Email",
            //   controller: _email,
            // ),
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
            // CustomTextField(
            //   hint: "Enter Password",
            //   label: "Password",
            //   controller: _password,
            // ),
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
                onPressed: _login,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Login', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Already have an account? ", style: GoogleFonts.poppins(),),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                Text("Signup", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
              )
            ]),
            const Spacer()
          ],
        ),
      )
    );
  }
  goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignUpScreen()),
  );

  goToHome(BuildContext context) => Navigator.pushReplacementNamed(context, '/tracker');

  // goToHome(BuildContext context) => Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => ArticleListView()),
  // );

  _login() async {
    final user =
    await _auth.loginUserEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      print("User Logged In");
      // Store logged-in email
      UserSession().email = _email.text;
      goToHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Wrong Email or password"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
