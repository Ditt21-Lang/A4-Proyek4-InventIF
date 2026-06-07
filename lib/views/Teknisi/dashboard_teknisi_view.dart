import 'package:flutter/material.dart';
import '../../controllers/Teknisi/dashboard_teknisi_controller.dart';
import '../../models/transaction_model.dart';
import 'document_viewer_view.dart';

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
                  const Color(0xFF283593).withValues(alpha: 0.85),
                  const Color(0xFF1A237E).withValues(alpha: 0.95),
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
                          Text('Hello,',
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Equipment Submission',
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
                          child: Text("There is no equipment submission",
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

          // === TOMBOL LIHAT DOKUMEN (IN-APP VIEWER) ===
          if (item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentViewerView(url: item.attachmentUrl!),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.description_rounded, color: Colors.blue),
                  label: const Text('View Supporting Document',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
          // ============================================

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
                      content: Text('${item.itemNames} approved successfully!'),
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
