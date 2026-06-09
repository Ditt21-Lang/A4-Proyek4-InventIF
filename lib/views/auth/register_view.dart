import 'package:flutter/material.dart';
import '../../controllers/auth/register_controller.dart';
import 'profile_completion_view.dart';
import 'register_otp_verification_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        _showErrorSnackBar('Enter your ${_isPhoneSelected ? 'phone number' : 'email'}');
        return;
      }

    // Validate format
    if (_isPhoneSelected) {
      // Validate phone number (minimum 10 digits)
        if (!RegExp(r'^[+]?[0-9]{10,}$').hasMatch(identity)) {
          _showErrorSnackBar('Invalid phone number format. Use format +62812345678 or 081234567890');
          return;
        }
    } else {
      // Validate email
        if (!RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(identity)) {
          _showErrorSnackBar('Invalid email format');
          return;
        }
      
      // Validate that email is from Polban domain
        if (!identity.toLowerCase().endsWith('@polban.ac.id')) {
          _showErrorSnackBar('Only Polban email (@polban.ac.id) is allowed to register');
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
              isPhone: _isPhoneSelected,
              identity: identity,
              registerController: _registerController,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(result['message']);
      }
    }
  }

  // Mendaftar dengan Google
  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result = await _registerController.signUpWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        if (result['isNewUser']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileCompletionView(
                userData: result['userData'],
              ),
            ),
          );
        } else {
          _showSuccessSnackBar(result['message']);
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        _showErrorSnackBar(result['message']);
      }
    }
  }

  // Tampilkan snackbar error sederhana
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



  // Tampilkan snackbar success sederhana
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF51CF66),
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
            // Dorong konten ke atas setinggi tombol navigasi HP
            bottom: 20.0 + MediaQuery.of(context).padding.bottom, 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Judul Verify Your Identity
              const Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2C8F),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Choose your preferred method to receive verification code',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              // Phone/Email Toggle Buttons
              Row(
                children: [
                  // Phone Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isPhoneSelected = true;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _isPhoneSelected
                              ? Color(0xFFF88031)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: _isPhoneSelected
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 18,
                              color: _isPhoneSelected
                                  ? primaryBlue
                                  : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isPhoneSelected
                                    ? primaryBlue
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Email Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isPhoneSelected = false;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: !_isPhoneSelected
                              ? Color(0xFFF88031)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: !_isPhoneSelected
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: !_isPhoneSelected
                                  ? primaryBlue
                                  : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !_isPhoneSelected
                                    ? primaryBlue
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Label Phone Number / Email
              Text(
                _isPhoneSelected ? 'Phone Number' : 'Email Address',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2C8F),
                ),
              ),
              const SizedBox(height: 8),
              // Input Field
              TextField(
                controller: _identityController,
                enabled: !_isLoading,
                keyboardType: _isPhoneSelected
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _isPhoneSelected
                      ? 'e.g., +62812345678'
                      : 'e.g., your@gmail.com',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    _isPhoneSelected ? Icons.phone : Icons.email_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: primaryBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Info Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:  Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We\'ll send a verification code to verify your ${_isPhoneSelected ? 'phone number' : 'email address'}.',
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
                      borderRadius: BorderRadius.circular(10),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Divider
              Center(
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Google Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 1,
                    side: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2A2C8F),
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                'assets/images/google_icon.png',
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata,
                                    size: 26,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Sign up with Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF88031),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Already have account link
              Center(
                child: Row(
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
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
