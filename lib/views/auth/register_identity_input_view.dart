import 'package:flutter/material.dart';
import '../../controllers/auth/register_controller.dart';
import 'register_otp_verification_view.dart';

class RegisterIdentityInputView extends StatefulWidget {
  const RegisterIdentityInputView({super.key});

  @override
  State<RegisterIdentityInputView> createState() =>
      _RegisterIdentityInputViewState();
}

class _RegisterIdentityInputViewState extends State<RegisterIdentityInputView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);

  bool _isLoading = false;
  bool _isPhoneSelected = true;
  late RegisterController _registerController;
  late TextEditingController _identityController;

  @override
  void initState() {
    super.initState();
    _registerController = RegisterController();
    _identityController = TextEditingController();
  }

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  // Send OTP
  Future<void> _handleSendOTP() async {
    String identity = _identityController.text.trim();

    // Validate if input is empty
    if (identity.isEmpty) {
      _showErrorDialog('Enter your ${_isPhoneSelected ? 'phone number' : 'email'}');
      return;
    }

    // Validate format
    if (_isPhoneSelected) {
      // Validate phone number (minimum 10 digits)
      if (!RegExp(r'^[+]?[0-9]{10,}$').hasMatch(identity)) {
        _showErrorDialog('Invalid phone number format. Use format +62812345678 or 081234567890');
        return;
      }
    } else {
      // Validate email
      if (!RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
          .hasMatch(identity)) {
        _showErrorDialog('Invalid email format');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;
    if (_isPhoneSelected) {
      result = await _registerController.sendPhoneOTP(identity);
    } else {
      result = await _registerController.sendEmailOTP(identity);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Navigasi ke halaman verifikasi OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterOTPVerificationView(
              identity: identity,
              isPhone: _isPhoneSelected,
              registerController: _registerController,
            ),
          ),
        );
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }

  // Tampilkan dialog error dengan design yang menarik
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan background merah
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Oops!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Message
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                  ),
                  // Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Create Your Account'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_gedung.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Verify Your Identity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred method to receive verification code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Toggle Buttons (Phone / Email)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        // Phone Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPhoneSelected = true;
                                      _identityController.clear();
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isPhoneSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    size: 18,
                                    color: _isPhoneSelected
                                        ? primaryBlue
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Phone',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isPhoneSelected
                                          ? primaryBlue
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Email Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPhoneSelected = false;
                                      _identityController.clear();
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isPhoneSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 18,
                                    color: !_isPhoneSelected
                                        ? primaryBlue
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: !_isPhoneSelected
                                          ? primaryBlue
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPhoneSelected
                            ? 'Phone Number'
                            : 'Email Address',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A2C8F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _identityController,
                        enabled: !_isLoading,
                        keyboardType: _isPhoneSelected
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2A2C8F),
                        ),
                        decoration: InputDecoration(
                          hintText: _isPhoneSelected
                              ? 'e.g., +62812345678'
                              : 'e.g., user@example.com',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            _isPhoneSelected ? Icons.phone : Icons.email,
                            color: primaryBlue,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'We\'ll send a verification code to verify your ${_isPhoneSelected ? 'phone number' : 'email'}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? primaryOrange.withOpacity(0.6)
                            : primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleSendOTP,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send Verification Code',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Google Sign Up Option
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'or',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // Google Sign Up Button bisa ditambah di sini jika diperlukan

                  const SizedBox(height: 20),
                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
