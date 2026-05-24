import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap; // Tambahkan ini agar dinamis

  const CustomBottomNav(
      {Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        // Ini kunci agar bottom nav Anda aman di semua jenis HP
        bottom: 12 + MediaQuery.of(context).padding.bottom, 
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(icon: Icons.home_rounded, index: 0, iconSize: 34),
          _buildNavItem(icon: Icons.crop_free_rounded, index: 1, iconSize: 32),
          _buildNavItem(
              icon: Icons.account_circle_outlined, index: 2, iconSize: 38),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required int index, required double iconSize}) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index), // Panggil fungsi di sini
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
                spreadRadius: 1),
            const BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 1),
          ],
        ),
        child: Center(child: Icon(icon, color: Colors.black87, size: iconSize)),
      ),
    );
  }
}
