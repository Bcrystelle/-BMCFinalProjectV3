import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart'; // 1. ADD THIS

// 2. Change this to a StatefulWidget
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  // 3. Create the State
  State<CartScreen> createState() => _CartScreenState();
}

// 4. Rename the class to _CartScreenState
class _CartScreenState extends State<CartScreen> {
  
  // 5. Add our loading state variable
  bool _isLoading = false;

  // 6. Move the build method inside here
  @override
  Widget build(BuildContext context) {
    // 1. This line is the same
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
                          // NOTE: Assumed 'name' should be 'title' based on your CartProvider logic
                          child: Text(cartItem.title[0]), 
                        ),
                        // NOTE: Assumed 'name' should be 'title'
                        title: Text(cartItem.title), 
                        subtitle: Text('Qty: ${cartItem.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            Text(
                              '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                            ),
                            
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // NOTE: Assumed 'id' should be 'productId'
                                cart.removeItem(cartItem.productId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          
          // 3. The "Total" Card is the same
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          // 4. --- ADD THIS NEW BUTTON ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Wide button
              ),
              
              // 5. Disable button if loading OR if cart is empty
              onPressed: (_isLoading || cart.items.isEmpty) ? null : () async {
                // 6. Start the loading spinner
                setState(() {
                  _isLoading = true;
                });

                try {
                  // 7. Get provider (listen: false is for functions)
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  
                  // 8. Call our new methods
                  await cartProvider.placeOrder();
                  await cartProvider.clearCart();
                  
                  // 9. Navigate to success screen and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                    (route) => false,
                  );

                } catch (e) {
                  // 10. Show error if placeOrder() fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to place order: ${e.toString()}')),
                  );
                } finally {
                  // 11. ALWAYS stop the spinner
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              
              // 12. Show spinner or text based on loading state
              child: _isLoading 
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Place Order', style: TextStyle(fontSize: 18)),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}