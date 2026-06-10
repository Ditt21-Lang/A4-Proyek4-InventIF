import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class DashboardTeknisiController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> get transaksiPendingStream {
    return _firestore
        .collection('transactions')
        .where('status', whereIn: ['Waiting', 'Returning'])
        .where('category', isEqualTo: 'equipment')
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .where((tx) => tx.category.toLowerCase() == 'equipment')
          .toList();
      // Urutkan: Returning naik ke atas, lalu descending createdAt
      list.sort((a, b) {
        if (a.status == 'Returning' && b.status != 'Returning') return -1;
        if (a.status != 'Returning' && b.status == 'Returning') return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return list;
    });
  }

  // Teknisi ACC pengajuan (Waiting → In Use) ATAU ACC pengembalian (Returning → Returned)
  Future<void> confirmSubmission(TransactionModel transaction) async {
    try {
      WriteBatch batch = _firestore.batch();

      DocumentReference txRef =
          _firestore.collection('transactions').doc(transaction.transactionId);

      if (transaction.status == 'Returning') {
        // ACC pengembalian: transaksi selesai, barang kembali Available
        batch.update(txRef, {'status': 'Returned'});
        for (var item in transaction.items) {
          DocumentReference eqRef =
              _firestore.collection('equipments').doc(item.id);
          batch.update(eqRef, {'status': 'Available'});
        }
      } else {
        // ACC pengajuan pinjam: transaksi jadi In Use, barang jadi In Use
        batch.update(txRef, {'status': 'In Use'});
        for (var item in transaction.items) {
          DocumentReference eqRef =
              _firestore.collection('equipments').doc(item.id);
          batch.update(eqRef, {'status': 'In Use'});
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error konfirmasi pengajuan: $e');
    }
  }

  Future<String?> getBorrowerKTM(String borrowerId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(borrowerId).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        return data?['ktm'] as String?;
      }
    } catch (e) {
      debugPrint('Error getting borrower KTM: $e');
    }
    return null;
  }
}
