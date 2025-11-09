import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // Converts CartItem to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Creates a CartItem from a Map retrieved from Firestore
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      // Firebase/Dart type safety: ensure 'price' is read as a double
      price: (json['price'] as num).toDouble(), 
      // Firebase/Dart type safety: ensure 'quantity' is read as an int
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId; 
  StreamSubscription? _authSubscription; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters (Unchanged)
  List<CartItem> get items => _items;
  
  int get itemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // CONSTRUCTOR
  CartProvider() {
    print('CartProvider initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = []; 
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart(); 
      }
      notifyListeners();
    });
  }

  // Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return; 

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
        print('No saved cart found. Starting empty.');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = []; 
    }
    notifyListeners(); 
  }

  // Saves the current local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return; 

    try {
      final List<Map<String, dynamic>> cartData = 
          _items.map((item) => item.toJson()).toList();
      
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }
  
  // Updated Methods
  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }

    _saveCart(); 
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    
    _saveCart(); 
    notifyListeners();
  }

  // 1. ADDED: Creates an order in the 'orders' collection
  Future<void> placeOrder() async {
    // 2. Check if we have a user and items
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      // 3. Convert our List<CartItem> to a List<Map> using toJson()
      final List<Map<String, dynamic>> cartData = 
          _items.map((item) => item.toJson()).toList();
      
      // 4. Get total price and item count from our getters
      final double total = totalPrice;
      final int count = itemCount;

      // 5. Create a new document in the 'orders' collection
      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData, // Our list of item maps
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending', // 6. IMPORTANT: For admin verification
        'createdAt': FieldValue.serverTimestamp(), // For sorting
      });
      
      print('Order placed successfully for user $_userId');
      
      // Note: We DO NOT clear the cart here. clearCart() is called separately.
      
    } catch (e) {
      print('Error placing order: $e');
      // 8. Re-throw the error so the UI can catch it
      // The `e` might not be dynamic, so we cast it slightly safer
      rethrow; 
    }
  }

  // 9. ADDED: Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    // 10. Clear the local list
    _items = [];
    
    // 11. If logged in, clear the Firestore cart as well
    if (_userId != null) {
      try {
        // 12. Set the 'cartItems' field in their cart doc to an empty list
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }
    
    // 13. Notify all listeners (this will clear the UI)
    notifyListeners();
  }

  // dispose() Method
  @override
  void dispose() {
    _authSubscription?.cancel(); 
    super.dispose();
  }
}