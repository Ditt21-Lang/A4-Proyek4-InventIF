import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;              // Kode Peminjaman
  final String borrowerId;      // NIM/NIP Peminjam
  final List<String> equipmentIds; // Kode Barang (Bisa lebih dari 1 alat)
  final DateTime startDate;     // Tanggal Pinjam
  final String approverId;      // NIP (Penyetuju)
  final DateTime endDate;       // Tanggal Pengembalian
  final String details;         // Detail Peminjaman
  final String status;          // Status

  TransactionModel({
    required this.id,
    required this.borrowerId,
    required this.equipmentIds,
    required this.startDate,
    required this.approverId,
    required this.endDate,
    required this.details,
    required this.status,
  });

  // Fungsi penerjemah dari data Firebase ke objek Dart/Flutter
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      borrowerId: data['NIM/NIP Peminjam'] ?? '',
      
      // Karena di Firebase bentuknya List (Array), kita pastikan jadi List<String>
      equipmentIds: List<String>.from(data['Kode Barang'] ?? []),
      
      // Menerjemahkan Timestamp khas Firebase menjadi DateTime khas Flutter
      startDate: data['Tanggal Pinjam'] != null 
          ? (data['Tanggal Pinjam'] as Timestamp).toDate() 
          : DateTime.now(),
          
      approverId: data['NIP'] ?? '',
      
      endDate: data['Tanggal Pengembalian'] != null 
          ? (data['Tanggal Pengembalian'] as Timestamp).toDate() 
          : DateTime.now(),
          
      details: data['Detail Peminjaman'] ?? '',
      status: data['status'] ?? 'Unknown',
    );
  }
}