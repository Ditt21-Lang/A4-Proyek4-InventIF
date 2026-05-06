import 'package:flutter/material.dart';
import 'manageAccount_view.dart';
import 'listOrder_view.dart';
import '../controllers/userProfile_controller.dart';
// import 'qrScanner_view.dart';

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

  static const double cardHeight = 102.0;
  static const double overlapAmount = cardHeight / 2;

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
          userID = userProfile.identifier ?? userProfile.studentID ?? userProfile.uid;
          userDate = userProfile.dateOfBirth ?? '16/08/06';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _signOut() async {
    final success = await _controller.signOut();
    if (success && mounted) {
      // Navigate to login page
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // transisi cream biru dengan card overlap (profile info)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Container(
                      color: creamColor,
                      height: overlapAmount,
                      width: double.infinity,
                    ),
                    Container(
                      color: primaryBlue,
                      height: overlapAmount,
                      width: double.infinity,
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: _buildProfileCard(),
                ),
              ],
            ),

            // Blue area dengan menu buttons
            Expanded(
              child: Container(
                color: primaryBlue,
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 80,
                  bottom: 16,
                ),
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
                    const SizedBox(height: 14),
                    _buildMenuButton(
                      icon: Icons.shopping_bag_outlined,
                      label: 'List Order',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListOrderView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildMenuButton(
                      icon: Icons.logout_outlined,
                      label: 'Sign Out',
                      onPressed: () {
                        _signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: creamColor,
        boxShadow: [
          // Shadow lapis pertama - shadow besar
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 6,
          ),
          // Shadow lapis kedua - shadow medium
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          // Shadow lapis ketiga - highlight inner
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_01.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userID ?? 'ID Loading...',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userDate ?? '16/08/06',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: primaryOrange, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: primaryOrange,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: primaryOrange, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Home (inactive)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
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
              child: const Center(
                child: Icon(Icons.home_rounded, color: Colors.black87, size: 34),
              ),
            ),
          ),

          // Scanner (inactive)
          GestureDetector(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerView()));
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
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
              child: const Center(
                child: Icon(Icons.crop_free_rounded, color: Colors.black87, size: 32),
              ),
            ),
          ),

          // Profile (ACTIVE – oranye)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF78233),
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
            child: const Center(
              child: Icon(
                Icons.account_circle_outlined,
                color: Colors.black87,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
