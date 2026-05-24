import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../controllers/profile/manageAccount_controller.dart';

class ManageAccountView extends StatefulWidget {
  const ManageAccountView({super.key});

  @override
  State<ManageAccountView> createState() => _ManageAccountViewState();
}

class _ManageAccountViewState extends State<ManageAccountView> {
  final ManageAccountController _controller = ManageAccountController();

  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);
  final Color creamColor = const Color(0xFFFAF0E6);
  final Color navyField = const Color(0xFF1E2070);

  bool _isPersonalInfoExpanded = false;
  bool _isChangePasswordExpanded = false;
  bool _isContactExpanded = false;

  bool _isLoadingPersonalInfo = false;
  bool _isLoadingPassword = false;
  bool _isLoadingContact = false;

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late TextEditingController _identifierController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _birthDateController;
  late TextEditingController _ktmController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String? userName;
  String? userNickname;
  String? userUID;
  String? userProfileImage;
  String? _ktmFileName;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _identifierController = TextEditingController();
    _emailController = TextEditingController();
    _fullNameController = TextEditingController();
    _nicknameController = TextEditingController();
    _birthDateController = TextEditingController();
    _ktmController = TextEditingController();
    _phoneController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _controller.getManageAccountData();
      if (userData != null) {
        setState(() {
          userUID = userData.uid;
          _emailController.text = userData.email;
          userName = userData.fullName;
          userNickname = userData.nickname;
          userProfileImage = userData.profileImage;
          _fullNameController.text = userData.fullName;
          _nicknameController.text = userData.nickname ?? '';
          _ktmController.text = userData.ktm ?? '';
          _birthDateController.text = userData.dateOfBirth ?? '';
          _phoneController.text = userData.phoneNumber ?? '';
        });

        // Check for existing KTM file in document directory (writable location)
        if (userData.uid.isNotEmpty) {
          try {
            final appDocDir = await getApplicationDocumentsDirectory();
            final userFolder =
                Directory('${appDocDir.path}/ktm_files/${userData.uid}');
            if (userFolder.existsSync()) {
              try {
                final files = userFolder.listSync();
                for (var file in files) {
                  if (file is File && file.path.contains('KTM')) {
                    final fileName = file.path.split('/').last;
                    final filePath = file.path;
                    setState(() {
                      _ktmFileName = fileName;
                      _ktmController.text = filePath;
                    });
                    break;
                  }
                }
              } catch (e) {
                print('Error listing KTM files: $e');
              }
            }
          } catch (e) {
            print('Error accessing document directory: $e');
          }
        }

        // Also check from database
        if (userData.ktm != null && userData.ktm!.isNotEmpty) {
          final file = File(userData.ktm!);
          if (file.existsSync()) {
            setState(() {
              _ktmFileName = userData.ktm?.split('/').last ?? '';
              _ktmController.text = userData.ktm ?? '';
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _uploadKTMFile() async {
    if (userUID == null || userUID!.isEmpty) {
      _showErrorSnackBar('User ID not loaded');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate file format - only allow jpg, jpeg, png, pdf
        final validExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
        final fileExtension =
            image.path.substring(image.path.lastIndexOf('.') + 1).toLowerCase();

        if (!validExtensions.contains(fileExtension)) {
          _showErrorSnackBar('Unsupported file format. Use: JPG, PNG, or PDF');
          return;
        }

        final file = File(image.path);
        final fileName = 'KTM.$fileExtension';

        // Create folder path in app's document directory (writable location)
        final appDocDir = await getApplicationDocumentsDirectory();
        final userFolder = Directory('${appDocDir.path}/ktm_files/$userUID');
        if (!userFolder.existsSync()) {
          userFolder.createSync(recursive: true);
        }

        // Copy file to document directory
        final newFilePath = '${userFolder.path}/$fileName';
        final newFile = await file.copy(newFilePath);

        // Save path to database
        final success = await _controller.updatePersonalInfo(
          fullName: _fullNameController.text,
          nickname: _nicknameController.text,
          identifier: _identifierController.text,
          ktm: newFilePath, // Save file path
          birthDate: _birthDateController.text,
        );

        if (success) {
          setState(() {
            _ktmFileName = fileName;
            _ktmController.text = newFilePath;
          });
          _showSuccessSnackBar('KTM file uploaded successfully');
        } else {
          _showErrorSnackBar('Failed to save KTM file path to database');
        }
      }
    } catch (e) {
      print('Error uploading KTM: $e');
      _showErrorSnackBar('Failed to upload file: ${e.toString()}');
    }
  }

  Future<void> _openKTMFile() async {
    if (_ktmController.text.isEmpty) {
      _showErrorSnackBar('No KTM file yet. Please upload first.');
      return;
    }

    try {
      final file = File(_ktmController.text);
      if (file.existsSync()) {
        _showSuccessSnackBar('KTM file found: ${file.path}');
        // TODO: Open file dengan package 'open_file' untuk preview
      } else {
        _showErrorSnackBar('KTM file not found. Path: ${_ktmController.text}');
      }
    } catch (e) {
      print('Error opening KTM: $e');
      _showErrorSnackBar('Failed to open file: ${e.toString()}');
    }
  }

  Future<void> _savePersonalInfo() async {
    setState(() => _isLoadingPersonalInfo = true);
    final success = await _controller.updatePersonalInfo(
      fullName: _fullNameController.text,
      nickname: _nicknameController.text,
      identifier: _identifierController.text,
      ktm: _ktmController.text,
      birthDate: _birthDateController.text,
    );
    setState(() => _isLoadingPersonalInfo = false);
    if (success) {
      _showSuccessSnackBar('Personal info updated successfully');
      setState(() => _isPersonalInfoExpanded = false);
    } else {
      _showErrorSnackBar('Failed to update personal info');
    }
  }

  Future<void> _savePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('New passwords do not match');
      return;
    }
    // Validate password: min 8 chars, uppercase, lowercase, digit
    final password = _newPasswordController.text;
    if (password.length < 8) {
      _showErrorSnackBar('Password must be at least 8 characters');
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showErrorSnackBar('Password must include uppercase letter (A-Z)');
      return;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      _showErrorSnackBar('Password must include lowercase letter (a-z)');
      return;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      _showErrorSnackBar('Password must include a number (0-9)');
      return;
    }
    setState(() => _isLoadingPassword = true);
    final success = await _controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    setState(() => _isLoadingPassword = false);
    if (success) {
      _showSuccessSnackBar('Password changed successfully');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isChangePasswordExpanded = false);
    } else {
      _showErrorSnackBar(
          'Failed to change password. Check your current password');
    }
  }

  Future<void> _saveContact() async {
    setState(() => _isLoadingContact = true);
    final success = await _controller.updateContact(
      email: _emailController.text,
      phoneNumber: _phoneController.text,
    );
    setState(() => _isLoadingContact = false);
    if (success) {
      _showSuccessSnackBar('Contact info updated successfully');
      setState(() => _isContactExpanded = false);
    } else {
      _showErrorSnackBar('Failed to update contact info');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _identifierController.dispose();
    _ktmController.dispose();
    _birthDateController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          // Header (cream background)
          Container(
            color: creamColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: creamColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(4, 4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Greeting - gunakan nickname, jika kosong pakai fullName
                Expanded(
                  child: Text(
                    'Hello, ${(userNickname != null && userNickname!.isNotEmpty) ? userNickname : userName}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Profile photo
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFE0E0E0), width: 2),
                  ),
                  child: ClipOval(
                    child: userProfileImage != null && userProfileImage!.isNotEmpty
                        ? Image.network(
                            userProfileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.grey, size: 24),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey, size: 24),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content (blue background)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: 20 + MediaQuery.of(context).padding.bottom, 
              ),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Personal Info',
                    icon: Icons.person_outline,
                    isExpanded: _isPersonalInfoExpanded,
                    onToggle: () => setState(() =>
                        _isPersonalInfoExpanded = !_isPersonalInfoExpanded),
                    children: [
                      _buildNavyField(
                        label: 'Fullname',
                        controller: _fullNameController,
                        suffixIcon: Icons.edit,
                      ),
                      _buildNavyField(
                        label: 'Nickname',
                        controller: _nicknameController,
                        suffixIcon: Icons.edit,
                      ),
                      _buildNavyField(
                        label: 'NIM',
                        controller: _identifierController,
                        suffixIcon: Icons.edit,
                      ),
                      _buildKtmField(),
                      _buildNavyField(
                        label: 'Birth Date',
                        controller: _birthDateController,
                        suffixIcon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildSaveButton(
                        label: 'Save Changes',
                        isLoading: _isLoadingPersonalInfo,
                        onPressed: _savePersonalInfo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: 'Change Password',
                    icon: Icons.shopping_bag_outlined,
                    isExpanded: _isChangePasswordExpanded,
                    onToggle: () => setState(() =>
                        _isChangePasswordExpanded = !_isChangePasswordExpanded),
                    children: [
                      _buildCurrentPasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        label: 'New Password',
                        hint:
                            '*password must be at least 8 character with uppercase (A-Z),\nlowercase (a-z) and number (0-9)',
                        controller: _newPasswordController,
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        hint:
                            '*password must be at least 8 character with uppercase (A-Z),\nlowercase (a-z) and number (0-9)',
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 14),
                      _buildSaveButton(
                        label: 'Save Changes',
                        isLoading: _isLoadingPassword,
                        onPressed: _savePassword,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: 'Contact',
                    icon: Icons.email_outlined,
                    isExpanded: _isContactExpanded,
                    onToggle: () => setState(
                        () => _isContactExpanded = !_isContactExpanded),
                    children: [
                      _buildContactField(
                        label: 'Email',
                        controller: _emailController,
                      ),
                      _buildContactField(
                        label: 'Phone Number',
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 14),
                      _buildSaveButton(
                        label: 'Update Contact',
                        isLoading: _isLoadingContact,
                        onPressed: _saveContact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section (collapsed & expanded)
  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: onToggle,
            child: Container(
              color: creamColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: primaryOrange, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryOrange,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.arrow_forward_ios,
                    color: primaryOrange,
                    size: isExpanded ? 24 : 18,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (isExpanded)
            Container(
              width: double.infinity,
              color: primaryOrange,
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  // Navy input field (Personal Info)
  Widget _buildNavyField({
    required String label,
    required TextEditingController controller,
    IconData? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: navyField,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (suffixIcon != null)
            Icon(suffixIcon, color: primaryOrange, size: 18),
        ],
      ),
    );
  }

  // KTM field with Upload & Open File buttons
  Widget _buildKtmField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: navyField,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KTM',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // Upload & Open File buttons row
          Row(
            children: [
              // Upload button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _uploadKTMFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.upload_outlined,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Open File button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _openKTMFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: primaryOrange, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.folder_open_outlined,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Open File',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // File status
          Text(
            _ktmFileName != null && _ktmFileName!.isNotEmpty
                ? 'File: $_ktmFileName'
                : 'No file uploaded',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Password field
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: navyField,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF888888),
                  ),
                ),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Current Password field (masked, no eye icon)
  Widget _buildCurrentPasswordField({
    required String label,
    required TextEditingController controller,
  }) {
    // Create masked representation of current password
    String maskedPassword =
        controller.text.isNotEmpty ? '*' * controller.text.length : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: navyField,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // Contact field with Verify button
  Widget _buildContactField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: navyField,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: verify logic
            },
            child: Text(
              'Verify',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Save / Update button
  Widget _buildSaveButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: creamColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryOrange,
                  ),
                ),
        ),
      ),
    );
  }
}
