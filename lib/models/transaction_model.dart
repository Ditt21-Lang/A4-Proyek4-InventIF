import 'package:cloud_firestore/cloud_firestore.dart';

/// Kelas bantuan untuk memetakan Array of Objects di dalam transaksi
class TransactionItem {
  final String id;
  final String name;
  final String type; // 'room' atau 'equipment'

  TransactionItem({required this.id, required this.name, required this.type});

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
    return {'id': id, 'name': name, 'type': type};
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
  final DateTime?
  actualReturnDate; // Nullable (?) karena belum tentu sudah dikembalikan
  final String details;
  final String? eventName; // Nullable (?) karena alat tidak butuh nama event
  final String? attachmentUrl; // Nullable (?) opsional jika ada surat
  final String status;
  final DateTime createdAt;

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
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final parsedItems = _readItems(data);

    return TransactionModel(
      transactionId: doc.id,
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? 'Unknown',
      items: parsedItems,
      category: data['category'] ?? 'mixed',

      startDate: _readDateTime(data['startDate'] ?? data['Tanggal Pinjam']),
      endDate: _readDateTime(data['endDate'] ?? data['Tanggal Pengembalian']),

      actualReturnDate: data['actualReturnDate'] != null
          ? _readDateTime(data['actualReturnDate'])
          : null,
      eventName: data['eventName'],
      attachmentUrl: data['attachmentUrl'],

      details: (data['details'] ?? data['Detail Peminjaman'] ?? '').toString(),
      status: data['status'] ?? 'Draft',
      createdAt: _readDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'items': items.map((item) => item.toMap()).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'actualReturnDate': actualReturnDate != null
          ? Timestamp.fromDate(actualReturnDate!)
          : null,
      'details': details,
      'status': status,
      'category': category,
      'eventName': eventName,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool containsItem(String itemId, {String? type}) {
    return items.any((item) {
      final sameId = item.id == itemId;
      final sameType = type == null || item.type == type;
      return sameId && sameType;
    });
  }

  String get displayTitle {
    if (eventName != null && eventName!.trim().isNotEmpty) return eventName!;
    if (details.trim().isNotEmpty) return details;
    if (items.isNotEmpty) return items.map((item) => item.name).join(', ');
    return 'Untitled Transaction';
  }

  static List<TransactionItem> _readItems(Map<String, dynamic> data) {
    final rawItems = data['items'];
    if (rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) => TransactionItem.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final itemIds = data['itemIds'];
    final itemName = (data['itemName'] ?? '').toString();
    final type = (data['type'] ?? data['category'] ?? 'equipment').toString();

    if (itemIds is List && itemIds.isNotEmpty) {
      final names = itemName
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      return itemIds.asMap().entries.map((entry) {
        return TransactionItem(
          id: entry.value.toString(),
          name: entry.key < names.length
              ? names[entry.key]
              : entry.value.toString(),
          type: type.toLowerCase(),
        );
      }).toList();
    }

    final oldEquipmentIds = data['Kode Barang'];
    if (oldEquipmentIds is List && oldEquipmentIds.isNotEmpty) {
      return oldEquipmentIds
          .map(
            (id) => TransactionItem(
              id: id.toString(),
              name: id.toString(),
              type: 'equipment',
            ),
          )
          .toList();
    }

    return [];
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
    bool isSameDayStart =
        startDate.year == date.year &&
        startDate.month == date.month &&
        startDate.day == date.day;

    // Logika 2: Cek overlap standar (Start < DayEnd DAN End >= DayStart)
    bool standardOverlap =
        startDate.isBefore(dayEnd) &&
        (endDate.isAfter(dayStart) || endDate.isAtSameMomentAs(dayStart));

    return isSameDayStart || standardOverlap;
  }
}
