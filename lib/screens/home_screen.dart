import 'package:flutter_barcode_scanner/screens/signin_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/screens/list_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/screens/scan_screen.dart';
import 'package:flutter_barcode_scanner/screens/cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedValue;

  void _logout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _viewProfile() {
    setState(() {
      selectedValue = widget.email;
    });
  }

  void _launchUnityApp() async {
    const url = "https://example.com/unity-app";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch Unity app";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.purple, Colors.blue],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("CART_X"),
          backgroundColor: Colors.transparent,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.accessibility_new_outlined),
              initialValue: selectedValue,
              onSelected: (String newValue) {
                setState(() {
                  selectedValue = newValue;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Email: ${widget.email}',
                  child: Text('Email: ${widget.email}'),
                ),
              ],
            ),
            SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.document_scanner_outlined),
                label: Text("| Scan"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  fixedSize: Size(220, 60),
                  textStyle:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 30,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: StadiumBorder(),
                ),
              ),
              SizedBox(
                width: 200,
                height: 40,
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add_shopping_cart_rounded),
                label: Text("| Cart"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShoppingCartScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  fixedSize: Size(220, 60),
                  textStyle:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 30,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: StadiumBorder(),
                ),
              ),
              SizedBox(
                width: 200,
                height: 40,
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.location_on_outlined),
                label: Text("| Location"),
                onPressed: () {
                  _launchUnityApp();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  fixedSize: Size(220, 60),
                  textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 30,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: StadiumBorder(),
                ),
              ),
              SizedBox(
                width: 200,
                height: 40,
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.format_list_bulleted_sharp),
                label: Text("| Pre-List"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  fixedSize: Size(220, 60),
                  textStyle:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 30,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 2),
                  shape: StadiumBorder(),
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}