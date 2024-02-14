
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/screens/signin_screen.dart';
import 'package:flutter_barcode_scanner/utils/colours.dart';

import '../reusable_widget/reusable_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState  extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors:[
                hexStringToColor("CB2B93"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4")

              ],begin: Alignment.topCenter, end: Alignment.bottomCenter )),
          child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(30,220,20,400),
                child: Column(
                  children:<Widget> [
                    const  SizedBox(
                      height: 30,
                    ),
                    reusableTextField1("Enter UserName", Icons.person_outline, false,
                        _usernameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField1("Enter Email", Icons.mail, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField1("Enter Password", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),

                    firebaseUIButton(context, "Sign Up", () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                          .then((value) {

                            print("Created New Account");
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context)=> SignInScreen()));

                          }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    }),
                  ],
                ),
              ))),
    );
  }
}