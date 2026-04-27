import 'package:flutter/material.dart';
import 'main.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true; // Toggle between Login and Register
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController(); // Optional metadata
  bool _isLoading = false;


  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      // Login Logic
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        //if the user is still on this page, go back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Register logic
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception("Passwords do not match!");
        }

        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'username': _usernameController.text.trim()},
        );

        // Show a message and switch to the Login view
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful! Please Login."),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isLogin = true; // This redirects the UI to the Login form
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stardewTanBody,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: stardewShadow, // Card background
              border: Border.all(color: stardewDarkBrown, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLogin ? "Login" : "Register",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stardewDarkBrown),
                ),
                const SizedBox(height: 20),

                // INPUT FIELDS
                _buildSTextField("Email", _emailController),
                const SizedBox(height: 15),
                //spread operator for spreading fields into the list
                if (!_isLogin) ...[
                  _buildSTextField("Username", _usernameController),
                  const SizedBox(height: 15),
                ],
                _buildSTextField("Password", _passwordController, obscure: true),
                if (!_isLogin) ...[
                  const SizedBox(height: 15),
                  _buildSTextField("Re-enter Password", _confirmPasswordController, obscure: true),
                ],

                const SizedBox(height: 25),

                // Auth button
                _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE961E),
                    side: BorderSide(color: stardewDarkBrown, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                      _isLogin ? "Sign In" : "Register",
                      style: TextStyle(color: stardewDarkBrown)),
                ),

                // login or register
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "Register Here" : "Login Here",
                    style: TextStyle(
                      color: Colors.blue,
                      shadows: [
                        Shadow(color: Colors.grey, offset: Offset(2, 2))
                      ],
                      // decoration: TextDecoration.underline,
                      // decorationColor: Colors.blue,
                      // decorationThickness: 3,
                      fontSize: 20
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //helper function for building fields
  Widget _buildSTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: stardewDarkBrown, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: stardewTanBody,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: stardewDarkBrown, width: 2)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: stardewDarkBrown, width: 3)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        ),
      ],
    );
  }
}