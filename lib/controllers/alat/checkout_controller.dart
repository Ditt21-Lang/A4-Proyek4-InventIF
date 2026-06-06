import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../services/offline_service.dart';
import '../../services/cloudinary_service.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/notification_model.dart';

class CheckoutController extends ChangeNotifier {
  bool isCheckingOut = false;
  final OfflineService _offlineService = OfflineService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Variabel untuk menampung file dokumen pendukung
  File? pickedFile;
  String? documentLabel;

  // Fungsi untuk memilih dokumen (PDF/Image)
  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        pickedFile = File(result.files.single.path!);
        documentLabel = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  // Fungsi untuk mereset file (misal saat batal)
  void clearDocument() {
    pickedFile = null;
    documentLabel = null;
    notifyListeners();
  }

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

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User belum login");

      DocumentSnapshot userDoc =
          await db.collection('users').doc(currentUser.uid).get();
      UserModel userData =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      List<Map<String, dynamic>> itemsData = cartItems
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'type': 'equipment',
              })
          .toList();

      bool hasConnection =
          await InternetConnectionChecker.createInstance().hasConnection;

      String? attachmentUrl;

      if (hasConnection) {
        // === MODE ONLINE ===
        // 1. Upload dokumen jika ada
        if (pickedFile != null) {
          attachmentUrl = await _cloudinaryService.uploadFile(
              pickedFile!, 'checkout_documents');
          if (attachmentUrl == null) {
            throw Exception("Gagal mengunggah dokumen pendukung ke server.");
          }
        }

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
          'attachmentUrl': attachmentUrl, // Simpan URL dokumen
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
        // === MODE OFFLINE ===
        // Cegah checkout offline jika membutuhkan upload dokumen
        if (pickedFile != null) {
          throw Exception(
              "Anda sedang offline. Mohon aktifkan internet untuk memproses peminjaman lintas hari yang memerlukan unggah dokumen.");
        }

        Map<String, dynamic> offlineData = {
          'borrowerId': currentUser.uid,
          'borrowerIdentifier': userData.identifier,
          'borrowerName': userData.fullName,
          'items': itemsData,
          'category': 'equipment',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'details': 'Peminjaman mandiri aplikasi InventIF',
          'attachmentUrl': null,
          'status': 'In Use',
        };

        await _offlineService.savePendingRequest(offlineData);
        debugPrint("Checkout Disimpan Offline");

        final notificationsController = NotificationsController.instance;
        final pendingNotification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Pending Sync',
          body:
              'Peminjaman tersimpan offline. Mohon online-kan untuk sinkronisasi.',
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
      clearDocument(); // Bersihkan memori file setelah sukses
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Gagal melakukan checkout: $e");
      isCheckingOut = false;
      notifyListeners();

      // Jika errornya dari Exception kita sendiri, rethrow agar bisa ditangkap oleh UI (View)
      if (e is Exception) {
        rethrow;
      }
      return false;
    }
  }
}
