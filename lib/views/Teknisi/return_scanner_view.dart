import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/transaction_model.dart';
import '../../controllers/Teknisi/return_scanner_controller.dart';

class ReturnScannerView extends StatefulWidget {
  final TransactionModel transaction;
  const ReturnScannerView({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<ReturnScannerView> createState() => _ReturnScannerViewState();
}

class _ReturnScannerViewState extends State<ReturnScannerView> {
  late ReturnScannerController _controller;
  bool _isShowingSnackbar = false;

  @override
  void initState() {
    super.initState();
    _controller = ReturnScannerController(widget.transaction);
  }

  void _showSnackbar(String message, bool isSuccess) {
    if (_isShowingSnackbar) return;
    setState(() => _isShowingSnackbar = true);

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            backgroundColor:
                isSuccess ? const Color(0xFF2E2E78) : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 120, left: 40, right: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            duration: const Duration(seconds: 2),
          ),
        )
        .closed
        .then((_) {
      if (mounted) {
        setState(() => _isShowingSnackbar = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllScanned =
        _controller.scannedItemIds.length == widget.transaction.items.length;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Kamera Utama
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !isAllScanned && !_isShowingSnackbar) {
                final String rawQr = barcodes.first.rawValue ?? '';
                if (rawQr.isNotEmpty) {
                  String result = _controller.processScannedCode(rawQr);
                  if (result == 'SUCCESS') {
                    setState(() {});
                    _showSnackbar('Item valid! Berhasil discan.', true);
                  } else if (result == 'WRONG_ITEM') {
                    _showSnackbar('Item tidak ada dalam transaksi ini!', false);
                  } else if (result == 'ALREADY_SCANNED') {
                    // Tidak spam snackbar
                  } else if (result == 'ALL_SCANNED') {
                    setState(() {});
                    _showSnackbar('Semua item komplit!', true);
                  }
                }
              }
            },
          ),

          // 2. Background Gedung + Overlay Biru (dengan lubang scanner)
          ClipPath(
            clipper: ScannerHoleClipper(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_gedung.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                color: const Color(0xFF3B3B98).withOpacity(0.9),
              ),
            ),
          ),

          // 3. Garis Viewfinder Scanner
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isShowingSnackbar ? Colors.greenAccent : Colors.redAccent,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // 4. Teks Instruksi di atas kotak scanner
          const Positioned(
            left: 0,
            right: 0,
            top: 180,
            child: Text(
              'Arahkan kamera ke QR Code item\nuntuk validasi pengembalian',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),

          // 5. Tombol Back
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B3B98),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      offset: const Offset(-3, -3),
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
          ),

          // 6. Judul Halaman (di atas, tengah)
          Positioned(
            top: 58,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Validasi Pengembalian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 7. Panel Putih Bagian Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4C4C4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status Item (${_controller.scannedItemIds.length}/${widget.transaction.items.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E78),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Daftar Item
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: widget.transaction.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.transaction.items[index];
                        final bool isScanned =
                            _controller.scannedItemIds.contains(item.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B3B98).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFF3B3B98),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF2E2E78),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'ID: ${item.id}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Indikator status
                                Icon(
                                  isScanned
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isScanned
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Tombol Approve (gaya sama dengan Checkout di qr_scanner_view)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF78233),
                          disabledBackgroundColor: const Color(0xFFC4C4C4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: !isAllScanned || _controller.isProcessing
                            ? null
                            : () async {
                                final bool success =
                                    await _controller.completeReturn();
                                if (success && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        child: _controller.isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'APPROVE PENGEMBALIAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clipper sama persis dengan qr_scanner_view ──────────────────────────────
class ScannerHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    const double holeWidth = 280;
    const double holeHeight = 280;
    final double left = (size.width - holeWidth) / 2;
    final double top = (size.height - holeHeight) / 2;
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, holeWidth, holeHeight),
        const Radius.circular(24),
      ),
    );
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}