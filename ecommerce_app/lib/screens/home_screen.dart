import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;

<<<<<<< HEAD

    final userUid = _currentUser.uid;
=======
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
<<<<<<< HEAD
          .doc(userUid) 
=======
          .doc(_currentUser.uid) 
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          .get();

      if (doc.exists && doc.data() != null) {
        
        if (!mounted) return; 
        setState(() {
          _userRole = doc.data()!['role'] ?? 'user';
        });
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          
          _currentUser != null ? 'Welcome, ${_currentUser.email}' : 'Home',
        ),
        actions: [
          
<<<<<<< HEAD
          
=======
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

<<<<<<< HEAD

          if (_currentUser != null) 
            IconButton(
              icon: const Icon(Icons.receipt_long), 
              tooltip: 'My Orders',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),

=======
         
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

<<<<<<< HEAD

=======
          
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),

<<<<<<< HEAD

=======
      
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

<<<<<<< HEAD
=======
          
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

<<<<<<< HEAD
=======
          
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

<<<<<<< HEAD
=======
          
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              return ProductCard(
                productName: productData['name'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}