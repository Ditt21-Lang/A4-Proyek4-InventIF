import 'package:cloud_firestore/cloud_firestore.dart';

class TransaksiModel {
  final String id;
  final String namaPeminjam;
  final String namaItem;
  String status;

  TransaksiModel({
    required this.id,
    required this.namaPeminjam,
    required this.namaItem,
    required this.status,
  });

  factory TransaksiModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransaksiModel(
      id: doc.id, 
      namaPeminjam: data['namaPeminjam'] ?? 'Tanpa Nama',
      namaItem: data['namaItem'] ?? 'Item Tidak Diketahui',
      status: data['status'] ?? 'Pending',
    );
  }
}