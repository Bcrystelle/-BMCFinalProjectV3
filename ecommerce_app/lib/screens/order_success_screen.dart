import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/screens/home_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Auto-redirect to HomeScreen after 3 seconds
    Timer(const Duration(seconds: 3), _navigateToHome);
  }

  /// ✅ Separate method for navigation logic
  void _navigateToHome() {
    if (!mounted) return;

    // Replace current route stack with HomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        // ❌ Remove back arrow (user cannot return to cart or checkout)
        automaticallyImplyLeading: false,
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
        children: const [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 120,
          ),
          SizedBox(height: 30),
          Text(
            'Thank You for Your Order!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Your order has been placed successfully and will be processed shortly.\n'
            'Check your email for confirmation.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          _ContinueShoppingButton(),
          SizedBox(height: 10),
          Text(
            'Redirecting to Home in 3 seconds...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
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
        // ✅ Manual navigation to HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
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
