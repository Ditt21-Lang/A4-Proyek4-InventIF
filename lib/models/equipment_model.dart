import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String status;
  final String description;
  final String image;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.image,
  });

  factory EquipmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EquipmentModel(
      id: doc.id, 
      name: data['name'] ?? 'Unknown Equipment',
      status: data['status'] ?? 'Tersedia',
      description: data['description'] ?? 'Tidak ada deskripsi',
      image: data['image'] ?? 'assets/placeholder.png',
    );
  }
}