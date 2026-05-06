import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String identifier; // NIM atau NIP
  final String email;
  final String role;       // Peminjam, Koordinator, Teknisi

  UserModel({
    required this.uid,
    required this.name,
    required this.identifier,
    required this.email,
    required this.role,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id, // uid mengambil dari ID Dokumen Firebase Auth
      name: data['name'] ?? 'Unknown User',
      identifier: data['identifier'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Peminjam', // Default role jika kosong
    );
  }
}