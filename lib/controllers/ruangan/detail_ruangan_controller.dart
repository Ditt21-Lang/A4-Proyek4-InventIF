import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../views/ruangan/calendar_ruangan_view.dart';
import 'calendar_ruangan_controller.dart';
import '../../models/room_model.dart';

class DetailRuanganController extends ChangeNotifier {
  final RoomModel room;
  bool isCoordinator = false;

  DetailRuanganController({required this.room}) {
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['role'] == 'coordinator') {
          isCoordinator = true;
          notifyListeners(); // Refresh UI untuk memunculkan tombol Edit/Hapus
        }
      }
    } catch (e) {
      debugPrint('Gagal cek role: $e');
    }
  }

  Future<bool> deleteRoom() async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(room.id)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Gagal menghapus ruangan: $e');
      rethrow;
    }
  }

  String get title => room.name;
  String get description => room.description;
  String get capacity => room.capacity;
  List<String> get availableItems => room.barangTersedia;
  String get imagePath => room.gambar;

  void openCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarRuanganScreen(
          controller: CalendarRuanganController(room: room),
        ),
      ),
    );
  }
}
