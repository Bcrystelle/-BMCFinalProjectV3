import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ----------------- ORDER SUCCESS SCREEN -----------------
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Your order has been placed successfully!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Go back to shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- CART SCREEN -----------------
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          // ----------------- CART ITEMS LIST -----------------
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(cartItem.name[0])),
                        title: Text(cartItem.name),
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
                                cart.removeItem(cartItem.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ----------------- TOTAL PRICE CARD -----------------
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

          // ----------------- PLACE ORDER BUTTON -----------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: (_isLoading || cart.items.isEmpty)
                  ? null
                  : () async {
                      if (!mounted) return;

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        await cartProvider.placeOrder();
                        await cartProvider.clearCart();

                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to place order: $e')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
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
