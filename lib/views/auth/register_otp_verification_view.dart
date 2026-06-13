import 'package:flutter/material.dart';
import 'dart:async';
import '../../controllers/auth/register_controller.dart';
import 'register_password_creation_view.dart';

class RegisterOTPVerificationView extends StatefulWidget {
  final String identity;
  final bool isPhone;
  final RegisterController registerController;

  const RegisterOTPVerificationView({
    super.key,
    required this.identity,
    required this.isPhone,
    required this.registerController,
  });

  @override
  State<RegisterOTPVerificationView> createState() =>
      _RegisterOTPVerificationViewState();
}

class _RegisterOTPVerificationViewState
    extends State<RegisterOTPVerificationView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  late TextEditingController _otpController;
  late List<TextEditingController> _otpDigitControllers;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpDigitControllers =
        List.generate(6, (_) => TextEditingController(), growable: false);
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var controller in _otpDigitControllers) {
      controller.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Mulai countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
        if (_resendCountdown == 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // Verifikasi OTP
  Future<void> _handleVerifyOTP() async {
    // Gabungkan digit OTP
    String otpCode = _otpDigitControllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
      _showErrorSnackBar('Enter 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Email-only verification
    Map<String, dynamic> result = await widget.registerController.verifyEmailOTP(otpCode);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // OTP terverifikasi - navigasi ke halaman pembuatan password
        // Navigate to password creation with email identity
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPasswordCreationView(
              identity: result['email'] ?? widget.identity,
              isPhone: false,
              registerController: widget.registerController,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(result['message']);
      }
    }
  }

  // Kirim ulang OTP
  Future<void> _handleResendOTP() async {
    setState(() {
      _isResending = true;
    });

    // Email-only resend
    Map<String, dynamic> result = await widget.registerController.sendEmailOTP(widget.identity);

    setState(() {
      _isResending = false;
    });

    if (mounted) {
      if (result['success']) {
        // Reset countdown
        setState(() {
          _resendCountdown = 60;
          _canResend = false;
          // Bersihkan field OTP
          for (var controller in _otpDigitControllers) {
            controller.clear();
          }
        });
        _startCountdown();
        _showSuccessSnackBar('Verification code resent');
      } else {
        _showErrorSnackBar(result['message']);
      }
    }
  }

  // Show error SnackBar
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

  // Show success SnackBar
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
        foregroundColor: Colors.white,
        title: const Text('Verify Your Code'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.identity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // OTP Input Fields (6 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _otpDigitControllers[index],
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2C8F),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
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
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          // Auto move to next field
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          // Auto move to previous field on backspace
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Countdown and Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _canResend
                        ? 'Didn\'t receive code?'
                        : 'Resend code in ${_resendCountdown}s', // Email OTP
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _isResending ? null : _handleResendOTP,
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isResending ? Colors.grey : Color(0xFFF88031),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Verify Button
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
                  onPressed: _isLoading ? null : _handleVerifyOTP,
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
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),

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
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Code expires in ${_resendCountdown}s. Please enter it quickly.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Already have account link
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
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
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
    );
  }
}
