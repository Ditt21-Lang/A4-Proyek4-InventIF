import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { room, equipment }

class TransactionModel {
  final String id;
  final String type; // 'room' atau 'equipment'
  final String borrowerId;
  final String borrowerName;
  final String borrowerEmail;
  final List<String> itemIds; // ID Ruangan atau ID Alat-alat
  final String itemName;      // Nama Ruangan atau Nama Alat utama
  final DateTime startDate;
  final DateTime endDate;
  final String details;       // Tujuan acara (untuk ruangan) atau detail peminjaman
  final String status;
  final String? approverId;
  final String? category;     // Kategori (khusus ruangan, misal: 'Seminar')

  TransactionModel({
    required this.id,
    required this.type,
    required this.borrowerId,
    required this.borrowerName,
    required this.borrowerEmail,
    required this.itemIds,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.details,
    required this.status,
    this.approverId,
    this.category,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Mencoba mendeteksi tipe jika tidak ada
    String type = data['type'] ?? (data['roomId'] != null ? 'room' : 'equipment');
    
    return TransactionModel(
      id: doc.id,
      type: type,
      borrowerId: (data['borrowerId'] ?? data['NIM/NIP Peminjam'] ?? '').toString(),
      borrowerName: (data['borrowerName'] ?? 'Unknown Borrower').toString(),
      borrowerEmail: (data['borrowerEmail'] ?? '').toString(),
      itemIds: data['itemIds'] != null 
          ? List<String>.from(data['itemIds'])
          : (data['Kode Barang'] != null 
              ? List<String>.from(data['Kode Barang'])
              : (data['roomId'] != null ? [data['roomId'].toString()] : [])),
      itemName: (data['itemName'] ?? data['roomName'] ?? '').toString(),
      startDate: _readDateTime(data['startDate'] ?? data['Tanggal Pinjam'] ?? data['startAt']),
      endDate: _readDateTime(data['endDate'] ?? data['Tanggal Pengembalian'] ?? data['endAt']),
      details: (data['details'] ?? data['Detail Peminjaman'] ?? data['eventName'] ?? data['title'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      approverId: (data['approverId'] ?? data['NIP'] ?? '').toString(),
      category: (data['category'] ?? 'General').toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'itemIds': itemIds,
      'itemName': itemName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'details': details,
      'status': status,
      'approverId': approverId,
      'category': category,
    };
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  bool overlapsDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Logika 1: Jika hari mulai sama dengan hari yang dicek
    bool isSameDayStart = startDate.year == date.year &&
        startDate.month == date.month &&
        startDate.day == date.day;

    // Logika 2: Cek overlap standar (Start < DayEnd DAN End >= DayStart)
    bool standardOverlap = startDate.isBefore(dayEnd) && 
                          (endDate.isAfter(dayStart) || endDate.isAtSameMomentAs(dayStart));

    return isSameDayStart || standardOverlap;
  }
}
