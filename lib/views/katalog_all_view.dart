import 'package:flutter/material.dart';
import 'alat/katalog_alat_view.dart';
import 'ruangan/katalog_ruangan.dart';
import '../controllers/alat/katalog_alat_controller.dart';
import '../controllers/ruangan/katalog_ruangan_controller.dart';
import '../models/equipment_model.dart';
import '../models/room_model.dart';
import '../widgets/base_catalog_layout.dart';

class KatalogAllView extends StatelessWidget {
  final KatalogAlatController alatController;
  final KatalogRuanganController ruanganController;
  final Function(int) onTabChanged;

  const KatalogAllView({
    Key? key,
    required this.alatController,
    required this.ruanganController,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
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

        // CHIPS (All active)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip('All', true),
              _buildChip('Room', false, onTap: () => onTabChanged(1)),
              _buildChip('Equipment', false, onTap: () => onTabChanged(0)),
              _buildChip('Available', false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SEARCH BAR: apply to both controllers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6E2E6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              onChanged: (q) {
                alatController.searchEquipment(q);
                ruanganController.searchRooms(q);
              },
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

        // Combined list: Equipment first, then Rooms
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([alatController, ruanganController]),
            builder: (context, child) {
              final isLoading =
                  alatController.isLoading || ruanganController.isLoading;

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF78233),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await alatController.fetchEquipmentData();
                  await ruanganController.fetchRoomData();
                },
                color: const Color(0xFFF78233),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                  children: [
                    // Equipments Section
                    const SizedBox(height: 8),
                    const Text(
                      'Equipments',
                      style: TextStyle(
                        color: Color(0xFFF78233),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildEquipmentList(alatController.displayedEquipment),
                    const SizedBox(height: 20),

                    // Rooms Section
                    const Text(
                      'Rooms',
                      style: TextStyle(
                        color: Color(0xFFF78233),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildRoomList(
                        context, ruanganController.displayedRooms),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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

  List<Widget> _buildEquipmentList(List<EquipmentModel> items) {
    if (items.isEmpty) {
      return [
        const SizedBox(height: 16),
        const Center(
            child: Text('Equipment not found',
                style: TextStyle(color: Colors.white))),
      ];
    }

    return items
        .map((e) => Container(
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
                          borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name,
                            style: const TextStyle(
                                color: Color(0xFFF78233),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: e.status == 'Available'
                                  ? Colors.green
                                  : Colors.amber,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(e.status,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> _buildRoomList(BuildContext context, List<RoomModel> items) {
    if (items.isEmpty) {
      return [
        const SizedBox(height: 16),
        const Center(
            child:
                Text('Room not found', style: TextStyle(color: Colors.white))),
      ];
    }

    return items
        .map((r) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6E2E6),
                  borderRadius: BorderRadius.circular(16)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Navigate to catalog ruangan screen for details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => KatalogRuanganScreen(
                              controller: ruanganController,
                              onTabChanged: onTabChanged)),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(r.gambar,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                                Icons.meeting_room_rounded,
                                color: Color(0xFF3B3B98),
                                size: 40)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: const TextStyle(
                                    color: Color(0xFFF78233),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(r.description,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ))
        .toList();
  }
}
