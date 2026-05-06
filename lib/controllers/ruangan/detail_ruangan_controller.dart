import 'package:flutter/material.dart';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calendar belum tersedia')));
  }
}
