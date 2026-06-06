import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';

class AddRoomController extends ChangeNotifier {
  bool isLoading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<bool> addRoom({
    required String id,
    required String name,
    required String capacity, // <--- TAMBAHAN BARU
    required String description,
    required File? pickedImage,
  }) async {
    // Validasi
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        capacity.trim().isEmpty ||
        description.trim().isEmpty ||
        pickedImage == null) {
      throw Exception(
          'ID, Nama, Kapasitas, Deskripsi, dan Gambar wajib diisi!');
    }

    isLoading = true;
    notifyListeners();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('rooms').doc(id.trim());

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        throw Exception('ID Ruangan ini sudah terdaftar di sistem!');
      }

      String? cloudinaryUrl =
          await _cloudinaryService.uploadFile(pickedImage, 'room_images');
      if (cloudinaryUrl == null) {
        throw Exception(
            'Gagal mengunggah gambar ruangan. Periksa koneksi internet!');
      }

      await docRef.set({
        'id': id.trim(),
        'name': name.trim(),
        'description': description.trim(),
        'gambar': cloudinaryUrl.trim(),
        'capacity': capacity.trim(), // <--- SIMPAN DARI INPUTAN
        'barangTersedia': [],
        'createdAt': FieldValue.serverTimestamp(),
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
