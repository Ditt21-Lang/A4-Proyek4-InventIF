import 'package:flutter/material.dart';
import 'dashboard_teknisi_view.dart';
import 'list_pengajuan_view.dart';
import '../profile/userProfile_view.dart';
import 'equipment_list_view.dart';
import '../../controllers/Teknisi/export_controller.dart';
import '../../widgets/export_history_dialog.dart';

class MainDashboardTeknisi extends StatefulWidget {
  const MainDashboardTeknisi({super.key});

  @override
  State<MainDashboardTeknisi> createState() => _MainDashboardTeknisiState();
}

class _MainDashboardTeknisiState extends State<MainDashboardTeknisi> {
  int _bottomNavIndex = 0;
  final ExportController _exportController = ExportController();

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
      // TOMBOL MENU MELAYANG (FAB)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0), // Jarak aman dari navigasi bawah
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFF48A42),
          // Menggunakan icon widgets (kumpulan menu) alih-alih tanda '+'
          child: const Icon(Icons.widgets_rounded, color: Colors.white),
          onPressed: () => _showQuickActionMenu(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // === FITUR POPUP MENU ===
  void _showQuickActionMenu(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 20 + MediaQuery.of(sheetContext).padding.bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF1A237E), // Latar Biru Tua Pekat
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Batang Handle Atas
              Container(
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),

              // Opsi 1: Menuju Halaman Data Alat (Equipment List)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF78233).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: Color(0xFFF78233)),
                ),
                title: const Text('Equipment Data (Assets)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: const Text('Manage equipment and lab facilities list',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(sheetContext); // Tutup popup
                  Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                          builder: (_) => const EquipmentListView()));
                },
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white12)),

              // Opsi 2: Ekspor Riwayat
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.ios_share_rounded, color: Colors.blue),
                ),
                title: const Text('Export history',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: const Text('Download transaction history (.xlsx)',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(sheetContext); // Tutup popup
                  
                  // Tampilkan Custom Export Dialog
                  showDialog(
                    context: parentContext,
                    builder: (context) => ExportHistoryDialog(
                      exportController: _exportController,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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
