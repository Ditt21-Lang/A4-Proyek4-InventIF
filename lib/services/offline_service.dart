import 'package:hive_flutter/hive_flutter.dart';

class OfflineService {
  final _box = Hive.box('pending_requests');
  Future<void> savePendingRequest(Map<String, dynamic> dataPengajuan) async {
    dataPengajuan['createdAt'] = DateTime.now().toIso8601String();
    await _box.add(dataPengajuan);
    print("Data tersimpan secara offline");
  }

  List<Map<String, dynamic>> getAllPendingRequests() {
    return _box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  Future<void> clearAllRequests() async {
    await _box.clear();
    print("Berhasil membersihkan hive");
  }
}