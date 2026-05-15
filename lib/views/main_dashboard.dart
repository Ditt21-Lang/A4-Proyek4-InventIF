import 'package:flutter/material.dart';
import 'alat/katalog_alat_view.dart';
import 'ruangan/katalog_ruangan.dart';
import 'alat/qr_scanner_view.dart';
import 'profile/userProfile_view.dart';
import '../controllers/alat/katalog_alat_controller.dart';
import '../controllers/ruangan/katalog_ruangan_controller.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/base_catalog_layout.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _bottomNavIndex = 0;
  int _catalogIndex = 0; // 0: Alat, 1: Ruangan

  // Controller dibuat SEKALI di sini agar data tidak ke-load ulang!
  late final KatalogAlatController _alatController;
  late final KatalogRuanganController _ruanganController;

  @override
  void initState() {
    super.initState();
    _alatController = KatalogAlatController();
    _ruanganController = KatalogRuanganController();
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // Scanner wajib di-push agar tidak memakan memori kamera di background
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const QrScannerView()));
    } else {
      setState(() => _bottomNavIndex = index);
    }
  }

  void _onCatalogTabChanged(int index) {
    setState(() => _catalogIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menyimpan halaman di memori, sehingga transisi sangat instan
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Index 0: Area Katalog (Dengan Background Gedung)
          BaseCatalogLayout(
            child: IndexedStack(
              index: _catalogIndex,
              children: [
                KatalogAlatView(
                    controller: _alatController,
                    onTabChanged: _onCatalogTabChanged),
                KatalogRuanganScreen(
                    controller: _ruanganController,
                    onTabChanged: _onCatalogTabChanged),
              ],
            ),
          ),

          // Index 1: Kosong (Karena scanner dipanggil via push)
          const SizedBox(),

          // Index 2: Profile / List Order
          UserProfileView(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
