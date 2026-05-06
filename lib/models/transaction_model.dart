import 'package:cloud_firestore/cloud_firestore.dart';

/// Kelas bantuan untuk memetakan Array of Objects di dalam transaksi
class TransactionItem {
  final String id;
  final String name;
  final String type; // 'room' atau 'equipment'

  TransactionItem({
    required this.id, 
    required this.name, 
    required this.type
  });

  // Menerjemahkan dari Map Firebase ke Object Dart
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'equipment',
    );
  }
  
  // Berguna saat Anda ingin menulis (Create) data transaksi baru ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}

/// Kelas Utama Transaksi
class TransactionModel {
  final String transactionId;
  final String borrowerId;
  final String borrowerName;
  final List<TransactionItem> items; // Menggunakan kelas bantuan di atas
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? actualReturnDate;  // Nullable (?) karena belum tentu sudah dikembalikan
  final String details;
  final String? eventName;           // Nullable (?) karena alat tidak butuh nama event
  final String? attachmentUrl;       // Nullable (?) opsional jika ada surat
  final String status;
  final DateTime createdAt;

  // Alias agar UI Teknisi tetap bisa memanggil .id
  String get id => transactionId;

  // Menggabungkan array items menjadi satu teks String yang dipisahkan koma
  String get itemNames {
    if (items.isEmpty) return 'Unknown Item';
    return items.map((item) => item.name).join(', ');
  }

  TransactionModel({
    required this.transactionId,
    required this.borrowerId,
    required this.borrowerName,
    required this.items,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.actualReturnDate,
    required this.details,
    this.eventName,
    this.attachmentUrl,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Mapping khusus untuk Array of Objects (items)
    var itemsList = data['items'] as List? ?? [];
    List<TransactionItem> parsedItems = itemsList
        .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return TransactionModel(
      transactionId: doc.id,
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? 'Unknown',
      items: parsedItems,
      category: data['category'] ?? 'mixed',
      
      startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : DateTime.now(),
      
      // Nullable handling
      actualReturnDate: data['actualReturnDate'] != null ? (data['actualReturnDate'] as Timestamp).toDate() : null,
      eventName: data['eventName'],
      attachmentUrl: data['attachmentUrl'],
      
      details: data['details'] ?? '',
      status: data['status'] ?? 'Draft',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}