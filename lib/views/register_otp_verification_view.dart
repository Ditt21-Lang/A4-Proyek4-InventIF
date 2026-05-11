import 'package:flutter/material.dart';
import 'dart:async';
import '../../controllers/register_controller.dart';
import '../views/register_password_creation_view.dart';

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

  // Start countdown timer
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

  // Handle verify OTP
  Future<void> _handleVerifyOTP() async {
    // Combine OTP digits
    String otpCode = _otpDigitControllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
      _showErrorDialog('Please enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;
    if (widget.isPhone) {
      result = await widget.registerController.verifyPhoneOTP(otpCode);
    } else {
      result = await widget.registerController.verifyEmailOTP(otpCode);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // OTP verified - navigate ke password creation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPasswordCreationView(
              identity: result['email'] ?? result['phoneNumber'] ?? widget.identity,
              isPhone: widget.isPhone,
              registerController: widget.registerController,
            ),
          ),
        );
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }

  // Handle resend OTP
  Future<void> _handleResendOTP() async {
    setState(() {
      _isResending = true;
    });

    Map<String, dynamic> result;
    if (widget.isPhone) {
      result = await widget.registerController.sendPhoneOTP(widget.identity);
    } else {
      result = await widget.registerController.sendEmailOTP(widget.identity);
    }

    setState(() {
      _isResending = false;
    });

    if (mounted) {
      if (result['success']) {
        // Reset countdown
        setState(() {
          _resendCountdown = 60;
          _canResend = false;
          // Clear OTP fields
          for (var controller in _otpDigitControllers) {
            controller.clear();
          }
        });
        _startCountdown();
        _showSuccessDialog('Verification code sent again');
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.identity}',
                style: TextStyle(
                  fontSize: 14,
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
                        : 'Resend code in ${_resendCountdown}s',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _isResending ? null : _handleResendOTP,
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isResending ? Colors.grey : Colors.blue,
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
                            fontSize: 15,
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
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Code expires in ${_resendCountdown}s. Please enter it quickly.',
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
