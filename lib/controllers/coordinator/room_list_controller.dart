import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/room_model.dart'; // Pastikan path model ini sesuai dengan struktur Anda

class RoomListController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mengambil data ruangan real-time
  Stream<List<RoomModel>> getRoomsStream() {
    return _firestore.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Asumsi RoomModel memiliki factory fromFirestore
        // Jika tidak, Anda bisa menggunakan fromMap(doc.data() as Map<String, dynamic>)
        return RoomModel.fromFirestore(doc);
      }).toList();
    });
  }
}
