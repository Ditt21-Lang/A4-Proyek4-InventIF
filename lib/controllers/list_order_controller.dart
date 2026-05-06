import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class ListOrderController extends ChangeNotifier {
  List<TransactionModel> _orders = [];
  bool _isLoading = true;

  List<TransactionModel> get orders => _orders;
  bool get isLoading => _isLoading;

  ListOrderController() {
    // Sebagai permulaan, kita panggil data dengan dummy userId.
    // Nanti ganti dengan ID user yang sedang login.
    fetchUserOrders('NIM-DUMMY-123'); 
  }

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mengambil data dari koleksi transactions, di mana borrowerId cocok
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('borrowerId', isEqualTo: userId)
          // Opsional: Urutkan dari yang terbaru (membutuhkan index di Firebase)
          // .orderBy('createdAt', descending: true) 
          .get();

      _orders = snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(doc);
      }).toList();
      
    } catch (e) {
      debugPrint("Gagal mengambil data riwayat: $e");
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}