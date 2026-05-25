import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDetailController extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> returnItem(String transactionId) async {
    isLoading = true;
    notifyListeners(); // Memberitahu UI untuk memunculkan efek loading

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .update({
        'status': 'Returning',
      });

      isLoading = false;
      notifyListeners();
      return true; // Berhasil
    } catch (e) {
      debugPrint('Error request pengembalian: $e');
      isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }
}
