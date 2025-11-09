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

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(), 
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

 
  List<CartItem> get items => _items;
  String? get userId => _userId; 
  bool get isLoggedIn => _userId != null; 

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

  
  CartProvider() {
    if (kDebugMode) print('CartProvider initialized');
    
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
<<<<<<< HEAD
    
    _saveCart(); 
    notifyListeners();
=======
    notifyListeners(); 
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
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

  
  Future<void> signOut() async {
    try {
      
      await _auth.signOut();
      if (kDebugMode) print("Firebase Auth Sign Out successful.");
    } catch (e) {
      if (kDebugMode) print("Error during Firebase sign out: $e");
      rethrow;
    }
  }

  
  @override
  void dispose() {
    _authSubscription?.cancel(); 
    super.dispose();
  }
}