import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/equipment_model.dart';

class EquipmentListController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // Stream untuk mengambil data alat real-time
  Stream<List<EquipmentModel>> getEquipmentStream() {
    return _firestore.collection('equipments').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EquipmentModel.fromFirestore(doc))
          .toList();
    });
  }

  // Fungsi untuk Menghapus Alat
  Future<bool> deleteEquipment(String id) async {
    _isProcessing = true;
    notifyListeners();
    try {
      await _firestore.collection('equipments').doc(id).delete();
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      debugPrint("Gagal menghapus alat: $e");
      return false;
    }
  }

  // Fungsi untuk Mengubah Data Alat (Edit)
  Future<bool> updateEquipment({
    required String id,
    required String newName,
    required String newDesc,
  }) async {
    try {
      await _firestore.collection('equipments').doc(id).update({
        'name': newName.trim(),
        'description': newDesc.trim(),
      });
      return true;
    } catch (e) {
      debugPrint("Gagal memperbarui data alat: $e");
      return false;
    }
  }
}
