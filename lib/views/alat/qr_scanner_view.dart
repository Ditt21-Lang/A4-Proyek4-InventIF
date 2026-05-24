import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../controllers/alat/qr_scanner_controller.dart';
import 'self_checkout_view.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({Key? key}) : super(key: key);

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  // Panggil Controller
  final QrScannerController _controller = QrScannerController();
  bool _isShowingSnackbar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Tampilan Kamera Utama
          MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String rawQrData = barcodes.first.rawValue ?? '';

                if (rawQrData.isNotEmpty && !_isShowingSnackbar && !_controller.isProcessing) {
                  
                  // Tangkap pesan kembalian dari controller
                  String result = await _controller.processScannedCode(rawQrData);

                  if (mounted) {
                    if (result == 'SUCCESS') {
                      setState(() {});
                      _showSnackbar('Item added successfully!', true);
                    } else if (result == 'NOT_AVAILABLE') {
                      _showSnackbar('Failed: Item is in use/maintenance!', false);
                    } else if (result == 'ALREADY_IN_CART') {
                      _showSnackbar('Item is already in the cart.', false);
                    } else if (result == 'NOT_FOUND') {
                      _showSnackbar('QR Code not recognized by the system.', false);
                    }
                  }
                }
              }
            },
          ),

          // 2. Background Gedung + Overlay Biru
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

          // 4. Tombol Back
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

          // 5. Tombol Checkout
          if (_controller.scannedEquipments.isNotEmpty)
            Positioned(
              bottom: 40 + MediaQuery.of(context).padding.bottom,
              left: 24,
              right: 24,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF78233),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelfCheckoutView(
                        equipments: _controller.scannedEquipments,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Checkout (${_controller.scannedEquipments.length} Items)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, bool isSuccess) {
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
}

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