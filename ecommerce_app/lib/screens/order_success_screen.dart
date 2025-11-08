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
        padding: EdgeInsets.all(32.0),
        child: _OrderSuccessBody(),
      ),
    );
  }
}

class _OrderSuccessBody extends StatelessWidget {
  const _OrderSuccessBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ Success Icon
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 120,
          ),
          const SizedBox(height: 30),

          // ✅ Title
          const Text(
            'Thank You for Your Order!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),

          // ✅ Description
          const Text(
            'Your order has been placed successfully and will be processed shortly. '
            'Check your email for confirmation.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          // ✅ Continue Shopping Button
          _ContinueShoppingButton(),
        ],
      ),
    );
  }
}

class _ContinueShoppingButton extends StatelessWidget {
  const _ContinueShoppingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        // Navigate to Home and clear the previous screens
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      },
      child: const Text(
        'CONTINUE SHOPPING',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
