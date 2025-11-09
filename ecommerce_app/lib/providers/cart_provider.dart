import 'dart:async'; // 1. ADDED
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 2. ADDED
import 'package:cloud_firestore/cloud_firestore.dart'; // 3. ADDED

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

  // 1. ADDED: Converts CartItem to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // 2. ADDED: Creates a CartItem from a Map retrieved from Firestore
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Note: Firestore stores numbers as 'num' (int or double), so we convert price to double and quantity to int.
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
  // 4. CHANGED: _items is no longer final
  List<CartItem> _items = [];

  // 5. ADDED: New properties for auth and database
  String? _userId; // Will hold the current user's ID
  StreamSubscription? _authSubscription; // To listen to auth changes

  // 6. ADDED: Get Firebase instances
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

  // 7. ADDED CONSTRUCTOR
  CartProvider() {
    print('CartProvider initialized');
    // Listen to authentication changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is logged out
        print('User logged out, clearing cart.');
        _userId = null;
        _items = []; // Clear local cart
      } else {
        // User is logged in
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart(); // Load their cart from Firestore
      }
      // Notify listeners to update UI (e.g., clear cart badge on logout)
      notifyListeners();
    });
  }

  // 8. ADDED: Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return; // Not logged in, nothing to fetch

    try {
      // 1. Get the user's specific cart document
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      
      if (doc.exists && doc.data()!['cartItems'] != null) {
        // 2. Get the list of items from the document
        final List<dynamic> cartData = doc.data()!['cartItems'];
        
        // 3. Convert that list of Maps into our List<CartItem>
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        // 4. The user has no saved cart, start with an empty one
        _items = [];
        print('No saved cart found. Starting empty.');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = []; // On error, default to an empty cart
    }
    notifyListeners(); // Update the UI
  }

  // 9. ADDED: Saves the current local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return; // Not logged in, nowhere to save

    try {
      // 1. Convert our List<CartItem> into a List<Map>
      final List<Map<String, dynamic>> cartData = 
          _items.map((item) => item.toJson()).toList();
      
      // 2. Find the user's document and set the 'cartItems' field
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

    _saveCart(); // 10. ADDED LINE: Persist the change
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    
    _saveCart(); // 11. ADDED LINE: Persist the change
    notifyListeners();
  }

  // 12. ADDED dispose() Method
  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the auth listener to prevent memory leaks
    super.dispose();
  }
}