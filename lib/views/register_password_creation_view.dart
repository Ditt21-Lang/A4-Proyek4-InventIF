import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';
import '../views/profile_completion_view.dart';

class RegisterPasswordCreationView extends StatefulWidget {
  final String identity;
  final bool isPhone;
  final RegisterController registerController;

  const RegisterPasswordCreationView({
    super.key,
    required this.identity,
    required this.isPhone,
    required this.registerController,
  });

  @override
  State<RegisterPasswordCreationView> createState() =>
      _RegisterPasswordCreationViewState();
}

class _RegisterPasswordCreationViewState
    extends State<RegisterPasswordCreationView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle create account
  Future<void> _handleCreateAccount() async {
    // Validasi input
    if (_fullNameController.text.isEmpty) {
      _showErrorDialog('Please enter your full name');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Please enter a password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create account dengan email dan password
    Map<String, dynamic> result =
        await widget.registerController.createAccountAfterOTPVerification(
      email: widget.identity,
      password: _passwordController.text,
      fullName: _fullNameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Account created - navigate ke profile completion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileCompletionView(
              userData: result['userData'],
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Create Your Account'),
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
                'Complete Your Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your password and enter your name to complete signup',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Full Name Field
              _buildTextField(
                label: 'Full Name',
                controller: _fullNameController,
                hintText: 'e.g., John Doe',
                prefixIcon: Icons.person,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Minimum 6 characters',
                prefixIcon: Icons.lock,
                enabled: !_isLoading,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              _buildTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock,
                enabled: !_isLoading,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleObscure: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Password requirements info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Password Requirements:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Minimum 6 characters\n• Use mix of letters and numbers\n• Keep it secure!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Create Account Button
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
                  onPressed: _isLoading ? null : _handleCreateAccount,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

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
                            // Navigate back to login (pop all registration screens)
                            Navigator.pop(context);
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
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool enabled = true,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2C8F),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword && obscureText,
          keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2A2C8F),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: primaryBlue,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
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
    );
  }
}
