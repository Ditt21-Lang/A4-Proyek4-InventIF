import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Teknisi/transaksi_model.dart'; 

class DashboardTeknisiController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransaksiModel>> get transaksiPendingStream {
    return _firestore
        .collection('transactions') 
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransaksiModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> confirmSubmission(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).update({
        'status': 'Approved',
      });
    } catch (e) {
      debugPrint("Gagal meng-ACC data: $e");
    }
  }
}