import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/room_model.dart';

class KatalogRuanganController extends ChangeNotifier {
  List<RoomModel> _allRooms = [];
  List<RoomModel> _displayedRooms = [];

  bool _isLoading = true;
  String _searchQuery = '';

  List<RoomModel> get displayedRooms => _displayedRooms;
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
      _applySearch();
    } catch (e) {
      debugPrint('Gagal mengambil data ruangan dari Firebase: $e');
      _allRooms = [];
      _displayedRooms = [];
    }

    _isLoading = false;
    notifyListeners();
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
