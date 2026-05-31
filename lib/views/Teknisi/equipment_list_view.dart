import 'package:flutter/material.dart';
import '../../controllers/Teknisi/equipment_list_controller.dart';
import '../../models/equipment_model.dart';
import 'add_equipment_view.dart';
import 'edit_equipment_view.dart';
import 'detail_equipment_view.dart';

class EquipmentListView extends StatefulWidget {
  const EquipmentListView({super.key});

  @override
  State<EquipmentListView> createState() => _EquipmentListViewState();
}

class _EquipmentListViewState extends State<EquipmentListView> {
  final EquipmentListController _controller = EquipmentListController();
  String _searchQuery = '';

  // Dialog Hapus Data Alat
  void _showDeleteDialog(EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus "${equipment.name}" dari sistem?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              bool success = await _controller.deleteEquipment(equipment.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Alat dihapus!'),
                    backgroundColor: Colors.red));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // Header Biru Tua Melengkung
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
                        onPressed: () => Navigator.pop(context)),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text('Data Alat (Assets)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                      decoration: const InputDecoration(
                          hintText: 'Cari nama atau ID alat...',
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // List View
                Expanded(
                  child: StreamBuilder<List<EquipmentModel>>(
                    stream: _controller.getEquipmentStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      final filteredItems = (snapshot.data ?? [])
                          .where((item) =>
                              item.name.toLowerCase().contains(_searchQuery) ||
                              item.id.toLowerCase().contains(_searchQuery))
                          .toList();
                      if (filteredItems.isEmpty)
                        return const Center(
                            child: Text("Tidak ada alat ditemukan",
                                style: TextStyle(color: Colors.black54)));

                      return ListView.builder(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 80 + MediaQuery.of(context).padding.bottom),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (content) =>
                                          DetailEquipmentView(equipment: item)),
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
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(item.image,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.inventory_2_rounded,
                                                  size: 40,
                                                  color: Colors.grey)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF1A237E))),
                                          Text('ID: ${item.id}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.edit_note_rounded,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditEquipmentView(
                                                          equipment: item)),
                                            );
                                          },
                                        ),
                                        IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.redAccent),
                                            onPressed: () =>
                                                _showDeleteDialog(item)),
                                      ],
                                    )
                                  ],
                                ),
                              ));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      // TOMBOL TAMBAH ALAT BARU DIPINDAH KE SINI
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF78233),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEquipmentView()));
        },
      ),
    );
  }
}
