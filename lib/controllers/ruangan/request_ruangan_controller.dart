import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../services/cloudinary_service.dart';

class RequestRuanganController extends ChangeNotifier {
  RequestRuanganController({required this.room, DateTime? initialDate}) {
    final baseDate = initialDate ?? DateTime.now();
    _startDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      13,
      30,
    );
    _endDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      17,
      20,
    );
  }

  final RoomModel room;
  final eventNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DateTime _startDateTime;
  late DateTime _endDateTime;
  bool _isSubmitting = false;
  String? _documentLabel;
  File? _pickedFile;

  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  bool get isSubmitting => _isSubmitting;
  String? get documentLabel => _documentLabel;
  File? get pickedFile => _pickedFile;

  @override
  void dispose() {
    eventNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDocument() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['pdf'],
      // );

      // if (result != null && result.files.single.path != null) {
      //   _pickedFile = File(result.files.single.path!);
      //   _documentLabel = result.files.single.name;
      //   notifyListeners();
      // }
    } catch (e) {
      print('Error picking document: $e');
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final firstDate = today.subtract(const Duration(days: 1));
    final lastDate = today.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(_startDateTime, firstDate, lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    _startDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _startDateTime.hour,
      _startDateTime.minute,
    );

    if (!_endDateTime.isAfter(_startDateTime)) {
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
    }

    notifyListeners();
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );

    if (picked == null) return;

    _startDateTime = DateTime(
      _startDateTime.year,
      _startDateTime.month,
      _startDateTime.day,
      picked.hour,
      picked.minute,
    );

    if (!_endDateTime.isAfter(_startDateTime)) {
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
    }

    notifyListeners();
  }

  Future<void> pickEndDate(BuildContext context) async {
    final firstDate = _dateOnly(_startDateTime);
    final lastDate = _dateOnly(DateTime.now()).add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(_endDateTime, firstDate, lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    _endDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _endDateTime.hour,
      _endDateTime.minute,
    );

    if (!_endDateTime.isAfter(_startDateTime)) {
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
    }

    notifyListeners();
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime),
    );

    if (picked == null) return;

    _endDateTime = DateTime(
      _endDateTime.year,
      _endDateTime.month,
      _endDateTime.day,
      picked.hour,
      picked.minute,
    );

    if (!_endDateTime.isAfter(_startDateTime)) {
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
    }

    notifyListeners();
  }

  Future<bool> submitRequest() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final eventName = eventNameController.text.trim();
    final description = descriptionController.text.trim();

    if (eventName.isEmpty || description.isEmpty) {
      throw Exception('Event name dan description wajib diisi');
    }

    if (!_endDateTime.isAfter(_startDateTime)) {
      throw Exception('Waktu selesai harus setelah waktu mulai');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      String? attachmentUrl;
      if (_pickedFile != null) {
        attachmentUrl = await _cloudinaryService.uploadFile(
            _pickedFile!, 'surat_peminjaman');
        if (attachmentUrl == null) {
          throw Exception('Gagal mengupload dokumen ke Cloudinary');
        }
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.exists
          ? UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
          : null;

      final transactionRef = _firestore.collection('transactions').doc();
      final transaction = TransactionModel(
        transactionId: transactionRef.id,
        borrowerId: user.uid,
        borrowerName: (userData?.fullName?.trim().isNotEmpty ?? false)
            ? userData!.fullName!
            : (user.displayName?.trim().isNotEmpty == true
                ? user.displayName!
                : user.email ?? 'Unknown User'),
        items: [
          TransactionItem(id: room.id, name: room.name, type: 'room'),
        ],
        category: 'room',
        startDate: _startDateTime,
        endDate: _endDateTime,
        actualReturnDate: null,
        details: description,
        eventName: eventName,
        attachmentUrl: attachmentUrl,
        status: 'Waiting',
        createdAt: DateTime.now(),
      );

      await transactionRef.set(transaction.toMap());
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    final normalized = _dateOnly(value);
    if (normalized.isBefore(min)) return min;
    if (normalized.isAfter(max)) return max;
    return normalized;
  }
}
