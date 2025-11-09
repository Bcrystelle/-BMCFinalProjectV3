import 'dart:async';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

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
  
  // New method for cleaner navigation logic
  void _navigateToHome() {
    if (mounted) {
      // 🚀 SOLUSYON: Gagamitin ang pushAndRemoveUntil
      // upang tiyaking ang HomeScreen ang magiging tanging screen 
      // sa navigation stack pagkatapos ng order.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        // Tanggalin ang lahat ng dating routes (tulad ng CartScreen, ProductDetail, etc.)
        (Route<dynamic> route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        // ✅ Aalisin natin ang back arrow
        // para hindi na pwedeng balikan ang CartScreen at maiwasan ang issues.
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
            'Your order has been placed successfully and will be processed shortly.\n'
            'Check your email for confirmation.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          // ✅ Manual Continue Button (optional)
          const _ContinueShoppingButton(),
          const SizedBox(height: 10),

          // ✅ Info about auto redirect
          const Text(
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
        // ✅ Manual navigation back to Home
        // 🚀 SOLUSYON: Ginamit din ang pushAndRemoveUntil dito
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