import 'package:flutter/material.dart';

class ListOrderView extends StatefulWidget {
  const ListOrderView({super.key});

  @override
  State<ListOrderView> createState() => _ListOrderViewState();
}

class _ListOrderViewState extends State<ListOrderView> {
  final Color primaryBlue = const Color(0xFF2A2C8F);
  final Color primaryOrange = const Color(0xFFF88031);
  final Color creamColor = const Color(0xFFFAF0E6);

  String? userName;
  String? userNickname;

  @override
  void initState() {
    super.initState();
    // TODO: Call list_order_controller to fetch orders & user data
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
                    'Hello, ${(userNickname != null && userNickname!.isNotEmpty) ? userNickname : (userName ?? "User")}!',
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
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile_01.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Area (blue background, scrollable) 
          Expanded(
            child: Container(
              color: primaryBlue,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // TODO: Load order list from list_order_controller
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Loading Orders...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar 
          _buildBottomNavigationBar(context),
        ],
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

          // Profile 
          Container(
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
