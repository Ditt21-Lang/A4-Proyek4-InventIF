import 'package:cloud_firestore/cloud_firestore.dart';

class TransaksiModel {
  final String id;
  final String borrowerName;
  final List<dynamic> items;
  String status;
  final DateTime? startDate;

  TransaksiModel({
    required this.id,
    required this.borrowerName,
    required this.items,
    required this.status,
    this.startDate,
  });

  factory TransaksiModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    DateTime? parsedTanggal;
    if (data['startDate'] != null) {
      parsedTanggal = (data['startDate'] as Timestamp).toDate();
    }

    return TransaksiModel(
      id: doc.id, 
      borrowerName: data['borrowerName'] ?? 'Tanpa Nama',
      items: data['items'] ?? [],
      status: data['status'] ?? 'Waiting',
      startDate: parsedTanggal,
    );
  }

  String get itemNames {
    if (items.isEmpty) return 'Tidak ada barang';
    return items.map((item) => item['name'].toString()).join(', ');
  }
}