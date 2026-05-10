import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wajib untuk cek user login
import '../../models/equipment_model.dart';
import '../../models/user_model.dart'; // Wajib untuk ambil NIM

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

      // 1. Ambil UID pengguna yang sedang Login saat ini
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User belum login");

      // 2. Ambil data profilnya dari Firestore untuk mendapatkan identifier & nama
      DocumentSnapshot userDoc =
          await db.collection('users').doc(currentUser.uid).get();
      UserModel userData =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      WriteBatch batch = db.batch();

      // 3. Format daftar barang agar sesuai dengan format array object di TransactionModel
      List<Map<String, dynamic>> itemsData = cartItems
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'type': 'equipment',
              })
          .toList();

      DocumentReference transactionRef = db.collection('transactions').doc();

      // 4. Simpan ke Firebase dengan field yang COCOK dengan TransactionModel
      batch.set(transactionRef, {
        // UID tetap dijadikan borrowerId agar query di HP pengguna (List Order) berjalan lancar
        'borrowerId': currentUser.uid,

        // Simpan identifier/NIM secara terpisah sebagai referensi untuk Teknisi
        'borrowerIdentifier': userData.identifier,
        'borrowerName': userData.fullName ?? 'Unknown',
        'items': itemsData,
        'category': 'equipment',
        'startDate': startDate,
        'endDate': endDate,
        'details': 'Peminjaman mandiri aplikasi InventIF',
        'status': 'Dipinjam',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Ubah status barang fisik di database menjadi "Waiting"
      for (var equipment in cartItems) {
        DocumentReference equipmentRef =
            db.collection('equipments').doc(equipment.id);
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
