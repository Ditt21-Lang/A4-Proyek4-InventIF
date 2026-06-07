import 'package:flutter/material.dart';
import '../../controllers/ruangan/detail_ruangan_controller.dart';
import '../../controllers/ruangan/katalog_ruangan_controller.dart';
import '../../models/room_model.dart';
import 'detail_ruangan.dart';

class KatalogRuanganScreen extends StatelessWidget {
  final KatalogRuanganController controller;
  final Function(int) onTabChanged;

  const KatalogRuanganScreen(
      {super.key, required this.controller, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    // 1. Bungkus dengan BaseCatalogLayout, set currentIndex ke 0
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // Jarak dari ujung lengkungan ke teks judul
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

        // CHIPS (Tab Room Aktif)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip('All', false, onTap: () => onTabChanged(2)),
              _buildChip('Room', true),
              _buildChip('Equipment', false, onTap: () => onTabChanged(0)),
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
              onChanged: controller.searchRooms,
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
              if (controller.displayedRooms.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchRoomData,
                  color: const Color(0xFFF78233),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      const Center(
                        child: Text(
                          'Room not found',
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
                onRefresh: controller.fetchRoomData,
                color: const Color(0xFFF78233),
                backgroundColor: Colors.white,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom:
                        100, // Jarak aman agar item terbawah tidak tertutup Navbar
                  ),
                  itemCount: controller.displayedRooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(
                      context,
                      controller.displayedRooms[index],
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

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E2E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailRuanganScreen(
                  controller: DetailRuanganController(room: room),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: room.gambar.startsWith('http')
                    ? Image.network(
                        room.gambar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.meeting_room_rounded,
                          color: Color(0xFF3B3B98),
                          size: 40,
                        ),
                      )
                    : Image.asset(
                        room.gambar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.meeting_room_rounded,
                          color: Color(0xFF3B3B98),
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: Color(0xFFF78233),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  // Widget khusus untuk membuat efek Skeleton Loading
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 104,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E2E6).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
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
}
