import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final Color stardewDarkBrown = const Color(0xFF52180E);
  final Color stardewButtonTan = const Color(0xFFF8D387);
  final Color stardewFormBg = const Color(0xFFE1A363).withOpacity(0.5);

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      // Inside AuthPage's _handleAuth function
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Instead of a Navigator.push (which creates a new screen),
        // you can just pop back to the base route if you called this as a sub-page,
        // OR use a callback to change the _selectedIndex in StardewOutline.
        if (mounted) {
          // If you want to force the whole app to refresh and land on Villagers (index 0)
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } else {
        // 2. REGISTER LOGIC
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception("Passwords do not match!");
        }

        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'username': _usernameController.text.trim()},
        );

        // SUCCESS: Show a message and switch to the Login view
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
      backgroundColor: const Color(0xFFF8D387), // stardewTanBody
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEE961E).withOpacity(0.4), // Card background
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

                // AUTH BUTTON
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE961E),
                    side: BorderSide(color: stardewDarkBrown, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(_isLogin ? "Sign In" : "Register", style: TextStyle(color: stardewDarkBrown)),
                ),

                // TOGGLE TEXT
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "Register Here" : "Login Here",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            fillColor: stardewButtonTan,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: stardewDarkBrown, width: 2)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: stardewDarkBrown, width: 3)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        ),
      ],
    );
  }
}