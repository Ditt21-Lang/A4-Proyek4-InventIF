import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/equipment_model.dart';

class QrScannerController extends ChangeNotifier {
  List<EquipmentModel> scannedEquipments = [];
  bool isProcessing = false;

  Future<String> processScannedCode(String scannedId) async {
    if (isProcessing) return 'PROCESSING';

    // Cek apakah sudah ada di keranjang
    if (scannedEquipments.any((eq) => eq.id == scannedId)) {
      return 'ALREADY_IN_CART';
    }

    isProcessing = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('equipments')
          .doc(scannedId)
          .get();

      if (doc.exists) {
        EquipmentModel equipment = EquipmentModel.fromFirestore(doc);

        // --- VALIDASI UTAMA ---
        // Jika status BUKAN 'Available', tolak dan beritahu alasannya
        if (equipment.status != 'Available') {
          isProcessing = false;
          notifyListeners();
          return 'NOT_AVAILABLE';
        }

        // Jika Available, masukkan ke keranjang
        scannedEquipments.add(equipment);
        isProcessing = false;
        notifyListeners();
        return 'SUCCESS';
      } else {
        isProcessing = false;
        notifyListeners();
        return 'NOT_FOUND';
      }
    } catch (e) {
      debugPrint("Gagal mencari barang: $e");
      isProcessing = false;
      notifyListeners();
      return 'ERROR';
    }
  }
}
