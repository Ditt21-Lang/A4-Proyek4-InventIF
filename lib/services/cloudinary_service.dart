import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary =
      CloudinaryPublic('inventif_unsigned', 'ddhiy2jhq', cache: false);

  /// Fungsi universal untuk mengupload gambar
  /// [folderName] bisa diisi 'ktm' atau 'profile_pics' agar rapi di Cloudinary
  Future<String?> uploadImage(File imageFile, String folderName) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folderName, // Otomatis membuat folder di Cloudinary
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Mengembalikan URL publik (HTTPS) yang bisa langsung disimpan ke Firestore
      return response.secureUrl;
    } catch (e) {
      print('Error upload ke Cloudinary: $e');
      return null;
    }
  }

  /// Fungsi universal untuk mengupload SEMUA JENIS FILE (Gambar, PDF, DOCX)
  Future<String?> uploadFile(File file, String folderName) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folderName,
          // --- UBAH BAGIAN INI MENJADI AUTO ---
          // Dengan 'Auto', Cloudinary akan otomatis mendeteksi apakah
          // yang masuk itu Gambar, Video, atau Raw file (seperti PDF/DOCX)
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print('Error upload ke Cloudinary: $e');
      return null;
    }
  }
}
