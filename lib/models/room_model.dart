import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name;
  final String description;
  final bool isAvailable;
  final int capacity;
  final List<String> availableItems;

  const RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isAvailable,
    required this.capacity,
    required this.availableItems,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return RoomModel(
      id: doc.id,
      name: data['name'] ?? data['nama'] ?? data['roomName'] ?? 'Unknown Room',
      description:
          data['description'] ??
          data['deskripsi'] ??
          data['detail'] ??
          'Tidak ada deskripsi',
      isAvailable: data['isAvailable'] ?? data['available'] ?? true,
      capacity: _toInt(data['capacity'] ?? data['kapasitas'] ?? 0),
      availableItems: _readAvailableItems(data),
    );
  }

  static List<String> _readAvailableItems(Map<String, dynamic> data) {
    final rawList =
        data['availableItems'] ?? data['barangTersedia'] ?? data['fasilitas'];

    if (rawList is List) {
      return rawList
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final itemEntries = data.entries.where((entry) {
      final key = entry.key.toLowerCase();
      return key.startsWith('barang') || key.startsWith('item');
    }).toList()..sort((a, b) => a.key.compareTo(b.key));

    return itemEntries
        .map((entry) => entry.value.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
