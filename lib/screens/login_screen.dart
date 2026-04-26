import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'search_criteria_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _passwordError;
  String? _emailError;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _emailError = null;
    });
    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        if (_authService.isEmailVerified()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SearchCriteriaScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          String message = 'An error occurred. Please try again.';
          if (e.code == 'user-not-found') {
            message = 'invalid email try again';
            _emailError = 'Invalid email address';
          } else if (e.code == 'wrong-password') {
            message = 'invalid password try again';
            _passwordError = 'Invalid password';
            _passwordController.clear();
          } else if (e.code == 'invalid-credential') {
            message = 'invalid email or password try again';
            _passwordError = 'Invalid email or password';
            _passwordController.clear();
          } else if (e.code == 'invalid-email') {
            message = 'invalid email format';
            _emailError = 'Invalid email format';
          } else {
            message = e.message ?? message;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent! Please check your inbox.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.black),
                ),
              ),
              const SizedBox(height: 64),
              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/login.jpeg',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),
              
              // Email/Phone label
              RichText(
                text: const TextSpan(
                  text: 'Email ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(errorText: _emailError),
              ),
              const SizedBox(height: 40),

              // Password label
              RichText(
                text: const TextSpan(
                  text: 'Password ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInputDecoration(errorText: _passwordError),
              ),
              const SizedBox(height: 4),
              // forget password?
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    'forget password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Login button
              Center(
                child: SizedBox(
                  width: 220,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF424242), // Dark grey
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'login',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? errorText}) {
    return InputDecoration(
      filled: true,
      fillColor: errorText != null ? const Color(0xFFFFEBEE) : const Color(0xFFEBEBEB),
      isDense: true,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      suffixIcon: errorText != null ? const Icon(Icons.error_outline, color: Colors.red) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.black54, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
