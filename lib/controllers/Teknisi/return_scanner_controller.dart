import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction_model.dart';

class ReturnScannerController extends ChangeNotifier {
  final TransactionModel transaction;
  List<String> scannedItemIds = [];
  bool isProcessing = false;

  ReturnScannerController(this.transaction);

  // Fungsi validasi saat QR disorot
  String processScannedCode(String scannedId) {
    if (isProcessing) return 'PROCESSING';

    // 1. Cek apakah barang ini BENAR dipinjam di transaksi ini?
    bool belongsToTransaction = transaction.items.any((item) => item.id == scannedId);
    if (!belongsToTransaction) return 'WRONG_ITEM';

    // 2. Cek apakah barang ini sudah di-scan sebelumnya?
    if (scannedItemIds.contains(scannedId)) return 'ALREADY_SCANNED';

    // 3. Lolos validasi, masukkan ke daftar ter-scan
    scannedItemIds.add(scannedId);
    notifyListeners();

    // 4. Cek apakah SEMUA barang sudah komplit di-scan?
    if (scannedItemIds.length == transaction.items.length) {
      return 'ALL_SCANNED';
    }
    return 'SUCCESS';
  }

  // Fungsi untuk menyelesaikan pengembalian setelah semua cocok
  Future<bool> completeReturn() async {
    isProcessing = true;
    notifyListeners();
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      // 1. Update transaksi jadi Selesai (Returned)
      DocumentReference txRef = db.collection('transactions').doc(transaction.transactionId);
      batch.update(txRef, {
        'status': 'Returned',
        'actualReturnDate': FieldValue.serverTimestamp(),
      });

      // 2. Bebaskan semua barang yang dikembalikan menjadi 'Available'
      for (var itemId in scannedItemIds) {
        DocumentReference eqRef = db.collection('equipments').doc(itemId);
        batch.update(eqRef, {'status': 'Available'});
      }

      await batch.commit();
      isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error complete return: $e");
      isProcessing = false;
      notifyListeners();
      return false;
    }
  }
}