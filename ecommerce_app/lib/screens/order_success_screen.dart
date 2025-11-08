import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/cart_item.dart'; // Assuming this import path for CartItem

class CartProvider with ChangeNotifier {
  // --- Dependencies ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State Variables ---
  String? _userId;
  List<CartItem> _items = [];

  // --- Getters ---
  List<CartItem> get items => _items;

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  // --- Initialization & Setup ---
  // Method to set the current user ID (must be called on login/auth state change)
  void setUserId(String? userId) {
    _userId = userId;
    // Optionally load cart from Firestore here if persistent cart is desired
    // loadCart(); 
    notifyListeners();
  }

  // --- Core Cart Operations ---

  void addItem(String productId, String title, double price, String imageUrl,
      {int quantity = 1}) {
    // 1. Check if the item already exists in the cart
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      // Item exists: Update quantity
      _items[index].quantity += quantity;
    } else {
      // Item is new: Add new CartItem
      _items.add(CartItem(
        productId: productId,
        title: title,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
      ));
    }
    
    // 2. Persist change to Firestore (if user is logged in)
    if (_userId != null) {
      _updateFirestoreCart();
    }
    
    notifyListeners();
  }

  void removeItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        // Reduce quantity
        _items[index].quantity--;
      } else {
        // Quantity is 1, remove item entirely
        _items.removeAt(index);
      }
    }
    
    // Persist change to Firestore
    if (_userId != null) {
      _updateFirestoreCart();
    }

    notifyListeners();
  }

  // --- Firestore Synchronization (Helper) ---
  Future<void> _updateFirestoreCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData =
          _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to not overwrite other fields
    } catch (e) {
      print('Error updating Firestore cart: $e');
    }
  }
  
  // --- Order Logic (New Methods) ---

  // 1. placeOrder(): Creates an order in the 'orders' collection
  Future<void> placeOrder() async {
    // 2. Check if we have a user and items
    if (_userId == null || _items.isEmpty) {
      // Don't place an order if cart is empty or user is logged out
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
      
      // 7. Note: We DO NOT clear the cart here.
      //    We'll call clearCart() separately from the UI after this succeeds.
      
    } catch (e) {
      print('Error placing order: $e');
      // 8. Re-throw the error so the UI can catch it
      throw e;  
    }
  }

  // 9. clearCart(): Clears the cart locally AND in Firestore
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
}