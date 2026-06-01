import 'package:flutter/material.dart';
import '../../controllers/coordinator/import_jadwal_controller.dart';

class ImportJadwalView extends StatefulWidget {
  const ImportJadwalView({super.key});

  @override
  State<ImportJadwalView> createState() => _ImportJadwalViewState();
}

class _ImportJadwalViewState extends State<ImportJadwalView> {
  final ImportJadwalController _controller = ImportJadwalController();

  Future<void> _handleImport() async {
    final success = await _controller.importExcelJadwal();

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Import Berhasil 🎉',
                style: TextStyle(color: Colors.green)),
            content: Text(
                'Sebanyak ${_controller.totalJadwalImported} jadwal perkuliahan rutin berhasil disingkronisasi ke kalender ruangan.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mengimpor jadwal atau file dibatalkan.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('Import Jadwal Rutin',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.sync_rounded,
                  size: 80, color: Color(0xFFFF8A2A)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Panduan Import:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A237E))),
                    SizedBox(height: 12),
                    Text(
                        '1. Pastikan file PDF jadwal telah di-convert ke format CSV (.csv).',
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text(
                        '2. Pastikan ID Ruangan di database sesuai/mirip dengan nama ruangan di dalam CSV (contoh: D-108).',
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text(
                        '3. Sistem akan otomatis mengisi jadwal dari 9 Februari hingga 13 Juni 2026.',
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A2A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      onPressed: _controller.isLoading ? null : _handleImport,
                      child: _controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('PILIH FILE CSV & IMPORT',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
