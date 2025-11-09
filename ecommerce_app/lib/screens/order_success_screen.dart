import 'package:flutter/material.dart';

class ContinueShoppingButton extends StatelessWidget {
  const ContinueShoppingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Add your custom styles here (example below)
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        // *** TEMPORARY TEST: Palitan ang HomeScreen ng simpleng Text widget ***
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text(
                  'TEST SUCCESS! GUMANA ANG NAVIGATION!',
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          (Route<dynamic> route) => false,
        );
      },
      child: const Text(
        'Continue Shopping',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
