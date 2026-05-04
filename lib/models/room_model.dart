import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name;
  final List<String> barangTersedia;
  final String description;
  final String gambar;
  final String capacity;

  RoomModel({
    required this.id,
    required this.name,
    required this.barangTersedia,
    required this.description,
    required this.gambar,
    required this.capacity,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return RoomModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Room',
      // Memastikan tipe data Firebase Array menjadi List<String> Dart
      barangTersedia: List<String>.from(data['barangTersedia'] ?? []),
      description: data['description'] ?? 'Tidak ada deskripsi',
      gambar: data['gambar'] ?? 'assets/placeholder.png',
      capacity: data['capacity']?.toString() ?? '0',
    );
  }

  static String _readImagePath(Map<String, dynamic> data, String roomId) {
    final rawPath =
        data['imagePath'] ?? data['gambar'] ?? data['foto'] ?? data['photo'];

    if (rawPath is String && rawPath.trim().isNotEmpty) {
      final path = rawPath.trim();
      if (path.startsWith('assets/')) return path;
      return 'assets/images/ruangan/$path';
    }

    return 'assets/images/ruangan/$roomId.png';
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
