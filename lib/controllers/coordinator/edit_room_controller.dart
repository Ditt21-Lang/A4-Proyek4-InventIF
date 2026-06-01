import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';

class EditRoomController extends ChangeNotifier {
  bool isLoading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<bool> updateRoom({
    required String id,
    required String name,
    required String capacity,
    required String description,
    required File? pickedImage,
    required String oldImageUrl,
  }) async {
    // Validasi dasar
    if (name.trim().isEmpty ||
        capacity.trim().isEmpty ||
        description.trim().isEmpty) {
      throw Exception('Nama, Kapasitas, dan Deskripsi wajib diisi!');
    }

    isLoading = true;
    notifyListeners();

    try {
      String finalImageUrl = oldImageUrl;

      // Jika koordinator memilih gambar baru, upload ulang ke Cloudinary
      if (pickedImage != null) {
        String? cloudinaryUrl =
            await _cloudinaryService.uploadFile(pickedImage, 'room_images');
        if (cloudinaryUrl == null)
          throw Exception(
              'Gagal mengunggah gambar baru. Periksa koneksi internet!');
        finalImageUrl = cloudinaryUrl.trim();
      }

      // Update data di Firestore
      await FirebaseFirestore.instance.collection('rooms').doc(id).update({
        'name': name.trim(),
        'description': description.trim(),
        'gambar': finalImageUrl,
        'capacity': capacity.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
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
