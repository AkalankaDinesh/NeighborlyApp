import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabhiour_og/firebase/models/user_model.dart';
import '../firebase/auth.dart';
import '../firebase/fire_store_s.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _apartmentNumberController =
      TextEditingController();

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FireStoreS _fireStoreS = FireStoreS();
  final Auth _authService =
      Auth(); //all firebase services create as separated classes.

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _apartmentNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService
          .signUpWithEmailPassword(
            _emailController.text,
            _passwordController.text,
          )
          .whenComplete(() async {
            User? user = await _authService.getSignedUser();
            if (user == null) {
              setState(() {
                // _isSpinKitLoaded = false;
              });
              _showSnackBar('Email already in use.Try another one');
            } else {
              await _fireStoreS
                  .registerUser(
                    UserModel(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                      city: _cityController.text,
                      zipCode: _zipCodeController.text,
                      apartmentNumber: _apartmentNumberController.text,
                    ),
                  )
                  .whenComplete(() async {
                    User? user = await _authService.getSignedUser();
                    setState(() {
                      // _isSpinKitLoaded = false;
                    });
                    _authService.signOut().whenComplete(() {
                      _showSnackBar('Registration successfully. use Login');
                      navigate(user);
                    });
                  });
            }
          });
      //_showSuccessDialog('Account created successfully!');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage =
              'An error occurred during registration. Please try again.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your name');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email');
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      _showErrorDialog('Please enter a valid email address');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your phone number');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your address');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your city');
      return false;
    }
    if (_zipCodeController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your zip code');
      return false;
    }
    if (_apartmentNumberController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your apartment number');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', height: 60),
                    const SizedBox(height: 8),
                    const Text(
                      'NEIGHBORLY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              _buildTextField(
                controller: _nameController,
                hintText: 'Full Name',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              // Email field
              _buildTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone field
              _buildTextField(
                controller: _phoneController,
                hintText: 'Phone Number (e.g., +1 (555) 123-4567)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address field
              _buildTextField(
                controller: _addressController,
                hintText: 'Address (e.g., 123 Main Street)',
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 16),

              // City field
              _buildTextField(
                controller: _cityController,
                hintText: 'City',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Zip Code field
              _buildTextField(
                controller: _zipCodeController,
                hintText: 'Zip Code',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Apartment Number field
              _buildTextField(
                controller: _apartmentNumberController,
                hintText: 'Apartment Number',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Password (minimum 6 characters)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Confirm Password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
              const SizedBox(height: 16),

              // Login text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.pop(context);
                            },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      keyboardType: keyboardType,
      enabled: !_isLoading,
    );
  }

  //this function is used to navigate to the previous screen after successful registration
  void navigate(User? user) {
    if (user != null) {
      Navigator.of(context).pop();
    } else {
      _showSnackBar('Something went wrong. Signup failed.');
    }
  }

  void _showSnackBar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg, style: TextStyle(color: Colors.black)),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.yellow,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
