import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  
  final _formKey = GlobalKey<FormState>();

  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  
  bool _isLoading = false;

  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  
  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product uploaded successfully!')),
      );

      
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
    } catch (e) {
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to upload product: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Add a New Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),

              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product description'
                    : null,
              ),
              const SizedBox(height: 12),

              
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter image URL' : null,
              ),
              const SizedBox(height: 20),

              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Product'),
                      onPressed: _uploadProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
