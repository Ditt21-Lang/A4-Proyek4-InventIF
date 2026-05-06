import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);
  final Color creamColor = const Color(0xFFFAF0E6);

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  late LoginController _loginController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login
  Future<void> _handleLogin() async {
    // Validasi input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email and password are required!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Panggil login controller
    Map<String, dynamic> result = await _loginController.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Login berhasil
        _showSuccessDialog(result['message']);
        // TODO: Navigate ke halaman home
        // Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Login gagal
        _showErrorDialog(result['message']);
      }
    }
  }

  // Show error dialog
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

  // Show success dialog
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

  // Show info dialog
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background Image
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

          // 2. Kotak Login yang Lebih Ramping
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.90),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 15.0, // Dikurangi dari 25.0
                    bottom: 25.0, // Dikurangi dari 40.0
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Garis "Grabber" di atas
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20), // Dikurangi dari 30
                      // Judul
                      const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Dikurangi dari 28
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15), // Dikurangi dari 25
                      // Field Email
                      TextField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12, // Dikurangi dari 16
                          ),
                        ),
                      ),
                      const SizedBox(height: 12), // Dikurangi dari 15
                      // Field Password
                      TextField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12, // Dikurangi dari 16
                          ),
                          suffixIcon: IconButton(
                            iconSize: 20, // Ukuran ikon diperkecil
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      // Row Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.8, // Mengecilkan ukuran checkbox
                                child: Checkbox(
                                  value: _rememberMe,
                                  side: const BorderSide(color: Colors.white54),
                                  activeColor: primaryOrange,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                ),
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11, // Dikurangi dari 12
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_emailController.text.isEmpty) {
                                      _showErrorDialog(
                                          'Please enter your email first!');
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    Map<String, dynamic> result =
                                        await _loginController
                                            .sendPasswordResetEmail(
                                      _emailController.text,
                                    );

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (mounted) {
                                      if (result['success']) {
                                        _showSuccessDialog(result['message']);
                                      } else {
                                        _showErrorDialog(result['message']);
                                      }
                                    }
                                  },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11, // Dikurangi dari 12
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10), // Dikurangi dari 20
                      // Tombol Log In
                      SizedBox(
                        width: double.infinity,
                        height: 45, // Dikurangi dari 50
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? primaryOrange.withOpacity(0.6)
                                : primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15), // Dikurangi dari 20
                      // Footer Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New Account? ",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    // TODO: Navigate ke halaman register
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         const RegisterView(),
                                    //   ),
                                    // );
                                    _showInfoDialog(
                                        'Register feature will be available soon');
                                  },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
