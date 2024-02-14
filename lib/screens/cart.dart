import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/screens/scan_screen.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pay/pay.dart';
import 'package:flutter_barcode_scanner/screens/payment_config.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<Product> _cartItems = [];
  String _userEmail = '';
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    Firebase.initializeApp();
    // Get the user's email address
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
    // Load the cart items from Firestore
    await _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      if (_userEmail.isNotEmpty) {
        // Get the user's cart from Firestore
        DocumentSnapshot cartDoc = await FirebaseFirestore.instance
            .collection('carts')
            .doc(_userEmail)
            .get();
        // Load the cart items into the _cartItems list
        Map<String, dynamic>? cartData =
        cartDoc.data() as Map<String, dynamic>?;
        if (cartData != null) {
          List<dynamic> cartList = cartData['cart'];
          setState(() {
            _cartItems = cartList.map((e) => Product.fromMap(e)).toList();
            _totalPrice =
                _cartItems.fold(0, (total, item) => total + item.Price);
          });
        }
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _scanBarcode() async {
    try {
      // Scan barcode using third-party package
      String barcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      // Check if the product is already in the cart
      int existingIndex =
      _cartItems.indexWhere((product) => product.barcode == barcode);

      if (existingIndex != -1) {
        // If the product is already in the cart, increase the quantity
        setState(() {
          _cartItems[existingIndex].quantity += 1;
          _totalPrice += _cartItems[existingIndex].Price;
        });
      } else {
        // Get product document from Firestore
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('table')
            .doc(barcode)
            .get();
        // Create Product object from Firestore data
        Product product = Product.fromFirestore(productDoc);
        // Add product to shopping cart
        setState(() {
          _cartItems.add(product);
          _totalPrice += product.Price;
        });
      }

      // Save cart to Firestore
      _saveCart();
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  var googlePayButton;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    googlePayButton = GooglePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
      paymentItems: [
        PaymentItem(
          label: 'Total',
          amount: '$_totalPrice',
          status: PaymentItemStatus.final_price,
        )
      ],
      type: GooglePayButtonType.pay,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: (result) => debugPrint('Payment Result $result'),
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    );
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
          title: Text('Shopping Cart'),
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          itemCount: _cartItems.length,
          itemBuilder: (context, index) {
            Product product = _cartItems[index];
            return ListTile(
              title: Text(
                product.Name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                'Quantity: ${product.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\Rs ${product.Price * product.quantity}'),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _removeItem(index),
                    child: Text('Remove'),
                  ),
                  SizedBox(width: 2),
                  ElevatedButton(
                    onPressed: () => _decreaseQuantity(index),
                    child: Text('-'),
                  ),
                  SizedBox(width: 2),
                  ElevatedButton(
                    onPressed: () => _increaseQuantity(index),
                    child: Text('+'),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scanBarcode,
          child: Icon(Icons.camera_alt),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.indigo,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Payment'),
                    content: googlePayButton,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              'Pay Total: \Rs $_totalPrice',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _decreaseQuantity(int index) {
    Product product = _cartItems[index];

    if (product.quantity > 1) {
      setState(() {
        product.quantity -= 1;
        _totalPrice -= product.Price;
      });
    } else {
      // If the quantity is 1, remove the item from the cart
      _removeItem(index);
    }

    // Save the updated cart to Firestore
    _saveCart();
  }

  void _removeItem(int index) {
    Product product = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
      _totalPrice -= product.Price;
    });
    // Save the updated cart to Firestore
    _saveCart();
  }

  void _increaseQuantity(int index) {
    Product product = _cartItems[index];

    setState(() {
      product.quantity += 1;
      _totalPrice += product.Price;
    });

    // Save the updated cart to Firestore
    _saveCart();
  }

  Future<void> _saveCart() async {
    try {
      if (_userEmail.isNotEmpty) {
        // Create a list of map data from the _cartItems list
        List<Map<String, dynamic>> cartData =
        _cartItems.map((product) => product.toMap()).toList();

        // Save the cart data to Firestore
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(_userEmail)
            .set({'cart': cartData});
      }
    } catch (e) {
      print('Error saving cart: $e');
    }
  }
}

class Product {
  final String barcode;
  final String Name;
  final int Price;
  int quantity;

  Product({
    required this.barcode,
    required this.Name,
    required this.Price,
    required this.quantity,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return Product(
      barcode: doc.id,
      Name: data?['Name'] ?? '',
      Price: data?['Price'] ?? 0,
      quantity: 1,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcode: map['barcode'],
      Name: map['Name'],
      Price: map['Price'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'Name': Name,
      'Price': Price,
      'quantity': quantity,
    };
  }
}
