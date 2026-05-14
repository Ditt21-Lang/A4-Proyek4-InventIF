import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class ListPengajuanController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getFilteredStream(String status) {
    Query query = _firestore.collection('transactions');

    if (status == 'History') {
      // Ambil SEMUA status yang menandakan barang sudah selesai/kembali (Termasuk data lama)
      query = query.where('status', whereIn: [
        'Approved',
        'Returned',
        'Selesai',
        'completed',
        'dikembalikan'
      ]);
    } else {
      // Untuk status 'Waiting' dan 'In Use'
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Urutkan data secara lokal (Tanggal paling baru muncul di paling atas!)
      list.sort((a, b) => b.startDate.compareTo(a.startDate));

      return list;
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
