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

  Future<void> updateStatus(String id, String statusBaru) async {
    try {
      await _firestore.collection('transactions').doc(id).update({
        'status': statusBaru,
      });
    } catch (e) {
      debugPrint("Gagal update status: $e");
    }
  }
}
