import 'package:flutter/material.dart';
import '../../controllers/Teknisi/dashboard_teknisi_controller.dart';
import '../../models/transaction_model.dart';
import 'document_viewer_view.dart';
import 'return_scanner_view.dart';

class DashboardTeknisiScreen extends StatefulWidget {
  const DashboardTeknisiScreen({super.key});

  @override
  State<DashboardTeknisiScreen> createState() => _DashboardTeknisiScreenState();
}

class _DashboardTeknisiScreenState extends State<DashboardTeknisiScreen> {
  final DashboardTeknisiController _controller = DashboardTeknisiController();

  String _formatTanggal(DateTime? date) {
    if (date == null) return 'No date set';
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
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Borrow requests & return requests',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12)),
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
                          return _buildCard(listTransaksi[index]);
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

  Widget _buildCard(TransactionModel item) {
    final bool isReturning = item.status == 'Returning';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
        border: isReturning
            ? Border.all(color: Colors.orange.shade400, width: 1.5)
            : null,
      ),
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
              // Badge status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReturning ? Colors.orange : const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isReturning ? 'Return Request' : 'Borrow Request',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
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

          // === TOMBOL DOKUMEN & KTM ===
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                if (item.attachmentUrl != null &&
                    item.attachmentUrl!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DocumentViewerView(url: item.attachmentUrl!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description_rounded,
                        color: Colors.blue, size: 20),
                    label: const Text('View Document',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    String? ktmUrl =
                        await _controller.getBorrowerKTM(item.borrowerId);

                    if (context.mounted) Navigator.pop(context);

                    if (ktmUrl != null && ktmUrl.isNotEmpty) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    ktmUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(20),
                                      child: const Text(
                                          'Failed to load identity card',
                                          style:
                                              TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Borrower has not uploaded an Identity Card.')),
                        );
                      }
                    }
                  },
                  icon:
                      const Icon(Icons.badge, color: Colors.orange, size: 20),
                  label: const Text('View Identity',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          // =============================================

          const SizedBox(height: 16),
          // Tombol aksi: Returning → Scan Return, Waiting → Approve
          Align(
            alignment: Alignment.center,
            child: isReturning
                ? _buildButton(
                    'Scan Return', [Colors.orange, Colors.deepOrange], () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ReturnScannerView(transaction: item)),
                    );
                  })
                : _buildButton(
                    'Approve',
                    const [Color(0xFFF48A42), Color(0xFFE65C00)], () {
                    _controller.confirmSubmission(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${item.itemNames} approved successfully!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
          ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
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
