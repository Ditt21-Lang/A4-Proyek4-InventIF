import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/equipment_model.dart';

class CheckoutController extends ChangeNotifier {
  bool isCheckingOut = false;

  Future<bool> processCheckout(
    List<EquipmentModel> cartItems,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (cartItems.isEmpty) return false;

    isCheckingOut = true;
    notifyListeners();

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      // MENGGUNAKAN FORMAT TransactionModel YANG BARU
      DocumentReference transactionRef = db.collection('transactions').doc();
      
      batch.set(transactionRef, {
        'type': 'equipment',
        'borrowerId': 'NIM-DUMMY-123', 
        'borrowerName': 'Dummy Borrower',
        'borrowerEmail': 'dummy@student.telkomuniversity.ac.id',
        'itemIds': cartItems.map((e) => e.id).toList(), 
        'itemName': cartItems.map((e) => e.name).join(', '),
        'startDate': Timestamp.fromDate(startDate), 
        'endDate': Timestamp.fromDate(endDate), 
        'details': 'Peminjaman mandiri aplikasi InventIF',
        'status': 'Dipinjam', 
        'approverId': '',
        'category': 'Equipment',
      });

      // UBAH STATUS BARANG FISIK MENJADI "In Use"
      for (var equipment in cartItems) {
        DocumentReference equipmentRef = db.collection('equipments').doc(equipment.id);
        batch.update(equipmentRef, {'status': 'In Use'});
      }

      await batch.commit();

      isCheckingOut = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint("Gagal melakukan checkout: $e");
      isCheckingOut = false;
      notifyListeners();
      return false; 
    }
  }
}