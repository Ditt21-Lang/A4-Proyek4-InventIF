import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class ListPengajuanController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getFilteredStream(String status) {
    return _firestore
        .collection('transactions')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateStatus(
      TransactionModel transaction, String newStatus) async {
    try {
      WriteBatch batch = _firestore.batch();

      // 1. Update transaksi (misal menjadi 'Approved')
      DocumentReference txRef =
          _firestore.collection('transactions').doc(transaction.transactionId);
      batch.update(txRef, {'status': newStatus});

      // 2. Jika Teknisi meng-Approve pengembalian, ubah barang jadi Available
      if (newStatus == 'Approved') {
        for (var item in transaction.items) {
          DocumentReference eqRef =
              _firestore.collection('equipments').doc(item.id);
          batch.update(eqRef, {'status': 'Available'});
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error mengupdate status: $e');
    }
  }
}
