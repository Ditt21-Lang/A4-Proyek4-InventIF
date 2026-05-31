import 'package:flutter/material.dart';
import '../../controllers/Teknisi/dashboard_teknisi_controller.dart';
import '../../models/transaction_model.dart';
import 'add_equipment_view.dart';
import 'equipment_list_view.dart';

class DashboardTeknisiScreen extends StatefulWidget {
  const DashboardTeknisiScreen({super.key});

  @override
  State<DashboardTeknisiScreen> createState() => _DashboardTeknisiScreenState();
}

class _DashboardTeknisiScreenState extends State<DashboardTeknisiScreen> {
  final DashboardTeknisiController _controller = DashboardTeknisiController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://drive.google.com/uc?id=14huLMCPbDYsCMkOrzIo3hezQVcpN6dHN&export=download'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF283593).withOpacity(0.85),
                  const Color(0xFF1A237E).withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo,',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          Text('Teknisi Rega!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              'https://i2.wp.com/images.genshin-builds.com/genshin/characters/furina/image.png?strip=all&quality=100&w=100')),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/list-pengajuan');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 25),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ]),
                      child: const Column(
                        children: [
                          Icon(Icons.access_time,
                              color: Color(0xFFF48A42), size: 36),
                          SizedBox(height: 8),
                          Text('Need Approve',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Room/Tool Submission',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _controller.transaksiPendingStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }

                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.white)));
                      }

                      final listTransaksi = snapshot.data ?? [];

                      if (listTransaksi.isEmpty) {
                        return const Center(
                          child: Text("Tidak ada antrian",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 100),
                        itemCount: listTransaksi.length,
                        itemBuilder: (context, index) {
                          return _buildSubmissionCard(listTransaksi[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // TOMBOL MENU MELAYANG (FAB)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 90.0), // Jarak aman dari navigasi bawah
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFF48A42),
          // Menggunakan icon widgets (kumpulan menu) alih-alih tanda '+'
          child: const Icon(Icons.widgets_rounded, color: Colors.white),
          onPressed: () => _showQuickActionMenu(context),
        ),
      ),
    );
  }

  // === FITUR POPUP MENU ===
  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 20 + MediaQuery.of(context).padding.bottom),
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
                      color: const Color(0xFFF78233).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: Color(0xFFF78233)),
                ),
                title: const Text('Data Alat (Assets)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: const Text('Kelola daftar alat dan fasilitas lab',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(context); // Tutup popup
                  Navigator.push(
                      context,
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
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.ios_share_rounded, color: Colors.blue),
                ),
                title: const Text('Export history',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: const Text('Unduh berkas laporan peminjaman (.csv)',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Fitur Ekspor Berkas Laporan siap dikembangkan!')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmissionCard(TransactionModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                    'https://i2.wp.com/images.genshin-builds.com/genshin/characters/furina/image.png?strip=all&quality=100&w=100'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${item.borrowerName}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      item.itemNames,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFF48A42), Color(0xFFE65C00)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _controller.confirmSubmission(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.itemNames} ACC sukses!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Confirm submission',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
