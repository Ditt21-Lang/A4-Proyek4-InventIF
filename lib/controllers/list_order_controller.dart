import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wajib ditambahkan untuk mengecek siapa yang login
import '../../models/transaction_model.dart';

class ListOrderController extends ChangeNotifier {
  List<TransactionModel> _orders = [];
  bool _isLoading = true;

  List<TransactionModel> get orders => _orders;
  bool get isLoading => _isLoading;

  ListOrderController() {
    // Ubah dari fetch satu kali menjadi mendengarkan data (listen)
    listenToUserOrders();
  }

  void listenToUserOrders() {
    _isLoading = true;
    notifyListeners();

    // 1. Ambil UID dari user yang sedang login di Firebase Auth saat ini
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      debugPrint("Gagal memuat list: User belum login");
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 2. Gunakan .snapshots().listen() agar layar pengguna otomatis ter-update
    //    setiap kali Teknisi mengubah status di Firestore
    FirebaseFirestore.instance
        .collection('transactions')
        .where('borrowerId', isEqualTo: currentUser.uid)
        // Opsional: .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders = snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(doc);
      }).toList();

      _isLoading = false;
      notifyListeners(); // Beritahu UI untuk render ulang dengan warna baru
    }, onError: (error) {
      debugPrint("Gagal mengambil data riwayat: $error");
      _orders = [];
      _isLoading = false;
      notifyListeners();
    });
  }
}
