import 'package:flutter/material.dart';
import '../../controllers/auth/register_controller.dart';
import 'register_otp_verification_view.dart';
import 'profile_completion_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);

  bool _isLoading = false;
  late RegisterController _registerController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _registerController = RegisterController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Send OTP (email only)
  Future<void> _handleSendOTP() async {
    String email = _emailController.text.trim();

    // Validate input
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email');
      return;
    }
    // Validate Polban domain
    if (!email.toLowerCase().endsWith('@polban.ac.id')) {
      _showErrorSnackBar(
          'Only Polban email (@polban.ac.id) is allowed to register');
      return;
    }
    // Check if email already exists
    bool exists = await _registerController.isEmailExists(email);
    if (exists) {
      _showErrorSnackBar('Email already registered, please login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Send email OTP
    Map<String, dynamic> result = await _registerController.sendEmailOTP(email);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterOTPVerificationView(
              isPhone: false,
              identity: email,
              registerController: _registerController,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to send OTP');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Your Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 20.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2C8F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your Polban email address to receive a verification code.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2C8F),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'yourEmail@polban.ac.id',
                  hintStyle:
                      TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: Colors.grey, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryBlue, width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              // Info Box (orange, email icon)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryOrange),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.email_outlined,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We\'ll send a verification code to verify your email address.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Send Verification Code Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? primaryOrange.withOpacity(0.6)
                        : primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _handleSendOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2))
                      : const Text('Send Verification Code',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              // Divider
              Center(
                  child: Text('or',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500))),
              const SizedBox(height: 20),
              // Google Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          var result =
                              await _registerController.signUpWithGoogle();
                          setState(() => _isLoading = false);
                          if (mounted) {
                            if (result['success'] &&
                                result['isNewUser'] == true) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileCompletionView(
                                      userData: result['userData']),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ??
                                      'Google sign‑up failed'),
                                  backgroundColor: result['success']
                                      ? const Color(0xFF51CF66)
                                      : const Color(0xFFE53935),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2A2C8F)),
                              strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(
                                      'assets/images/google_icon.png',
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.g_mobiledata,
                                          size: 26))),
                              const SizedBox(width: 10),
                              const Text('Sign up with Google',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF88031))),
                            ]),
                ),
              ),
              const SizedBox(height: 30),
              // Already have account link
              Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Login',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
