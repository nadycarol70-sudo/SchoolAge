import 'package:flutter/material.dart';
import 'thematic_map_screen.dart';
import '../services/auth_service.dart';
import '../services/school_service.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'payment_methods_screen.dart';
import 'search_criteria_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ParentInfoScreen extends StatefulWidget {
  final String? schoolId; // Option to pass school details

  const ParentInfoScreen({super.key, this.schoolId});

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  int _currentIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '01');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  final SchoolService _schoolService = SchoolService();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  String? _phoneError;
  String? _nameError;
  String? _emailError;
  String? _addressError;

  Uint8List? _nationalIdBytes;
  String? _nationalIdFileName;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _nameError = null;
      _phoneError = null;
      _emailError = null;
      _addressError = null;
    });

    bool hasError = false;

    if (_nameController.text.trim().split(' ').length < 2) {
      setState(() => _nameError = 'Please enter at least two names');
      hasError = true;
    }

    if (_phoneController.text.length != 11) {
      setState(() => _phoneError = 'Emergency number must be 11 numbers exactly');
      hasError = true;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      hasError = true;
    }

    if (_addressController.text.isEmpty) {
      setState(() => _addressError = 'Address is required');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isSubmitting = true);

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit application')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      String? nationalIdUrl;
      if (_nationalIdBytes != null) {
        String sanitizeFileName(String name) {
          return name.split(RegExp(r'[\\/]')).last.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_');
        }
        final safeName = sanitizeFileName(_nationalIdFileName ?? 'national_id.png');
        nationalIdUrl = await _schoolService.uploadFile(
          _nationalIdBytes!,
          '${DateTime.now().millisecondsSinceEpoch}_$safeName',
          'applications/national_ids'
        );
      }

      await _schoolService.submitApplication(
        userId: user.uid,
        schoolId: widget.schoolId ?? 'manual_entry',
        studentInfo: {
          'parentName': _nameController.text.trim(),
          'parentPhone': _phoneController.text.trim(),
          'parentEmail': _emailController.text.trim(),
          'homeAddress': _addressController.text.trim(),
          if (nationalIdUrl != null) 'parentNationalIdUrl': nationalIdUrl,
        },
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
              const SizedBox(height: 16),
              const Text(
                'Parent Personal Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              
              // Parent/Guardian Full Name
              _buildLabel('Parent/Guardian Full Name'),
              _buildTextField(
                controller: _nameController,
                errorText: _nameError,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              const SizedBox(height: 24),
              
              // Emergency Phone Number
              _buildLabel('Emergency Phone Number'),
              _buildTextField(
                controller: _phoneController, 
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (!newValue.text.startsWith('01')) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
              ),
              const SizedBox(height: 24),
              
              // Email Address
              _buildLabel('Email Address'),
              _buildTextField(
                controller: _emailController, 
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 24),
              
              // Home Address
              _buildLabel('Home Address'),
              _buildTextField(
                controller: _addressController,
                errorText: _addressError,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              const SizedBox(height: 32),
              
              // Parent's National ID
              _buildLabel('Parent\'s National ID'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 15,
                          maxWidth: 800,
                        );
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          setState(() {
                            _nationalIdBytes = bytes;
                            _nationalIdFileName = image.name;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBEBEB),
                        side: const BorderSide(color: Colors.black, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(0, 36),
                        elevation: 0,
                      ),
                      child: Text(
                        _nationalIdFileName != null ? 'change photo' : 'upload photo',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (_nationalIdFileName != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _nationalIdFileName!,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 64),
              
              // Submit button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 44,
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'submit',
                            style: TextStyle(
                              fontSize: 22,
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
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFD6E6DF),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _currentIndex,
          iconSize: 28,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
            );
          } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchCriteriaScreen()),
              );
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bell),
              activeIcon: Icon(CupertinoIcons.bell_fill),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Map',
          ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus_app),
              activeIcon: Icon(CupertinoIcons.plus_app_fill),
              label: 'Add',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller, 
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEBEBEB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.black54, width: 1.0),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.black, width: 1.5),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}


