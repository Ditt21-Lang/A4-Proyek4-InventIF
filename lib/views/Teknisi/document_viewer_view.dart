import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DocumentViewerView extends StatefulWidget {
  final String url;

  const DocumentViewerView({super.key, required this.url});

  @override
  State<DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<DocumentViewerView> {
  bool _isDownloading = false;

  // Cek apakah URL mengandung ekstensi .pdf
  bool get _isPdf => widget.url.toLowerCase().contains('.pdf');

  // Fungsi untuk mengunduh file ke penyimpanan HP
  Future<void> _downloadFile() async {
    setState(() => _isDownloading = true);
    try {
      Directory? dir;
      // Menentukan lokasi penyimpanan berdasarkan OS (Android/iOS)
      if (Platform.isAndroid) {
        dir = Directory(
            '/storage/emulated/0/Download'); // Folder Download Publik Android
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory(); // Fallback jika tidak ada
        }
      } else {
        dir = await getApplicationDocumentsDirectory(); // iOS Documents
      }

      // Ambil nama file asli dari URL Cloudinary
      String fileName = widget.url.split('/').last;
      if (!fileName.contains('.')) {
        fileName += _isPdf ? '.pdf' : '.jpg';
      }

      String savePath = '${dir!.path}/$fileName';

      // Proses Download menggunakan Dio
      await Dio().download(widget.url, savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded successfully! Saved to: $savePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Latar gelap agar fokus ke dokumen
      appBar: AppBar(
        title: const Text('Supporting Document', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          // Tombol Download Animasi Loading
          _isDownloading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: _downloadFile,
                  tooltip: 'Download Document',
                ),
        ],
      ),
      body: Center(
        child: _isPdf
            // Render PDF Interaktif
            ? SfPdfViewer.network(widget.url)
            // Render Gambar dengan fitur Zoom in/out (InteractiveViewer)
            : InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('Failed to load image',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
      ),
    );
  }
}
