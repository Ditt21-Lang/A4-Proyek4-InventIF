import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class DashboardTeknisiController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> get transaksiPendingStream {
    return _firestore
        .collection('transactions')
        .where('status', isEqualTo: 'Waiting')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .where((tx) => tx.category.toLowerCase() == 'equipment')
          .toList();
    });
  }

  // Teknisi ACC pengembalian -> Transaksi Selesai (Approved), Barang Tersedia lagi (Available)
  Future<void> confirmSubmission(TransactionModel transaction) async {
    try {
      WriteBatch batch = _firestore.batch();

      DocumentReference txRef =
          _firestore.collection('transactions').doc(transaction.transactionId);
      batch.update(txRef, {'status': 'Approved'});

      // UBAH BARANG JADI AVAILABLE
      for (var item in transaction.items) {
        DocumentReference eqRef =
            _firestore.collection('equipments').doc(item.id);
        batch.update(eqRef, {'status': 'Available'});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error konfirmasi pengajuan: $e');
    }
  }
}
