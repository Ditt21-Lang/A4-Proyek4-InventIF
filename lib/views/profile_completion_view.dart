import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';
import '../models/user_model.dart';
import './userProfile_view.dart';

class ProfileCompletionView extends StatefulWidget {
  final UserModel userData;

  const ProfileCompletionView({
    super.key,
    required this.userData,
  });

  @override
  State<ProfileCompletionView> createState() => _ProfileCompletionViewState();
}

class _ProfileCompletionViewState extends State<ProfileCompletionView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);

  bool _isLoading = false;
  bool _showNotification = true;

  late RegisterController _registerController;
  late TextEditingController _nicknameController;
  late TextEditingController _identifierController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _registerController = RegisterController();
    _nicknameController = TextEditingController(text: widget.userData.nickname ?? '');
    _identifierController = TextEditingController(text: widget.userData.identifier ?? '');
    _dateOfBirthController = TextEditingController(text: widget.userData.dateOfBirth ?? '');
    _phoneNumberController = TextEditingController(text: widget.userData.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _identifierController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Handle update profile
  Future<void> _handleUpdateProfile() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result = await _registerController.updateUserProfile(
      uid: widget.userData.uid,
      nickname: _nicknameController.text,
      identifier: _identifierController.text,
      dateOfBirth: _dateOfBirthController.text,
      phoneNumber: _phoneNumberController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        _showSuccessDialog(result['message']);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileView()),
            );
          }
        });
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }

  // Skip update profile
  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserProfileView()),
    );
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
        title: const Text('Complete Your Profile'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: 100.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info notification
                  if (_showNotification)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complete your profile to unlock all features. You can skip this for now.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showNotification = false;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Greeting
                  Text(
                    'Hello, ${widget.userData.fullName}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2C8F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s complete your profile information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Nickname Field
                  _buildTextFieldWithLabel(
                    label: 'Nickname (optional)',
                    controller: _nicknameController,
                    hintText: 'e.g., Budi, Ahmad',
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Identifier (NIM/Employee ID) Field
                  _buildTextFieldWithLabel(
                    label: 'Identifier (NIM for Students / NIP for Employees)',
                    controller: _identifierController,
                    hintText: 'e.g., 2023001234 for NIM or NIP format',
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth Field
                  _buildTextFieldWithLabel(
                    label: 'Date of Birth (optional)',
                    controller: _dateOfBirthController,
                    hintText: 'e.g., 01/05/2000',
                    enabled: !_isLoading,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _dateOfBirthController.text =
                            '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  _buildTextFieldWithLabel(
                    label: 'Phone Number (optional)',
                    controller: _phoneNumberController,
                    hintText: 'e.g., +62812345678',
                    enabled: !_isLoading,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 Tip: Complete your profile now to avoid seeing the notification later.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button Bar at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Skip Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: BorderSide(
                            color: primaryBlue.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleUpdateProfile,
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
                                'Save',
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
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onTap: onTap,
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
