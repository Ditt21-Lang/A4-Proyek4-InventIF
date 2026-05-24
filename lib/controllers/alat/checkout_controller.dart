import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../services/offline_service.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/notification_model.dart';

class CheckoutController extends ChangeNotifier {
  bool isCheckingOut = false;
  final OfflineService _offlineService = OfflineService();

  Future<bool> processCheckout(
    List<EquipmentModel> cartItems,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (cartItems.isEmpty) return false;

    isCheckingOut = true;
    notifyListeners();

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // 1. Ambil UID pengguna yang sedang Login saat ini
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User belum login");

      // 2. Ambil data profilnya dari Firestore untuk mendapatkan identifier & nama
      DocumentSnapshot userDoc =
          await db.collection('users').doc(currentUser.uid).get();
      UserModel userData =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      // 3. Format daftar barang agar sesuai dengan format array object di TransactionModel
      List<Map<String, dynamic>> itemsData = cartItems
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'type': 'equipment',
              })
          .toList();

      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;

      if (hasConnection) {
        // === MODE ONLINE (Langsung ke Firebase) ===
        WriteBatch batch = db.batch();
        DocumentReference transactionRef = db.collection('transactions').doc();

        batch.set(transactionRef, {
          'borrowerId': currentUser.uid,
          'borrowerIdentifier': userData.identifier,
          'borrowerName': userData.fullName,
          'items': itemsData,
          'category': 'equipment',
          'startDate': startDate,
          'endDate': endDate,
          'details': 'Peminjaman mandiri aplikasi InventIF',
          'status': 'In Use',
          'createdAt': FieldValue.serverTimestamp(),
        });

        for (var equipment in cartItems) {
          DocumentReference equipmentRef =
              db.collection('equipments').doc(equipment.id);
          batch.update(equipmentRef, {'status': 'In Use'});
        }

        await batch.commit();
        debugPrint("Checkout Online Sukses");
      } else {
        // === MODE OFFLINE (Simpan ke Hive) ===
        Map<String, dynamic> offlineData = {
          'borrowerId': currentUser.uid,
          'borrowerIdentifier': userData.identifier,
          'borrowerName': userData.fullName,
          'items': itemsData,
          'category': 'equipment',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'details': 'Peminjaman mandiri aplikasi InventIF',
          'status': 'In Use',
        };

        await _offlineService.savePendingRequest(offlineData);
        debugPrint("Checkout Disimpan Offline");
        // Note: Status barang di layar tidak langsung berubah sampai HP dapat sinyal
        final notificationsController = NotificationsController.instance;
        final pendingNotification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Pending Sync',
          body:
              'Anda memiliki peminjaman yang tersimpan offline. Mohon online-kan untuk sinkronisasi.',
          timestamp: DateTime.now(),
        );
        await notificationsController.addNotification(pendingNotification,
            showSystem: true);
        await notificationsController.startRepeatingPendingReminder(
          minutes: 5,
          title: 'Pending Sync Reminder',
          body:
              'Segera online-kan aplikasi untuk menyinkronkan pinjaman offline.',
        );
      }

      isCheckingOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Gagal melakukan checkout: $e");
      isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }
}
