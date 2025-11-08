import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: _SuccessContent(),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ Success icon
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 20),

          // ✅ Main title
          const Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // ✅ Description text
          const Text(
            'Your order has been placed successfully.\nYou will receive an email confirmation shortly.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // ✅ Continue shopping button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}
