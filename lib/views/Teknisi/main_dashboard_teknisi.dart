import 'package:flutter/material.dart';
import 'dashboard_teknisi_view.dart';
import 'list_pengajuan_view.dart';
import '../profile/userProfile_view.dart';

class MainDashboardTeknisi extends StatefulWidget {
  const MainDashboardTeknisi({super.key});

  @override
  State<MainDashboardTeknisi> createState() => _MainDashboardTeknisiState();
}

class _MainDashboardTeknisiState extends State<MainDashboardTeknisi> {
  int _bottomNavIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody wajib true agar background gedung Teknisi tembus ke bawah navigasi
      extendBody: true,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: const [
          DashboardTeknisiScreen(),
          ListPengajuanScreen(),
          UserProfileView(), // Halaman profil digunakan kembali di sini!
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
        bottom: 10 +
            MediaQuery.of(context).padding.bottom, // Anti tertutup navigasi HP
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(Icons.home_rounded, 0, 34),
          _buildNavItem(Icons.assignment, 1, 32),
          _buildNavItem(Icons.account_circle_outlined, 2, 38),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, double iconSize) {
    bool isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF78233) : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.black87, size: iconSize),
        ),
      ),
    );
  }
}
