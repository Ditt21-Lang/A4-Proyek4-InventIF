import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String status;
  final String condition;
  final String imagePath;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.status,
    required this.condition,
    required this.imagePath,
  });

  // Fungsi penerjemah data dari Firebase ke Flutter
  factory EquipmentModel.fromFirestore(DocumentSnapshot doc) {
    // Ambil semua Field dari dokumen
    Map data = doc.data() as Map<String, dynamic>;
    
    return EquipmentModel(
      // id otomatis mengambil dari Document ID di Firebase (misal: INF-001)
      id: doc.id, 
      name: data['name'] ?? 'Unknown Name',
      status: data['status'] ?? 'Unknown',
      condition: data['condition'] ?? 'Unknown',
      imagePath: data['imagePath'] ?? 'assets/placeholder.png',
    );
  }
}