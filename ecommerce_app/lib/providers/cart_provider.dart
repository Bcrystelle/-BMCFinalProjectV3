import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

// --- 1. CART ITEM MODEL ---
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
      price: (json['price'] as num).toDouble(), 
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

// --- 2. CART PROVIDER ---
class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId; 
  StreamSubscription? _authSubscription; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Getters ---
  List<CartItem> get items => _items;
  String? get userId => _userId; // Added from first snippet
  bool get isLoggedIn => _userId != null; // Added from first snippet

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

  // --- CONSTRUCTOR: Handles Auth State Changes ---
  CartProvider() {
    if (kDebugMode) print('CartProvider initialized');
    // Awtomatikong nag-fe-fetch o nagli-linis ng cart base sa login state.
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) print('User logged out, clearing local cart.');
        _userId = null;
        _items = []; 
      } else {
        if (kDebugMode) print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart(); 
      }
      notifyListeners();
    });
  }

  // --- CORE FIRESTORE LOGIC ---

  // Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return; 

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        if (kDebugMode) print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
        if (kDebugMode) print('No saved cart found. Starting empty.');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching cart: $e');
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
      if (kDebugMode) print('Cart saved to Firestore');
    } catch (e) {
      if (kDebugMode) print('Error saving cart: $e');
    }
  }
  
  // --- USER ACTION METHODS ---

  void addItem(String id, String name, double price) {
    if (_userId == null) {
      throw Exception("User not logged in. Cannot add item to cart.");
    }
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

  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData = 
          _items.map((item) => item.toJson()).toList();
      
      final double total = totalPrice;
      final int count = itemCount;

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData, 
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending', 
        'createdAt': FieldValue.serverTimestamp(), 
      });
      
      if (kDebugMode) print('Order placed successfully for user $_userId');
      
      // Clear the cart after placing the order
      await clearCart(); 
      
    } catch (e) {
      if (kDebugMode) print('Error placing order: $e');
      rethrow; 
    }
  }

  Future<void> clearCart() async {
    _items = [];
    
    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        if (kDebugMode) print('Firestore cart cleared.');
      } catch (e) {
        if (kDebugMode) print('Error clearing Firestore cart: $e');
      }
    }
    
    notifyListeners();
  }

  // --- LOGOUT FUNCTIONALITY (GUMAGAMIT NG FIREBASE AUTH) ---
  Future<void> signOut() async {
    try {
      // Tanging ang pagtawag lang sa Firebase Auth signOut() ang kailangan.
      // Awtomatikong magli-linis ang CartProvider dahil sa _authSubscription.
      await _auth.signOut();
      if (kDebugMode) print("Firebase Auth Sign Out successful.");
    } catch (e) {
      if (kDebugMode) print("Error during Firebase sign out: $e");
      rethrow; // Re-throw para ma-handle ng UI
    }
  }

  // --- DISPOSE METHOD ---
  @override
  void dispose() {
    _authSubscription?.cancel(); 
    super.dispose();
  }
}