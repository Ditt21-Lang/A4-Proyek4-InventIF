import 'package:flutter/material.dart';
import '../../controllers/Teknisi/list_pengajuan_controller.dart';
import '../../models/transaction_model.dart';
import 'return_scanner_view.dart';

class ListPengajuanScreen extends StatefulWidget {
  const ListPengajuanScreen({super.key});

  @override
  State<ListPengajuanScreen> createState() => _ListPengajuanScreenState();
}

class _ListPengajuanScreenState extends State<ListPengajuanScreen> {
  final ListPengajuanController _controller = ListPengajuanController();
  String _selectedStatus = 'Waiting';

  String _formatTanggal(DateTime? date) {
    if (date == null) return 'Belum ada tanggal';
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

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
              children: [
                const SizedBox(height: 20),
                const Text('Request List',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tab 1: Antrean Pinjam Baru
                      _buildFilterTab('Requests', 'Waiting'),
                      const SizedBox(width: 10),
                      
                      // Tab 2: Barang di Luar & Mau Dikembalikan
                      _buildFilterTab('In Use', 'In Use'),
                      const SizedBox(width: 10),
                      
                      // Tab 3: Riwayat Selesai
                      _buildFilterTab('History', 'History'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _controller.getFilteredStream(_selectedStatus),
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

                      final listData = snapshot.data ?? [];

                      if (listData.isEmpty) {
                        return Center(
                          child: Text(
                              "Tidak ada data di kategori $_selectedStatus",
                              style: const TextStyle(color: Colors.white70)),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 100),
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          return _buildCard(listData[index]);
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
    );
  }

  Widget _buildFilterTab(String label, String statusDb) {
    bool isActive = _selectedStatus == statusDb;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = statusDb),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF48A42) : const Color(0xFFD3D3D3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(TransactionModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text('Name: ${item.borrowerName}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Text('Borrow date: ${_formatTanggal(item.startDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Items:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text('• ${item.itemNames}',
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          if (_selectedStatus == 'Waiting')
            Align(
              alignment: Alignment.center,
              child: _buildButton(
                  'Approve', const [Color(0xFFF48A42), Color(0xFFE65C00)], () {
                _controller.updateStatus(item, 'Approved');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.itemNames} berhasil di-Approve!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }),
            )
          else if (_selectedStatus == 'In Use')
            // Jika statusnya Returning, munculkan tombol Scan Pengembalian
            if (item.status == 'Returning')
              _buildButton('Scan Pengembalian', [Colors.orange, Colors.deepOrange], () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReturnScannerView(transaction: item)),
                );
              })
            // Jika statusnya murni In Use (belum klik return), beri teks saja
            else
              const Align(
                alignment: Alignment.center,
                child: Text('Sedang dipakai mahasiswa',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic)),
              )
          else if (_selectedStatus == 'History')
            Align(
              alignment: Alignment.center,
              child: Text('Selesai (${item.status})',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic)),
            )
        ],
      ),
    );
  }

  Widget _buildButton(
      String label, List<Color> gradientColors, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
