import 'package:flutter/material.dart';
import '../../controllers/auth/login_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_bottom_nav.dart';

import 'coordinator_dashboard_view.dart';
import 'coordinator_history_view.dart';
import '../profile/userProfile_view.dart';

class MainDashboardCoordinator extends StatefulWidget {
  const MainDashboardCoordinator({super.key});

  @override
  State<MainDashboardCoordinator> createState() =>
      _MainDashboardCoordinatorState();
}

class _MainDashboardCoordinatorState extends State<MainDashboardCoordinator> {
  int _bottomNavIndex = 0;
  final LoginController _authController = LoginController();

  bool _isAuthorized = false;
  bool _isLoading = true;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _checkAuthorizationAndRole();
  }

  /// Mengecek apakah user sudah login dan benar-benar koordinator
  Future<void> _checkAuthorizationAndRole() async {
    try {
      final currentUser = _authController.getCurrentUser();

      if (currentUser == null) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final userData =
          await _authController.getUserDataFromFirestore(currentUser.uid);

      if (userData == null || userData.role != 'coordinator') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied! You must login as a coordinator.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      setState(() {
        _userData = userData;
        _isAuthorized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking authorization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() => _bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Loading saat mengecek akses
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF283593).withOpacity(0.85),
                const Color(0xFF1A237E).withOpacity(0.95)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
              child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // Tampilan Ditolak
    if (!_isAuthorized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF283593).withOpacity(0.85),
                const Color(0xFF1A237E).withOpacity(0.95)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Text('Access Denied',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Wajib true agar background tembus ke bawah navigasi

      // === MENGGUNAKAN INDEXED STACK (Tanpa Animasi Slide) ===
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          CoordinatorDashboardView(
              userData: _userData), // Kirim data user ke Dashboard
          const CoordinatorHistoryView(),
          const UserProfileView(),
        ],
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        middleIcon: Icons.assignment, // Ikon riwayat untuk koordinator
      ),
    );
  }
}
