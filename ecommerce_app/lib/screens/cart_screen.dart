import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart'; // Import for navigation

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  
  // State variable for the loading spinner on the button
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the cart state
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(cartItem.title[0]), 
                        ),
                        title: Text(cartItem.title), 
                        subtitle: Text('Qty: ${cartItem.quantity} | Total: ₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Call the removeItem logic
                              cart.removeItem(cartItem.productId); 
                            },
                          ),
                      );
                    },
                  ),
          ),
          
          // Total Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₱${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          
          // Place Order Button (New Logic)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), 
              ),
              
              // Button is disabled if loading OR if the cart is empty
              onPressed: (_isLoading || cart.items.isEmpty) ? null : () async {
                setState(() {
                  _isLoading = true; // Start loading
                });

                try {
                  // Get provider without listening
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  
                  // 1. Place the order in Firestore
                  await cartProvider.placeOrder();
                  // 2. Clear the cart (local state and Firestore cart document)
                  await cartProvider.clearCart();
                  
                  // 3. Navigate to the success screen and clear the navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                    (route) => false,
                  );

                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to place order: ${e.toString()}')),
                  );
                } finally {
                  // Stop loading, regardless of success or failure
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              
              // Button content (Spinner or Text)
              child: _isLoading 
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Place Order', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}