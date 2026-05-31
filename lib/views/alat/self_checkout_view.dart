import 'package:flutter/material.dart';
import '../../models/equipment_model.dart';
import '../../controllers/alat/checkout_controller.dart';

class SelfCheckoutView extends StatefulWidget {
  final List<EquipmentModel> equipments;

  const SelfCheckoutView({Key? key, required this.equipments})
      : super(key: key);

  @override
  State<SelfCheckoutView> createState() => _SelfCheckoutViewState();
}

class _SelfCheckoutViewState extends State<SelfCheckoutView> {
  final CheckoutController _checkoutController = CheckoutController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  // Helper cek apakah tanggal sama
  bool _isSameDay() {
    return _startDate.year == _endDate.year &&
        _startDate.month == _endDate.month &&
        _startDate.day == _endDate.day;
  }

  String _formatDate(DateTime date) {
    String yearStr = date.year.toString().substring(2);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/$yearStr";
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // --- PEMANGGIL KALENDER ---
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF78233),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Cegah tanggal akhir bocor ke belakang tanggal mulai
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          if (picked.isBefore(_startDate)) {
            _endDate = _startDate;
          } else {
            _endDate = picked;
          }
        }

        // PENGAMAN EKSTRA: Jika setelah ubah tanggal ternyata harinya jadi SAMA,
        // kita otomatis samakan jam akhirnya jika jam akhir ternyata lebih kecil.
        if (_isSameDay()) {
          int startMins = _startTime.hour * 60 + _startTime.minute;
          int endMins = _endTime.hour * 60 + _endTime.minute;
          if (endMins < startMins) {
            _endTime = _startTime; // Reset otomatis
          }
        }
      });
    }
  }

  // --- PEMANGGIL JAM & VALIDASI ---
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF78233),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // Validasi 1: Harus di antara 07:00 - 17:00
      if (picked.hour < 7 ||
          picked.hour > 17 ||
          (picked.hour == 17 && picked.minute > 0)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a time between 07:00 and 17:00'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Hitung total menit untuk perbandingan waktu
      int pickedMinutes = picked.hour * 60 + picked.minute;
      int startMinutes = _startTime.hour * 60 + _startTime.minute;
      int endMinutes = _endTime.hour * 60 + _endTime.minute;

      // Validasi 2: Jika Edit Waktu Akhir pada Hari yang Sama
      if (!isStart && _isSameDay()) {
        if (pickedMinutes < startMinutes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Return time cannot be earlier than start time on the same day',
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return; // Batalkan input
        }
      }

      // Validasi 3: Jika Edit Waktu Mulai jadi lebih lambat dari Waktu Akhir di hari yang sama
      if (isStart && _isSameDay()) {
        if (pickedMinutes > endMinutes) {
          // Otomatis samakan waktu akhir agar tidak error
          setState(() {
            _startTime = picked;
            _endTime = picked;
          });
          return;
        }
      }

      // Jika lolos semua validasi, simpan datanya
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B3B98),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Checkout Equipment',
                style: TextStyle(
                  color: Color(0xFFF78233),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(width: 250, height: 1.5, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            const Text(
              'List Checkout',
              style: TextStyle(
                color: Color(0xFFF78233),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.equipments.length,
                itemBuilder: (context, index) {
                  final equipment = widget.equipments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E2E6),
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
                                equipment.name,
                                style: const TextStyle(
                                  color: Color(0xFFF78233),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              // Text(
                              //   'Condition: ${equipment.condition}',
                              //   style: const TextStyle(
                              //     color: Colors.black87,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E2E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_startDate),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E2E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(_startTime),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E2E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_endDate),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E2E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(_endTime),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // --- UI DINAMIS: MUNCUL HANYA JIKA LINTAS HARI ---
            if (!_isSameDay()) ...[
              const SizedBox(height: 24),
              const Text(
                'Upload Dokumen Pendukung',
                style: TextStyle(
                  color: Color(0xFFF78233),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Peminjaman lebih dari 1 hari wajib menyertakan surat izin atau jaminan (PDF/JPG).',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _checkoutController.pickDocument(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E2E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        // AnimatedBuilder untuk re-render saat nama file berubah
                        child: AnimatedBuilder(
                          animation: _checkoutController,
                          builder: (context, _) {
                            return Text(
                              _checkoutController.documentLabel ??
                                  'Tap to upload document...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              // BUNGKUS DENGAN ANIMATED BUILDER
              child: AnimatedBuilder(
                animation: _checkoutController,
                builder: (context, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF78233),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // MATIKAN TOMBOL JIKA SEDANG LOADING
                    // MATIKAN TOMBOL JIKA SEDANG LOADING
                    onPressed: _checkoutController.isCheckingOut
                        ? null
                        : () async {
                            // VALIDASI UX: Lintas Hari Wajib Upload
                            if (!_isSameDay() &&
                                _checkoutController.pickedFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Harap unggah dokumen pendukung untuk peminjaman lintas hari!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return; // Hentikan proses
                            }

                            DateTime finalStartDateTime = DateTime(
                              _startDate.year,
                              _startDate.month,
                              _startDate.day,
                              _startTime.hour,
                              _startTime.minute,
                            );

                            DateTime finalEndDateTime = DateTime(
                              _endDate.year,
                              _endDate.month,
                              _endDate.day,
                              _endTime.hour,
                              _endTime.minute,
                            );

                            try {
                              bool success =
                                  await _checkoutController.processCheckout(
                                widget.equipments,
                                finalStartDateTime,
                                finalEndDateTime,
                              );

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pesanan dicatat!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/dashboard', (route) => false);
                              }
                            } catch (e) {
                              // Tangkap pesan error dari Controller (misal saat offline tapi ada upload)
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e
                                        .toString()
                                        .replaceFirst('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          },
                    // UBAH TAMPILAN TEXT MENJADI LOADING
                    child: _checkoutController.isCheckingOut
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Checkout (${widget.equipments.length} Items)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
            SizedBox(height: 30 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
