import 'package:flutter/material.dart';
import '../../controllers/transactions/transaction_detail_controller.dart';
import '../../models/transaction_model.dart';

class TransactionDetailView extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailView({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  // Panggil Controller-nya di sini
  final TransactionDetailController _controller = TransactionDetailController();

  // Helper untuk memformat tanggal menjadi dd/mm/yy
  String _formatDate(DateTime date) {
    String yearStr = date.year.toString().substring(2);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/$yearStr";
  }

  // Helper untuk memformat jam menjadi hh:mm
  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B3B98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER & TOMBOL BACK ---
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
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
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFFF78233),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. JUDUL TENGAH ---
            Center(
              child: Column(
                children: [
                  const Text(
                    'Detail Order',
                    style: TextStyle(
                      color: Color(0xFFF78233),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 250,
                    height: 1.5,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. KONTEN UTAMA ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'List Checkout',
                      style: TextStyle(
                        color: Color(0xFFF78233),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LIST BARANG YANG DIPINJAM (Perhatikan tambahan 'widget.' sebelum transaction)
                    ...widget.transaction.items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6D1D6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Color(0xFFF78233),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Condition: Good',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 24),

                    // --- 4. DATE TIME START ---
                    const Text(
                      'Date Time Start',
                      style: TextStyle(
                        color: Color(0xFFF78233),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeBox(
                            icon: Icons.calendar_today_outlined,
                            text: _formatDate(widget.transaction.startDate),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeBox(
                            icon: Icons.access_time_rounded,
                            text: _formatTime(widget.transaction.startDate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 5. DATE TIME END ---
                    const Text(
                      'Date Time End',
                      style: TextStyle(
                        color: Color(0xFFF78233),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeBox(
                            icon: Icons.calendar_today_outlined,
                            text: _formatDate(widget.transaction.endDate),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeBox(
                            icon: Icons.access_time_rounded,
                            text: _formatTime(widget.transaction.endDate),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- 6. TOMBOL RETURN ITEM DENGAN ANIMATED BUILDER ---
                    if (widget.transaction.status.toLowerCase() == 'in use')
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF78233),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                              ),
                              // Matikan tombol jika sedang proses loading
                              onPressed: _controller.isLoading
                                  ? null
                                  : () async {
                                      // Panggil controller
                                      bool success =
                                          await _controller.returnItem(
                                              widget.transaction.transactionId);

                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Permintaan pengembalian dikirim ke Teknisi'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else if (!success && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Gagal mengirim permintaan'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              child: _controller.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.calendar_month_outlined,
                                                color: Colors.white, size: 24),
                                            SizedBox(width: 12),
                                            Text(
                                              'Return Item',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Reusable untuk Kotak Tanggal & Jam
  Widget _buildTimeBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E2E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
