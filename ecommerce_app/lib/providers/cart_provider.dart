import 'dart:async'; // 1. ADDED: For StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 2. ADDED: For Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 3. ADDED: For Firestore

// (This is at the top of lib/providers/cart_provider.dart)

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

  // 1. ADDED: A method to convert our CartItem object into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // 2. ADDED: A factory constructor to create a CartItem from a Map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      // Tandaan: Firestore data ay maaaring maging int o double, kaya't
      // tinitiyak natin na ito ay double
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class CartProvider with ChangeNotifier {
  
  // 4. UPDATED: _items is no longer final
  List<CartItem> _items = [];

  // 5. ADDED: New properties for auth and database
  String? _userId; // Will hold the current user's ID
  StreamSubscription? _authSubscription; // To listen to auth changes

  // 6. ADDED: Get Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 7. ADDED: THE CONSTRUCTOR
  CartProvider() {
    debugPrint('CartProvider initialized'); // Pinalitan ang print ng debugPrint
    // Listen to authentication changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is logged out
        debugPrint('User logged out, clearing cart.');
        _userId = null;
        _items = []; // Clear local cart
      } else {
        // User is logged in
        debugPrint('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart(); // Load their cart from Firestore
      }
      // Notify listeners to update UI (e.g., clear cart badge on logout)
      notifyListeners();
    });
  }

  // --- Getters (Unchanged) ---

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

  // --- Core Methods (Updated) ---

  // 8. ADDED: Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return; // Not logged in, nothing to fetch

    try {
      // 1. Get the user's specific cart document
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      
      if (doc.exists && doc.data()?['cartItems'] != null) {
        // 2. Get the list of items from the document
        final List<dynamic> cartData = doc.data()!['cartItems'];
        
        // 3. Convert that list of Maps into our List<CartItem>
        _items = cartData.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
        debugPrint('Cart fetched successfully: ${_items.length} items');
      } else {
        // 4. The user has no saved cart, start with an empty one
        _items = [];
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e'); // Pinalitan ang print ng debugPrint
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
      debugPrint('Cart saved to Firestore'); // Pinalitan ang print ng debugPrint
    } catch (e) {
      debugPrint('Error saving cart: $e'); // Pinalitan ang print ng debugPrint
    }
  }
  
  // 10. UPDATED: Call _saveCart()
  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }

    _saveCart(); // 10. ADDED LINE
    notifyListeners();
  }

  // 11. UPDATED: Call _saveCart()
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    
    _saveCart(); // 11. ADDED LINE
    notifyListeners();
  }

  // 12. ADDED: dispose() Method
  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the auth listener
    super.dispose();
  }
}