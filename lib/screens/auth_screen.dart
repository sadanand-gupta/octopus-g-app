import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true; // Toggle between login and signup

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _userController = TextEditingController(); // Only for signup

  bool isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    String? error;

    if (isLogin) {
      error = await auth.signIn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } else {
      error = await auth.signUp(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        username: _userController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Welcome Back' : 'Create Account',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (!isLogin)
                        TextFormField(
                          controller: _userController,
                          decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
                          validator: (v) => v!.isEmpty ? 'Username required' : null,
                        ),
                      if (!isLogin) const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        validator: (v) => !v!.contains('@') ? 'Invalid Email' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passController,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A11CB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isLogin ? 'LOGIN' : 'SIGN UP'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin ? 'New here? Sign Up' : 'Already have account? Login'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}