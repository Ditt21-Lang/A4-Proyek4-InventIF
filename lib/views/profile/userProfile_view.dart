import 'package:flutter/material.dart';
import 'manageAccount_view.dart';
import '../list_order_view.dart';
import '../../controllers/profile/userProfile_controller.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final UserProfileController _controller = UserProfileController();

  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);
  final Color creamColor = const Color(0xFFFAF0E6);

  String? userFullName;
  String? userNickname;
  String? userID;
  String? userDate;
  String? userRole;
  String? userProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProfile = await _controller.getUserProfile();
      if (userProfile != null) {
        setState(() {
          userFullName = userProfile.fullName;
          userNickname = userProfile.nickname;
          userID = userProfile.identifier;
          userDate = userProfile.dateOfBirth ?? '16/08/06';
          userRole = userProfile.role;
          userProfileImage = userProfile.profileImage;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _signOut() async {
    final success = await _controller.signOut();
    if (success && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi status bar HP (poni HP)
    final double topPadding = MediaQuery.of(context).padding.top;

    // Menentukan tinggi area krem di atas dan tinggi kartu
    final double headerCreamHeight = topPadding + 140.0;
    const double cardHeight = 130.0;

    return Scaffold(
      backgroundColor: primaryBlue,
      // KITA HAPUS SAFE AREA AGAR WARNA KREM TEMBUS KE UJUNG ATAS LAYAR
      body: Column(
        children: [
          // --- 1. HEADER KREM & KARTU PROFIL ---
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Latar Belakang (Krem di atas, Biru di bawah)
              Column(
                children: [
                  Container(
                    height: headerCreamHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg_gedung.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Container(
                    color: primaryBlue,
                    height: cardHeight / 2, // Bantalan bawah untuk kartu
                    width: double.infinity,
                  ),
                ],
              ),
              // Kartu Profil (Tepat di tengah perbatasan warna)
              Positioned(
                top: headerCreamHeight - (cardHeight / 2),
                left: 24,
                right: 24,
                child: _buildProfileCard(cardHeight),
              ),
            ],
          ),

          // Memberi jarak ruang di bawah kartu yang melayang
          const SizedBox(height: (cardHeight / 2) + 10),

          // --- 2. MENU BUTTONS ---
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
              child: Column(
                children: [
                  _buildMenuButton(
                    icon: Icons.account_circle_outlined,
                    label: 'Manage Account',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageAccountView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (userRole != 'teknisi') ...[
                    _buildMenuButton(
                      icon: Icons.shopping_bag_outlined,
                      label: 'List Order',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListOrderView(
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildMenuButton(
                    icon: Icons.logout_rounded, // Berubah menyesuaikan Figma
                    label: 'Sign Out', // Mengikuti teks Figma "Sign Out"
                    onPressed: _signOut,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Komponen Kartu Profil
  Widget _buildProfileCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30), // Lebih melengkung
        color: creamColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Teks sejajar vertikal
        children: [
          // Foto Profil
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipOval(
              child: userProfileImage != null && userProfileImage!.isNotEmpty
                  ? Image.network(
                      userProfileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          // Data Teks
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 18, // Lebih besar agar mudah dibaca
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  userID ?? 'ID Loading...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userDate ?? '16/08/06',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Komponen Tombol Menu
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: creamColor,
          // Bentuk PILL (sangat melengkung) seperti Figma
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: primaryOrange, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18, // Font dibesarkan & ditebalkan
                fontWeight: FontWeight.bold,
                color: primaryOrange,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: primaryOrange, size: 20),
          ],
        ),
      ),
    );
  }
}
