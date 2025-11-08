import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// === 1. CART ITEM MODEL ===
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

  // Gagamitin para i-convert ang CartItem sa Map (para sa Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Gagamitin para gumawa ng CartItem galing sa Map (galing sa Firestore)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Tiyaking tama ang pag-handle ng price (int to double)
    final priceValue = json['price'];
    final quantityValue = json['quantity'] ?? 1; // Default to 1 if null

    return CartItem(
      id: json['id'],
      name: json['name'],
      price: priceValue is int ? (priceValue).toDouble() : priceValue, 
      quantity: quantityValue,
    );
  }
}

// ---

// === 2. CART PROVIDER (The Brain) ===
class CartProvider with ChangeNotifier {
  // Properties para sa local state at Firebase
  List<CartItem> _items = []; // Hindi na final
  String? _userId; 
  StreamSubscription? _authSubscription; 

  // Instances ng Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CONSTRUCTOR: Nagsisimula ng Authentication Listener
  CartProvider() {
    print('CartProvider initialized: Setting up Auth Listener');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // Logged out
        print('User logged out, clearing local cart.');
        _userId = null;
        _items = []; 
      } else {
        // Logged in
        print('User logged in: ${user.uid}. Starting cart fetch...');
        _userId = user.uid;
        _fetchCart(); 
      }
      notifyListeners();
    });
  }

  // === GETTERS ===
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
  
  // === FIREBASE HELPER METHODS ===

  // Kukuha ng cart galing sa Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return; 

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        
        // Convert List<Map> to List<CartItem>
        _items = cartData.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
        print('No saved cart found. Starting with empty list.');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = []; 
    }
    notifyListeners(); 
  }

  // Ise-save ang local cart sa Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return; 

    try {
      // Convert List<CartItem> to List<Map>
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

  // === MUTATOR METHODS (Public) ===

  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }

    _saveCart(); // Sync sa Firestore pagkatapos magbago
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    
    _saveCart(); // Sync sa Firestore pagkatapos magbago
    notifyListeners(); 
  }

  // ... Maaari ka ring magdagdag ng updateQuantity o clearCart methods dito ...

  // === DISPOSE METHOD ===
  @override
  void dispose() {
    _authSubscription?.cancel(); // Kinakailangan para iwasan ang memory leak
    super.dispose();
  }
}