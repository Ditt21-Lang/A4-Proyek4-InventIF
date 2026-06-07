import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import '../../models/transaction_model.dart';

class ListPengajuanController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getFilteredStream(String status) {
    // [VAR DUMP 1] Cek parameter status apa yang dikirim oleh tombol UI
    debugPrint("🔍 [DEBUG] UI meminta data untuk tab: '$status'");

    Query query = _firestore.collection('transactions')
        .where('category', isEqualTo: 'equipment');

    if (status == 'History') {
      query = query.where('status', whereIn: [
        'Approved', 'Returned', 'Selesai', 'completed', 'dikembalikan'
      ]);
    } 
    // PERBAIKAN: Tangkap kata 'Borrowed' jika UI menggunakan kata tersebut!
    else if (status == 'In Use' || status == 'Borrowed') { 
      query = query.where('status', whereIn: ['In Use', 'Returning']);
    } 
    else {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      // [VAR DUMP 2] Cek berapa data yang berhasil ditarik dari Firebase
      debugPrint("📦 [DEBUG] Ditemukan ${snapshot.docs.length} dokumen untuk tab '$status'");
      
      var list = snapshot.docs.map((doc) {
        var dataMap = doc.data() as Map<String, dynamic>;
        
        // [VAR DUMP 3] Intip langsung jeroan setiap dokumen yang ditarik (seperti print_r)
        // inspect(dataMap); // Hapus tanda komentar di awal baris ini jika ingin membongkar seluruh isi map

        debugPrint("   => Transaksi ID: ${doc.id} | Status Asli DB: ${dataMap['status']}");
        
        return TransactionModel.fromFirestore(doc);
      }).toList();

      // Logika pengurutan khusus untuk menaikkan 'Returning' ke paling atas
      list.sort((a, b) {
        if (a.status == 'Returning' && b.status != 'Returning') {
          return -1; 
        } else if (a.status != 'Returning' && b.status == 'Returning') {
          return 1;  
        } else {
          return b.createdAt.compareTo(a.createdAt);
        }
      });

      return list;
    });
  }

  Future<void> updateStatus(
      TransactionModel transaction, String newStatus) async {
    try {
      WriteBatch batch = _firestore.batch();

      // 1. Update transaksi
      DocumentReference txRef =
          _firestore.collection('transactions').doc(transaction.transactionId);
      batch.update(txRef, {'status': newStatus});

      // 2. Jika Teknisi meng-Approve peminjaman (status -> 'In Use'), ubah barang jadi 'In Use'
      if (newStatus == 'In Use') {
        for (var item in transaction.items) {
          DocumentReference eqRef =
              _firestore.collection('equipments').doc(item.id);
          batch.update(eqRef, {'status': 'In Use'});
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error mengupdate status: $e');
    }
  }
}
