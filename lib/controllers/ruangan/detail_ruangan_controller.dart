import 'package:flutter/material.dart';

import '../../views/ruangan/calendar_ruangan_view.dart';
import 'calendar_ruangan_controller.dart';
import '../../models/room_model.dart';

class DetailRuanganController {
  final RoomModel room;

  const DetailRuanganController({required this.room});

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
