import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'admin_dashboard.dart';
import 'victim_home_screen.dart';
import 'volunteer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // State
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRole = 'victim';

  // --- Logic ---
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_isLogin) {
          // 1. LOGIN LOGIC
          User? user = await _authService.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          if (user != null) {
            _checkRoleAndNavigate(user.uid);
          }
        } else {
          // 2. REGISTER LOGIC
          UserModel? newUser = await _authService.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _selectedRole,
            _nameController.text.trim(),
          );

          if (newUser != null) {
            _checkRoleAndNavigate(newUser.uid);
          }
        }
      } catch (e) {
        // Show Error
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _checkRoleAndNavigate(String uid) async {
    UserModel? userModel = await _authService.getUserDetails(uid);

    if (!mounted) return;

    if (userModel != null) {
      if (userModel.role == 'admin') {
        // 1. Admin
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else if (userModel.role == 'volunteer') {
        // 2. Volunteer (NEW!)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VolunteerDashboard()));
      } else {
        // 3. Victim
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VictimHomeScreen()));
      }
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Title
              const Icon(Icons.health_and_safety, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Card Container
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field (Register Only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputStyle("Full Name", Icons.person),
                            validator: (val) =>
                                val!.isEmpty ? "Enter name" : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputStyle("Email", Icons.email),
                          validator: (val) =>
                              val!.isEmpty ? "Enter email" : null,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          decoration: _inputStyle("Password", Icons.lock),
                          obscureText: true,
                          validator: (val) =>
                              val!.length < 6 ? "Min 6 chars" : null,
                        ),
                        const SizedBox(height: 16),

                        // Role Dropdown (Register Only, NO ADMIN option)
                        if (!_isLogin)
                          DropdownButtonFormField(
                            initialValue: _selectedRole,
                            decoration: _inputStyle(
                              "I am a...",
                              Icons.category,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'victim',
                                child: Text("Victim (Need Help)"),
                              ),
                              DropdownMenuItem(
                                value: 'volunteer',
                                child: Text("Volunteer (Give Help)"),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedRole = val.toString()),
                          ),

                        const SizedBox(height: 24),

                        // Main Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    _isLogin ? "LOGIN" : "REGISTER",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle Button
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Styles
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
    );
  }
}
