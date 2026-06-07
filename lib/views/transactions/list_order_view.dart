import 'package:flutter/material.dart';
import '../../controllers/transactions/list_order_controller.dart';
import '../../models/transaction_model.dart';
import 'transaction_detail_view.dart';
import '../../widgets/custom_bottom_nav.dart'; // Import navigasi universal
import '../Teknisi/document_viewer_view.dart';

class ListOrderView extends StatefulWidget {
  final VoidCallback onBack;
  const ListOrderView({Key? key, required this.onBack}) : super(key: key);

  @override
  State<ListOrderView> createState() => _ListOrderViewState();
}

class _ListOrderViewState extends State<ListOrderView> {
  final ListOrderController _controller = ListOrderController();

  // Helper untuk format tanggal singkat (dd MMM yyyy)
  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE5), // Warna background atas (krem)
      body: Column(
        children: [
          // --- BAGIAN ATAS (KREM): PROFIL ---
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Back
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6EFE5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-3, -3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFF78233),
                        size: 24,
                      ),
                    ),
                  ),

                  // Teks Sapaan
                  const Expanded(
                    child: Text(
                      'Hello, Arjuna!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Foto Profil (Placeholder)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                      // Jika Anda punya gambar profil di assets, un-comment kode di bawah ini:
                      // image: DecorationImage(
                      //   image: AssetImage('assets/images/profile_placeholder.png'),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- BAGIAN BAWAH (BIRU): LIST ORDER ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B3B98),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_controller.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFF78233)));
                  }

                  if (_controller.orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No borrowing history found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _controller.orders.length,
                    itemBuilder: (context, index) {
                      final transaction = _controller.orders[index];
                      return _buildOrderCard(context, transaction);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, TransactionModel transaction) {
    // Tentukan warna status
    Color statusColor;
    switch (transaction.status.toLowerCase()) {
      case 'approved':
      case 'in-use':
      case 'dipinjam':
        statusColor = Colors.green;
        break;
      case 'draft':
      case 'waiting':
      case 'pending':
        statusColor = const Color(0xFFF48A42); // Oranye
        break;
      case 'completed':
      case 'dikembalikan':
      case 'returned':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        // Navigasi ke Halaman Detail (pastikan rute ini sudah Anda buat sebelumnya)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailView(transaction: transaction),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              const Color(0xFFE0E0E0), // Warna abu-abu seragam dengan Teknisi
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  // Placeholder avatar, bisa disesuaikan nanti
                  backgroundImage: NetworkImage(
                      'https://i2.wp.com/images.genshin-builds.com/genshin/characters/furina/image.png?strip=all&quality=100&w=100'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${transaction.borrowerName}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text(
                          'Borrow date: ${_formatShortDate(transaction.startDate)}',
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
            // Memanggil getter itemNames yang pintar (otomatis gabung string jika lebih dari 1)
            Text('• ${transaction.itemNames}',
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
                
            // Tampilkan dokumen persetujuan dari koordinator jika ada
            if (transaction.officialLetterUrl != null &&
                transaction.officialLetterUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentViewerView(
                            url: transaction.officialLetterUrl!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description, color: Colors.blue),
                  label: const Text(
                    'Approved Permit Letter',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              
            const SizedBox(height: 16),

            // Indikator Status di tengah (mirip tombol Approve di Teknisi)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.status.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
