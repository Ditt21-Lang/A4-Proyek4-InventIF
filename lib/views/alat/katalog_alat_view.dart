import 'package:flutter/material.dart';
import '../../controllers/alat/katalog_alat_controller.dart';
import '../../models/equipment_model.dart';
import 'qr_scanner_view.dart';

class KatalogAlatView extends StatelessWidget {
  final KatalogAlatController controller;

  const KatalogAlatView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF3B3B98), <- HAPUS INI
      body: Container(
        // 1. Set Background Gambar Gedung pada Container terluar
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_gedung.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter, // Agar fokus ke bagian atas gambar
          ),
        ),
        child: Column(
          children: [
            // 2. Beri jarak kosong transparan di atas agar gambar gedung terlihat
            // Menggunakan 15% dari tinggi layar
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            // 3. Kontainer Biru Utama (Melengkung di atas)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B3B98),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      40,
                    ), // Ini untuk efek melengkung di sudut atas
                  ),
                ),
                // Gunakan ClipRRect agar konten ListView di dalamnya tidak melebihi lengkungan
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ), // Jarak dari ujung lengkungan ke teks judul
                      // HEADER TITLE
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
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
                            _buildChip('All', false),
                            _buildChip('Room', false),
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
                                onRefresh: () async => await controller.fetchEquipmentData(),
                                color: const Color(0xFFF78233),
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                    const Center(
                                      child: Text(
                                        'Alat tidak ditemukan',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                                  bottom: 100 // Jarak aman agar item terbawah tidak tertutup Navbar
                                ),
                                itemCount: controller.displayedEquipment.length,
                                itemBuilder: (context, index) {
                                  return _buildEquipmentCard(
                                    controller.displayedEquipment[index],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildChip(String label, bool isActive) {
    return Container(
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
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    Color statusColor = equipment.status == 'Available'
        ? Colors.green
        : Colors.amber;

    return Container(
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
            ),
            // Hapus komentar di bawah ini jika assets gambar sudah tersedia di pubspec.yaml
            // child: Image.asset(equipment.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  style: const TextStyle(
                    color: Color(0xFFF78233), // Warna font oranye
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    equipment.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  // Tambahkan (BuildContext context) di dalam kurung
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
          // 1. Icon Home (Active) - Sekarang ditambah efek Shadow Timbul
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF78233), // Warna tetap oranye
              borderRadius: BorderRadius.circular(18),
              // --- TAMBAHAN SHADOW DI SINI ---
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
              // -------------------------------
            ),
            child: const Center(
              child: Icon(
                Icons.home_rounded,
                color: Colors.black87,
                size: 34,
              ),
            ),
          ),

          // 2. Icon Scanner (Inactive)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerView()),
              );
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
                child: Icon(
                  Icons.crop_free_rounded,
                  color: Colors.black87,
                  size: 32,
                ),
              ),
            ),
          ),

          // 3. Icon Profile (Inactive)
          // Icon Profile
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
