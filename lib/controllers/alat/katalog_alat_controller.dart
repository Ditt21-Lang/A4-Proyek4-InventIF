import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib ditambahkan
import '../../models/equipment_model.dart';

class KatalogAlatController extends ChangeNotifier {
  List<EquipmentModel> _allEquipment = [];
  List<EquipmentModel> _displayedEquipment = [];

  bool _isLoading = true;
  String _searchQuery = '';

  List<EquipmentModel> get displayedEquipment => _displayedEquipment;
  bool get isLoading => _isLoading;

  KatalogAlatController() {
    fetchEquipmentData();
  }

  // --- MENGAMBIL DATA ASLI DARI FIREBASE ---
  Future<void> fetchEquipmentData() async {
    _isLoading = true;
    notifyListeners(); // Munculkan Skeleton Loading

    try {
      // Panggil koleksi 'equipments' dari database Firebase
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('equipments')
          .get();

      // Terjemahkan dokumen Firebase menjadi List<EquipmentModel>
      _allEquipment = snapshot.docs.map((doc) {
        return EquipmentModel.fromFirestore(doc);
      }).toList();

      _displayedEquipment = _allEquipment;
    } catch (e) {
      debugPrint("Gagal mengambil data dari Firebase: $e");
      // Jika error (misal internet mati), kosongkan list agar tidak crash
      _allEquipment = [];
      _displayedEquipment = [];
    }

    _isLoading = false;
    notifyListeners(); // Matikan Skeleton Loading dan tampilkan data
  }

  // Fungsi Search
  void searchEquipment(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _displayedEquipment = _allEquipment;
    } else {
      _displayedEquipment = _allEquipment
          .where((eq) => eq.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}