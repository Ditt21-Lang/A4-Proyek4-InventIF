import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/room_model.dart';

class KatalogRuanganController extends ChangeNotifier {
  List<RoomModel> _allRooms = [];
  List<RoomModel> _displayedRooms = [];
  List<RoomModel> _availableRoomsToday = [];

  bool _isLoading = true;
  String _searchQuery = '';

  List<RoomModel> get displayedRooms => _displayedRooms;
  List<RoomModel> get availableRoomsToday => _availableRoomsToday;
  bool get isLoading => _isLoading;

  KatalogRuanganController() {
    fetchRoomData();
  }

  Future<void> fetchRoomData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .get();

      _allRooms = snapshot.docs.map(RoomModel.fromFirestore).toList();
      await _calculateAvailableRoomsToday();
      _applySearch();
    } catch (e) {
      debugPrint('Gagal mengambil data ruangan dari Firebase: $e');
      _allRooms = [];
      _displayedRooms = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _calculateAvailableRoomsToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final txSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('category', isEqualTo: 'room')
          .where('status', whereIn: ['Waiting', 'Pending', 'In Use', 'Approved', 'pending_coordinator', 'coordinator_confirmed'])
          .get();

      Set<String> busyRoomIds = {};
      for (var doc in txSnapshot.docs) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        final endDate = (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();

        bool overlapsToday = startDate.isBefore(endOfDay) && endDate.isAfter(startOfDay);
        
        if (overlapsToday) {
           final items = data['items'] as List<dynamic>? ?? [];
           for (var item in items) {
             busyRoomIds.add(item['id']);
           }
        }
      }

      _availableRoomsToday = _allRooms.where((room) => !busyRoomIds.contains(room.id)).toList();
    } catch (e) {
      debugPrint('Error calculate available rooms: $e');
      _availableRoomsToday = _allRooms;
    }
  }

  void searchRooms(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _displayedRooms = _allRooms;
      return;
    }

    final query = _searchQuery.toLowerCase();
    _displayedRooms = _allRooms.where((room) {
      return room.name.toLowerCase().contains(query) ||
          room.description.toLowerCase().contains(query);
    }).toList();
  }
}
