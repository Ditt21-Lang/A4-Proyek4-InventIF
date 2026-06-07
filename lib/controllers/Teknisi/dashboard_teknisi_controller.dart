import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class DashboardTeknisiController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> get transaksiPendingStream {
    return _firestore
        .collection('transactions')
        .where('status', isEqualTo: 'Waiting')
        .where('category', isEqualTo: 'equipment')
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .where((tx) => tx.category.toLowerCase() == 'equipment')
          .toList();
      // Urutkan dari yang terbaru (descending) di sisi Dart
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Teknisi ACC pengembalian -> Transaksi Selesai (Approved), Barang Tersedia lagi (Available)
  Future<void> confirmSubmission(TransactionModel transaction) async {
    try {
      WriteBatch batch = _firestore.batch();

      DocumentReference txRef =
          _firestore.collection('transactions').doc(transaction.transactionId);
      batch.update(txRef, {'status': 'In Use'});

      // UBAH BARANG JADI IN USE
      for (var item in transaction.items) {
        DocumentReference eqRef =
            _firestore.collection('equipments').doc(item.id);
        batch.update(eqRef, {'status': 'In Use'});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error konfirmasi pengajuan: $e');
    }
  }
}
