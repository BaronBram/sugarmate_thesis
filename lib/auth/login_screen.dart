import 'package:flutter/material.dart';
import 'package:sugarmate_thesis/View/article_view.dart';
import 'package:sugarmate_thesis/View/sugar_tracker_view.dart';
import 'package:sugarmate_thesis/auth/auth_service.dart';
import 'package:sugarmate_thesis/auth/signup_screen.dart';
import 'package:sugarmate_thesis/home_screen.dart';

import 'package:sugarmate_thesis/widgets/textfield.dart';
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
                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              controller: _password,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _login,
              style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFA3F6D1),
                ),

              child: Text('Login', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),),

            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Already have an account? ", style: GoogleFonts.poppins(),),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                Text("Signup", style: GoogleFonts.poppins(color: Colors.red)),
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

  // goToHome(BuildContext context) => Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => CalendarScreen()),
  // );

  goToHome(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ArticleListView()),
  );

  _login() async {
    final user =
    await _auth.loginUserEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      print("User Logged In");
      goToHome(context);
    } else {
      Fluttertoast.showToast(
        msg: "Wrong Email or Password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
