import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';

class EditEquipmentController extends ChangeNotifier {
  bool isLoading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<bool> updateEquipment({
    required String id,
    required String name,
    required String description,
    required String status,
    required String currentImageUrl,
    File? newImageFile, // Opsional, hanya terisi jika gambar diganti
  }) async {
    if (name.trim().isEmpty || description.trim().isEmpty) {
      throw Exception('Nama dan deskripsi alat wajib diisi!');
    }

    isLoading = true;
    notifyListeners();

    try {
      String finalImageUrl = currentImageUrl;

      // Jika Teknisi memilih gambar baru, unggah ke Cloudinary
      if (newImageFile != null) {
        String? uploadedUrl = await _cloudinaryService.uploadFile(
            newImageFile, 'equipment_images');
        if (uploadedUrl == null) {
          throw Exception(
              'Gagal mengunggah gambar baru ke server. Periksa koneksi Anda.');
        }
        finalImageUrl = uploadedUrl; // Ganti dengan URL baru
      }

      // Update dokumen di Firestore
      await FirebaseFirestore.instance.collection('equipments').doc(id).update({
        'name': name.trim(),
        'description': description.trim(),
        'status': status,
        'image': finalImageUrl,
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
