import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// === 1. CART ITEM MODEL ===
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

  /// Converts the CartItem to a Firestore-friendly JSON format
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  /// Creates a CartItem from Firestore data
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'];
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: priceValue is int ? priceValue.toDouble() : priceValue ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

/// === 2. CART PROVIDER ===
/// Handles cart logic, syncs with Firestore, and listens for user changes.
class CartProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription<User?>? _authSubscription;

  /// Constructor sets up an auth listener
  CartProvider() {
    debugPrint('🛒 CartProvider initialized. Setting up auth listener...');
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // === 3. GETTERS ===
  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (totalSum, item) => totalSum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (totalSum, item) => totalSum + (item.price * item.quantity));

  // === 4. AUTH STATE CHANGE HANDLER ===
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      debugPrint('🚪 User logged out → clearing cart.');
      _userId = null;
      _items = [];
    } else {
      debugPrint('👤 User logged in: ${user.uid}. Fetching cart...');
      _userId = user.uid;
      await _fetchCart();
    }
    notifyListeners();
  }

  // === 5. FIRESTORE OPERATIONS ===

  /// Fetch the user's saved cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()?['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items =
            cartData.map((data) => CartItem.fromJson(data)).toList(growable: true);
        debugPrint('✅ Cart fetched: ${_items.length} items.');
      } else {
        _items = [];
        debugPrint(' No saved cart found. Starting with empty cart.');
      }
    } catch (e) {
      debugPrint('❌ Error fetching cart: $e');
      _items = [];
    }

    notifyListeners();
  }

  /// Save the current cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final cartData = _items.map((item) => item.toJson()).toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      debugPrint('💾 Cart saved to Firestore.');
    } catch (e) {
      debugPrint('❌ Error saving cart: $e');
    }
  }

  // === 6. PUBLIC CART METHODS ===

  void addItem(String id, String name, double price) {
    final index = _items.indexWhere((item) => item.id == id);

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

  // === 7. ORDER METHODS ===

  /// Place the order → creates new Firestore document under "orders"
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cannot place order: No user or empty cart.');
    }

    try {
      await _firestore.collection('orders').add({
        'userId': _userId,
        'amount': totalPrice,
        'dateTime': Timestamp.now(),
        'items': _items.map((i) => i.toJson()).toList(),
      });

      debugPrint('✅ Order placed successfully.');
    } catch (e) {
      debugPrint('❌ Failed to place order: $e');
      rethrow; // Allow UI to handle the error
    }
  }

  /// Clears both local and Firestore cart
  Future<void> clearCart() async {
    if (_userId == null) return;

    _items.clear();
    notifyListeners();

    try {
      await _firestore.collection('userCarts').doc(_userId).delete();
      debugPrint('🧹 Cart cleared from Firestore.');
    } catch (e) {
      debugPrint('⚠️ Error clearing cart from Firestore: $e');
    }
  }

  // === 8. CLEANUP ===
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
