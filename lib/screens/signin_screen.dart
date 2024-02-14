import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barcode_scanner/screens/home_screen.dart';
import 'package:flutter_barcode_scanner/screens/reset_password.dart';
import 'package:flutter_barcode_scanner/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/reusable_widget/reusable_widget.dart';
import 'package:flutter_barcode_scanner/utils/colours.dart';
import 'package:flutter_barcode_scanner/service/firebase_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors:[
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")

            ],begin: Alignment.topCenter, end: Alignment.bottomCenter )),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 400),
            child: Column(
              children:<Widget> [
                logoWidget("assets/images/design.png"),

                const SizedBox(
                  height: 30,
                ),

                reusableTextField1("Enter Email Address", Icons.person_outline, false,
                    _emailTextController),

                const SizedBox(
                  height: 20,
                ),

                reusableTextField2("Enter Password", Icons.lock_outline, _isHidden,
                    _passwordTextController),

                const SizedBox(
                  height: 5,
                ),

                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text)
                      .then((value) {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen(email: _emailTextController.text)));
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                }),

                // ElevatedButton.icon(
                //   onPressed: () async {
                //     await FirebaseServices().signInWithGoogle();
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => HomeScreen()));
                //   },
                //
                //   icon: Icon(Icons.g_mobiledata_sharp),
                //   label: Text("Sign In with Google"),
                //   style: ElevatedButton.styleFrom(
                //     primary: Colors.red, // Change the color as per your preference
                //     onPrimary: Colors.white,
                //   ),
                // ),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );


  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Row signUpOption (){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: (){
            Navigator.push(context as BuildContext, MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }



}