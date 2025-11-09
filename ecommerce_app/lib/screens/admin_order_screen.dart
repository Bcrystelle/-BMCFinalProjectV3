import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // We'll use this for dates again

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  // 1. Get an instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. This is the function that updates the status in Firestore
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // 3. Find the document and update the 'status' field
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      // Use mounted check before showing SnackBar in async function
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Order status updated!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to update status: $e')),
      );
    }
  }
  
  // 4. This function shows the update dialog
  void _showStatusDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        // 5. A list of all possible statuses
        const statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
        
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the dialog small
            children: statuses.map((status) {
              // 6. Create a button for each status
              return ListTile(
                title: Text(status),
                // 7. Show a checkmark next to the current status
                trailing: currentStatus == status ? const Icon(Icons.check) : null,
                onTap: () {
                  // 8. When tapped:
                  _updateOrderStatus(orderId, status); // Call update
                  Navigator.of(context).pop(); // Close the dialog
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
  
  // The build method starts here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        // 🌟 CORRECTION: AppBar styling properties go here (not styleFrom/onPressed)
        backgroundColor: Colors.indigo, 
        foregroundColor: Colors.white, // Sets the color for the title and icons to white
      ),
      // 1. Use a StreamBuilder to get all orders in real-time
      body: StreamBuilder<QuerySnapshot>(
        // 2. This is our query to get ALL orders, sorted newest first
        stream: _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true) 
            .snapshots(),
            
        builder: (context, snapshot) {
          // 3. Handle all states: loading, error, empty
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          // 4. We have the orders!
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              
              // 5. Format the date
              final Timestamp timestamp = orderData['createdAt'];
              final String formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
                  .format(timestamp.toDate());
              
              // 6. Get the current status
              final String status = orderData['status'] ?? 'Unknown';

              // 7. Build a Card for each order
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    'Order ID: ${order.id}', // Show the document ID
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    // 8. Display user and total price
                    'User: ${orderData['userId']}\n'
                    'Total: ₱${(orderData['totalPrice'] as num).toStringAsFixed(2)} | Date: $formattedDate'
                  ),
                  isThreeLine: true,
                  
                  // 9. Show the status with a colored chip
                  trailing: Chip(
                    label: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    // Use conditional logic for chip color
                    backgroundColor: 
                      status == 'Pending' ? Colors.orange : 
                      status == 'Processing' ? Colors.blue :
                      status == 'Shipped' ? Colors.deepPurple : 
                      status == 'Delivered' ? Colors.green : Colors.red,
                  ),
                  
                  // 10. On tap, show the status update dialog
                  onTap: () {
                    _showStatusDialog(order.id, status);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}