import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'search_criteria_screen.dart';
import 'welcome_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isVerified = _authService.isEmailVerified();

    if (!_isVerified) {
      _sendVerificationEmail();
      
      // Periodically check if email is verified
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending email: $e')),
        );
      }
    }
  }

  Future<void> _checkEmailVerified() async {
    await _authService.reloadUser();
    
    if (_authService.isEmailVerified()) {
      _timer?.cancel();
      if (mounted) {
        setState(() => _isVerified = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SearchCriteriaScreen()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 100, color: Color(0xFF2C2C2C)),
              const SizedBox(height: 32),
              const Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A verification link has been sent to your email. Please click the link to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 48),
              if (!_isVerified) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const Text(
                  'Waiting for verification...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ] else ...[
                const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Email Verified! Redirecting...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: _sendVerificationEmail,
                child: const Text('Resend Email', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  _authService.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
                child: const Text('Cancel / Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
