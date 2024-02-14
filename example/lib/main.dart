import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_barcode_scanner/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
//import 'package:flutter_barcode_scanner/screens/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // Stripe.publishableKey = 'pk_test_51NIacVBzpe3k5CWAFMSGxRTRZ9F3XSUmjUMKfFwJmqU0JkDYMOOR5U5IzQprQVwZe2S9DXj4ka9DRqwcVY07ssrf00YlTBbhOj';
  await Firebase.initializeApp();


 // await Stripe.instance.applySettings();

  // init the hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('mybox');

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {


  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  //removing debug banner
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const SignInScreen(),
    );
  }
}
