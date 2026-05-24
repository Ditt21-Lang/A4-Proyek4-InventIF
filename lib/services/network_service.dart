import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'offline_service.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';
import '../main.dart';

class NetworkService {
  final OfflineService _offlineService = OfflineService();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  // Flag ingatan untuk mencegah spam SnackBar setiap kali aplikasi dimuat
  bool _wasOffline = false;

  void startMonitoring() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
          
      // Cek apakah tidak mode pesawat dan terhubung ke suatu jaringan (Wifi/Seluler)
      if (!results.contains(ConnectivityResult.none)) {
        // Validasi ping nyata ke internet
        bool hasInternet =
            await InternetConnectionChecker.createInstance().hasConnection;

        if (hasInternet) {
          // --- KONEKSI KEMBALI / ONLINE ---
          // HANYA munculkan SnackBar JIKA sebelumnya benar-benar terdeteksi offline
          if (_wasOffline) {
            globalMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Kembali Online! Menyinkronkan data...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            print("Sinkronisasi karena sinyal kembali");
            await _syncDataToServer();

            // Reset ingatan karena sekarang HP sudah dipastikan online
            _wasOffline = false;
          } else {
            // Jika aplikasi baru dibuka dan sudah online dari awal, 
            // lakukan sinkronisasi secara diam-diam (Gaib) tanpa SnackBar berisik.
            await _syncDataToServer();
          }
        } else {
          // --- TERHUBUNG JARINGAN TAPI TIDAK ADA INTERNET (Misal Wi-Fi belum login) ---
          if (!_wasOffline) {
            _showOfflineWarning();
            _wasOffline = true;
          }
        }
      } else {
        // --- TERPUTUS TOTAL (Mode Pesawat / Tidak ada Wi-Fi & Seluler) ---
        if (!_wasOffline) {
          _showOfflineWarning();
          _wasOffline = true;
        }
      }
    });
  }

  void _showOfflineWarning() {
    print("Sinyal TERPUTUS. Aplikasi masuk mode OFFLINE.");
    globalMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Anda sedang offline. Beberapa fitur dibatasi.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _syncDataToServer() async {
    List<Map<String, dynamic>> pendingData =
        _offlineService.getAllPendingRequests();

    if (pendingData.isEmpty) {
      return;
    }

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      for (var data in pendingData) {
        WriteBatch batch = db.batch();

        // 1. Buat dokumen transaksi baru
        DocumentReference txRef = db.collection('transactions').doc();

        // Ubah string tanggal dari Hive kembali menjadi Timestamp untuk Firebase
        data['createdAt'] = FieldValue.serverTimestamp();
        data['startDate'] = DateTime.parse(data['startDate']);
        data['endDate'] = DateTime.parse(data['endDate']);

        batch.set(txRef, data);

        // 2. Ubah status barang fisik di database menjadi "In Use"
        List<dynamic> items = data['items'];
        for (var item in items) {
          DocumentReference equipmentRef =
              db.collection('equipments').doc(item['id']);
          batch.update(equipmentRef, {'status': 'In Use'});
        }

        // Eksekusi batch
        await batch.commit();
        print("Berhasil mengirim data & update alat ke Firebase!");
      }

      // Bersihkan Hive setelah semua berhasil terkirim
      await _offlineService.clearAllRequests();

      // Hentikan notifikasi pengingat berulang karena data offline sudah disinkronkan
      final notifCtrl = NotificationsController.instance;
      await notifCtrl.stopRepeating();
      
      final successNote = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Sinkronisasi Tuntas',
        body: 'Semua permintaan checkout offline telah berhasil disinkronkan.',
        timestamp: DateTime.now(),
      );
      await notifCtrl.addNotification(successNote, showSystem: true);

      print("SINKRONISASI SUKSES!");
    } catch (e) {
      print("GAGAL sinkronisasi data: $e");
    }
  }

  void stopMonitoring() {
    _subscription.cancel();
  }
}