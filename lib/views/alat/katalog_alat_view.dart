import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../controllers/alat/katalog_alat_controller.dart';
import '../../models/equipment_model.dart';
import '../../widgets/base_catalog_layout.dart';
import '../teknisi/detail_equipment_view.dart';

class KatalogAlatView extends StatelessWidget {
  final KatalogAlatController controller;
  final Function(int) onTabChanged;

  const KatalogAlatView(
      {Key? key, required this.controller, required this.onTabChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Bungkus dengan BaseCatalogLayout, set currentIndex ke 0
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // Jarak dari ujung lengkungan ke teks judul
        // HEADER TITLE
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Available Facilities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // CHIPS (Tab Equipment Aktif)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip('All', false, onTap: () => onTabChanged(2)),
              _buildChip('Room', false, onTap: () => onTabChanged(1)),
              _buildChip('Equipment', true),
              _buildChip('Available', false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6E2E6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              onChanged: controller.searchEquipment,
              decoration: const InputDecoration(
                hintText: 'Search Facilities',
                hintStyle: TextStyle(color: Colors.grey),
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.black87,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // LISTVIEW (Data vs Skeleton Loading)
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              // 1. Tampilkan Skeleton Loading saat sedang proses ambil data
              if (controller.isLoading) {
                return _buildSkeletonLoading();
              }

              // 2. Tampilan saat data kosong (tetap bisa di-refresh)
              if (controller.displayedEquipment.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // Cek sinyal dulu sebelum menyedot data
                    bool hasConnection =
                        await InternetConnectionChecker.createInstance()
                            .hasConnection;

                    if (!hasConnection) {
                      // Munculkan SnackBar penolakan jika offline
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Unable to refresh data while offline.'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return; // Hentikan fungsi refresh di sini
                    }

                    // Jika online, lanjutkan sedot data ulang dari Firebase
                    await controller.fetchEquipmentData();
                  },
                  color: const Color(0xFFF78233),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      const Center(
                        child: Text(
                          'Equipment not found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 3. TAMPILAN LIST DATA + FITUR PULL TO REFRESH
              return RefreshIndicator(
                onRefresh: () async {
                  // Memanggil fungsi untuk sedot data ulang dari Firebase
                  await controller.fetchEquipmentData();
                },
                color: const Color(0xFFF78233), // Warna *loading* oranye
                backgroundColor: Colors.white,
                child: ListView.builder(
                  // TAMBAHAN PENTING: Wajib ada agar list selalu bisa ditarik
                  // ke bawah, meskipun jumlah barangnya baru 1 atau 2.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom:
                        100, // Jarak aman agar item terbawah tidak tertutup Navbar
                  ),
                  itemCount: controller.displayedEquipment.length,
                  itemBuilder: (context, index) {
                    return _buildEquipmentCard(
                      context,
                      controller.displayedEquipment[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildChip(String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF78233) : const Color(0xFFE6E2E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Tambahkan BuildContext pada parameter
  Widget _buildEquipmentCard(BuildContext context, EquipmentModel equipment) {
    Color statusColor =
        equipment.status == 'Available' ? Colors.green : Colors.amber;

    // Bungkus dengan GestureDetector
    return GestureDetector(
      onTap: () {
        // Langsung arahkan ke halaman DetailEquipmentView yang sudah Anda buat!
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => DetailEquipmentView(
                equipment: equipment,
                showActions: false,
              ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E2E6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior:
                  Clip.antiAlias, // Wajib agar sudut gambar ikut melengkung
              child: _buildEquipmentImage(equipment
                  .image), // Sesuaikan .image atau .gambar dengan EquipmentModel Anda
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: const TextStyle(
                      color: Color(0xFFF78233),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      equipment.status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget khusus untuk membuat efek Skeleton Loading (Mockup ke-2)
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4, // Menampilkan 4 kotak kosong
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 104, // Estimasi tinggi kartu asli
          decoration: BoxDecoration(
            color: const Color(0xFFE6E2E6).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEquipmentImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return const Icon(Icons.inventory_2_outlined,
          color: Colors.grey, size: 32);
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey, size: 32),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey, size: 32),
    );
  }
}
