import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import ng bagong screen para sa navigation. 
// Palitan ang path nito kung saan mo talaga inilagay ang OrderSuccessScreen.
// Para sa kumpletong code, gumawa ako ng simple placeholder sa ibaba.
// import 'package:ecommerce_app/screens/order_success_screen.dart'; 

// === 1. GAWING STATEFUL WIDGET ANG CARTSCREEN ===
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Ang variable na ito ang magko-control sa loading spinner ng button
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // 1. Kukunin ang CartProvider instance
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          
          // === CART ITEMS LIST ===
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(cartItem.name[0]),
                        ),
                        title: Text(cartItem.name),
                        subtitle: Text('Qty: ${cartItem.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                            ),
                            
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Tumatakbo ang removeItem() at nagse-save sa Firestore
                                cart.removeItem(cartItem.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // === TOTAL PRICE CARD ===
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
          
          // 2. === ADD NEW PLACE ORDER BUTTON ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Wide button
              ),
              
              // 3. Disable button kung loading o kung empty ang cart
              onPressed: (_isLoading || cart.items.isEmpty) ? null : () async {
                // 4. Simulan ang loading spinner
                setState(() {
                  _isLoading = true;
                });

                try {
                  // 5. Kumuha ng provider instance (LISTEN: FALSE!)
                  // Kailangan itong gawin para sa async functions
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  
                  // Tandaan: Dapat mayroon kang 'placeOrder()' at 'clearCart()' 
                  // methods sa iyong CartProvider para gumana ito!

                  // 6. Tumawag sa order methods
                  await cartProvider.placeOrder(); // I-save ang order sa Firestore
                  await cartProvider.clearCart(); // I-clear ang local at Firestore cart
                  
                  // 7. Mag-navigate sa success screen at i-clear ang navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                    (route) => false,
                  );

                } catch (e) {
                  // 8. Magpakita ng error kung may naganap na problema
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to place order: $e')),
                  );
                } finally {
                  // 9. Itigil ang spinner, kahit may error
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              
              // 10. Magpakita ng spinner o text
              child: _isLoading 
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'PLACE ORDER',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// === PLACEHOLDER: ORDER SUCCESS SCREEN ===
// Kailangan mo ito para gumana ang Navigator.of(context).pushAndRemoveUntil
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Placed!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text('Your order has been placed successfully!', 
              style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Go back to shopping'),
            )
          ],
        ),
      ),
    );
  }
}