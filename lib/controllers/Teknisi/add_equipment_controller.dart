import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// IMPORT CLOUDINARY SERVICE YANG SUDAH ANDA MILIKI
import '../../services/cloudinary_service.dart';

class AddEquipmentController extends ChangeNotifier {
  bool isLoading = false;
  // Gunakan service Cloudinary yang sudah Anda buat sebelumnya
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Fungsi untuk menyimpan data alat baru beserta gambar
  Future<bool> addEquipment({
    required String id,
    required String name,
    required String description,
    required File? pickedImage,
  }) async {
    // Validasi wajib isi
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        description.trim().isEmpty ||
        pickedImage == null) {
      throw Exception('Semua bidang formulir, termasuk gambar, wajib diisi!');
    }

    isLoading = true;
    notifyListeners();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('equipments').doc(id.trim());

      // 1. Cek duplikasi ID Alat
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        throw Exception('ID Alat/Barcode ini sudah terdaftar di sistem!');
      }

      // 2. UNGGAH GAMBAR KE CLOUDINARY
      // Menggunakan fungsi uploadFile dari cloudinary_service.dart Anda
      // Parameter kedua ('equipment_images') adalah nama folder di Cloudinary (opsional/sesuaikan dengan service Anda)
      String? cloudinaryUrl =
          await _cloudinaryService.uploadFile(pickedImage, 'equipment_images');

      if (cloudinaryUrl == null) {
        throw Exception(
            'Gagal mengunggah gambar ke server. Periksa koneksi internet Anda!');
      }

      // 3. Simpan data alat baru ke Firestore dengan URL Gambar Baru
      await docRef.set({
        'name': name.trim(),
        'description': description.trim(),
        'status': 'Available',
        'image': cloudinaryUrl.trim(), // URL dari Cloudinary
      });

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
