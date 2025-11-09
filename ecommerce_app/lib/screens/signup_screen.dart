import 'package:ecommerce_app/screens/login_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  bool _isLoading = false;

  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    
    setState(() {
      _isLoading = true;
    });

    try {
      
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

<<<<<<< HEAD
      
=======
      // ⚠️ FIX: Check mounted state after the first await
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      if (!mounted) return; 

      
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'role': 'user', 
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

<<<<<<< HEAD
      
=======
      // ⚠️ FIX: Check mounted state after the second await (Firestore set)
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      if (!mounted) return;

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      
<<<<<<< HEAD
      
=======
      // No need for 'if (mounted)' here since we already checked above
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      
<<<<<<< HEAD
     
=======
      // ⚠️ FIX: Check mounted state before using context
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      if (!mounted) return;

      String message = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      
<<<<<<< HEAD
     
      if (!mounted) return;

      debugPrint('Unexpected error: $e'); 
=======
      // ⚠️ FIX: Check mounted state before using context
      if (!mounted) return;

      debugPrint('Unexpected error: $e'); // ✅ FIX: Changed 'print' to 'debugPrint'
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      
<<<<<<< HEAD
      
=======
      // This is correct: setState is inside an 'if (mounted)' check
>>>>>>> 696d4c296bf00fdb54be5ad28b6a3d861154c71d
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 10),

              
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}