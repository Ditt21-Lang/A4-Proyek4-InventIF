import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart'; // <--- Menggunakan package excel
import '../../models/room_model.dart';
import '../../models/transaction_model.dart';

class ImportJadwalController extends ChangeNotifier {
  bool isLoading = false;
  int totalJadwalImported = 0;

  // Tanggal mulai dan akhir semester genap
  final DateTime semesterStart = DateTime(2026, 2, 9);
  final DateTime semesterEnd = DateTime(2026, 6, 13);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> importExcelJadwal() async {
    // 1. Buka dialog pemilih file khusus Excel (.xlsx)
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) return false;

    isLoading = true;
    totalJadwalImported = 0;
    notifyListeners();

    try {
      // 2. Baca file Excel
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Ambil daftar ruangan untuk pencocokan
      final roomSnapshot = await _firestore.collection('rooms').get();
      final List<RoomModel> rooms =
          roomSnapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList();

      var batch = _firestore.batch();
      int batchCount = 0;

      final validDays = {
        'SENIN': 1,
        'SELASA': 2,
        'RABU': 3,
        'KAMIS': 4,
        'JUMAT': 5
      };

      // 3. Looping seluruh sheet di dalam file Excel
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;

        for (var row in sheet.rows) {
          // Bersihkan cell yang kosong/null
          List<String> cleanRow = row
              .map((cell) => cell?.value?.toString().trim() ?? '')
              .where((text) => text.isNotEmpty)
              .toList();

          if (cleanRow.isEmpty) continue;

          String hariStr = cleanRow[0].toUpperCase();
          if (!validDays.containsKey(hariStr)) continue;

          // Cari format waktu "00.00-00.00"
          String? waktuStr;
          try {
            waktuStr = cleanRow.firstWhere(
                (e) => RegExp(r'\d{2}\.\d{2}-\d{2}\.\d{2}').hasMatch(e));
          } catch (_) {
            continue;
          }

          // Cari ID Ruangan (Misal Excel: "D108-Kelas", Database: "D-108")
          String? matchedRoomId;
          String? matchedRoomName;
          for (var cell in cleanRow) {
            String normalizedCell =
                cell.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
            for (var room in rooms) {
              String normalizedRoom = room.name
                  .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
                  .toLowerCase();
              if (normalizedCell.contains(normalizedRoom) ||
                  normalizedRoom.contains(normalizedCell)) {
                matchedRoomId = room.id;
                matchedRoomName = room.name;
                break;
              }
            }
            if (matchedRoomId != null) break;
          }

          if (matchedRoomId == null) continue;

          String kelas = cleanRow.last;
          String mataKuliah =
              cleanRow.length > 4 ? cleanRow[4] : "Perkuliahan Rutin";

          var waktuSplit = waktuStr.split('-');
          var jamMulai = waktuSplit[0].split('.');
          var jamSelesai = waktuSplit[1].split('.');

          // 4. Generate jadwal per minggu di kalender
          for (int i = 0;
              i <= semesterEnd.difference(semesterStart).inDays;
              i++) {
            DateTime currentDate = semesterStart.add(Duration(days: i));

            if (currentDate.weekday == validDays[hariStr]) {
              DateTime startDateTime = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day,
                  int.parse(jamMulai[0]),
                  int.parse(jamMulai[1]));
              DateTime endDateTime = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day,
                  int.parse(jamSelesai[0]),
                  int.parse(jamSelesai[1]));

              final docRef = _firestore.collection('transactions').doc();

              batch.set(docRef, {
                'transactionId': docRef.id,
                'borrowerId': 'system_admin',
                'borrowerName': 'Kelas $kelas',
                'category': 'room',
                'status': 'Approved',
                'eventName': mataKuliah,
                'details': 'Jadwal Perkuliahan Rutin Semester Genap',
                'startDate': startDateTime,
                'endDate': endDateTime,
                'createdAt': FieldValue.serverTimestamp(),
                'items': [
                  {'id': matchedRoomId, 'name': matchedRoomName, 'type': 'room'}
                ],
              });

              batchCount++;
              totalJadwalImported++;

              // Kirim ke Firebase per 400 data
              if (batchCount >= 400) {
                await batch.commit();
                batch = _firestore.batch();
                batchCount = 0;
              }
            }
          }
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error importing Excel: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
