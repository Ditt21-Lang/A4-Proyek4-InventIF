import 'package:flutter/material.dart';
import '../../controllers/coordinator/room_list_controller.dart';
import '../../models/room_model.dart';
import 'add_room_view.dart';
import '../../views/ruangan/detail_ruangan.dart';
import '../../controllers/ruangan/detail_ruangan_controller.dart';
import 'import_jadwal_view.dart';

class RoomListView extends StatefulWidget {
  const RoomListView({super.key});

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  final RoomListController _controller = RoomListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(right: 8.0), // Padding disesuaikan
                        child: Text('Room Data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // --- TAMBAHAN TOMBOL IMPORT ---
                    IconButton(
                      icon: const Icon(Icons.upload_file_rounded,
                          color: Colors.white),
                      tooltip: 'Import Schedule CSV',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ImportJadwalView()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: StreamBuilder<List<RoomModel>>(
                    stream: _controller.getRoomsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }

                      final rooms = snapshot.data ?? [];

                      if (rooms.isEmpty) {
                        return const Center(
                          child: Text("No rooms have been added yet.",
                              style: TextStyle(color: Colors.black54)),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom:
                                100 + MediaQuery.of(context).padding.bottom),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];

                          // === BUNGKUS DENGAN GESTURE DETECTOR ===
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailRuanganScreen(
                                    controller:
                                        DetailRuanganController(room: room),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildImage(room.gambar),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(room.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF1A237E))),
                                        Text('ID: ${room.id}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF78233),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddRoomView()));
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty)
      return Container(
          width: 60,
          height: 60,
          color: Colors.grey[200],
          child: const Icon(Icons.meeting_room, color: Colors.grey));
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey)));
    }
    return Image.asset(imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey)));
  }
}
