import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'offline_service.dart';

class NetworkService {
  final OfflineService _offlineService = OfflineService();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  void startMonitoring() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      
      if (!results.contains(ConnectivityResult.none)) {
        bool hasInternet = await InternetConnectionChecker.createInstance().hasConnection;
        
        if (hasInternet) {
          print("Sinkronisasi");
          await _syncDataToServer();
        } else {
          print("Tidak ada internet");
        }
      } else {
        print("Sinyal TERPUTUS. Aplikasi masuk mode OFFLINE.");
      }
    });
  }
  Future<void> _syncDataToServer() async {
    List<Map<String, dynamic>> pendingData = _offlineService.getAllPendingRequests();

    if (pendingData.isEmpty) {
      return;
    }

    try {
      for (var data in pendingData) {
        await FirebaseFirestore.instance.collection('transactions').add(data);
        
        print("Berhasil mengirim data ke Firebase: $data");
      }
      await _offlineService.clearAllRequests();
      print("SINKRONISASI SUKSES!");

    } catch (e) {
      print("GAGAL mengirim data: $e");
    }
  }
  void stopMonitoring() {
    _subscription.cancel();
  }
}