import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';




class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _scanBarcode1 = 'Unknown';
  String _scanBarcode2 = 'Unknown';
  @override
  void initState() {
    super.initState();
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }






  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      ///

      CollectionReference productsRef = FirebaseFirestore.instance.collection('table');
      QuerySnapshot querySnapshot = await productsRef.where('barcode', isEqualTo: barcodeScanRes).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Barcode matches a record in Firestore
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;

        // Use the data as needed
        if (data != null) {
          print('Name: ${data['Name']}');
          _scanBarcode1 = 'Name: ${data['Name']}';
          print('Price: ${data['Price']}');
          _scanBarcode2 = 'Price: ${data['Price']}';


          ///
        }
      } else {
        // Barcode does not match any record in Firestore
        print('Barcode not found');
      }



      ///
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      ///_scanBarcode = barcodeScanRes;
    });
  }





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,  //removing debug banner
        home: Scaffold(

            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('CART_X'),
              //   backgroundColor: Colors.transparent,
            ),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.purple, Colors.blue]
                      )
                  ),

                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () => scanBarcodeNormal(),
                            child: Text('Start barcode scan')),

                        Text('Item $_scanBarcode1\n',
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Text('Item $_scanBarcode2 (Rs.)\n',
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                      ]));
            })));
  }
}
