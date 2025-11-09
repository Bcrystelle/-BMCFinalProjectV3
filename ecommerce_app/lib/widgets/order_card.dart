import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class OrderCard extends StatelessWidget {
  // Pass in the entire order data map from Firestore
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    
    // Safely get the Firestore Timestamp
    final Timestamp? timestamp = orderData['createdAt'];
    final String formattedDate;

    if (timestamp != null) {
      // Use DateFormat to convert Timestamp to a readable string
      formattedDate = DateFormat('MM/dd/yyyy - hh:mm a')
          .format(timestamp.toDate());
    } else {
      formattedDate = 'Date not available';
    }

    // Use a Card for a clean, elevated look
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // Use a ListTile for clean, structured content
        child: ListTile(
          // Title: Total Price (emphasized)
          title: Text(
            // Safely cast to double and format to two decimal places
            'Total: ₱${(orderData['totalPrice'] as double).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          
          // Subtitle: Item count and Status
          subtitle: Text(
            'Items: ${orderData['itemCount']}\n'
            'Status: ${orderData['status']}',
          ),
          
          // Trailing: The formatted date
          trailing: Text(
            formattedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          
          // Allows the subtitle to span two lines
          isThreeLine: true,
        ),
      ),
    );
  }
}