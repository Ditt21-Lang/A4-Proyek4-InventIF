import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import '../../models/room_model.dart';

class CalendarRuanganController extends ChangeNotifier {
  final RoomModel room;

  final List<TransactionModel> _bookings = [];
  bool _isLoading = true;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  CalendarRuanganController({required this.room}) {
    fetchBookings();
  }

  List<TransactionModel> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;

  List<TransactionModel> get selectedDateBookings {
    return _bookings
        .where((booking) => booking.overlapsDate(_selectedDate))
        .toList();
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = FirebaseFirestore.instance;
      
      // Coba ambil dari 'transactions' dulu
      var snapshot = await db
          .collection('transactions')
          .where('type', isEqualTo: 'room')
          .where('itemIds', arrayContains: room.id)
          .get();


      _bookings
        ..clear()
        ..addAll(snapshot.docs.map(TransactionModel.fromFirestore));
      _bookings.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      debugPrint('Berhasil mengambil ${_bookings.length} jadwal untuk ${room.name}');
    } catch (e) {
      debugPrint('Gagal mengambil jadwal ruangan: $e');
      _bookings.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    if (date.year != _focusedMonth.year || date.month != _focusedMonth.month) {
      _focusedMonth = DateTime(date.year, date.month);
    }
    notifyListeners();
  }

  void showPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void showNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  bool hasBookingOn(DateTime date) {
    return _bookings.any((booking) => booking.overlapsDate(date));
  }
}
