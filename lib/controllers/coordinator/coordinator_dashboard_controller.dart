import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';

class CoordinatorDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _lazyUpdateRoomStatus(List<TransactionModel> transactions) {
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.category.toLowerCase() == 'room') {
        if (tx.status == 'Booked' &&
            now.isAfter(tx.startDate) &&
            now.isBefore(tx.endDate)) {
          // Time to start using
          _firestore.collection('transactions').doc(tx.id).update({
            'status': 'In Use',
          }).catchError((e) => debugPrint('Lazy update failed: $e'));
        } else if ((tx.status == 'Booked' || tx.status == 'In Use') &&
            now.isAfter(tx.endDate)) {
          // Time ended
          _firestore.collection('transactions').doc(tx.id).update({
            'status': 'Completed',
          }).catchError((e) => debugPrint('Lazy update failed: $e'));
        }
      }
    }
  }

  /// Get today's active room submissions
  Stream<List<TransactionModel>> getTodayRoomSubmissions() {
    final today = DateTime.now();

    return _firestore.collection('transactions').snapshots().map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Trigger lazy update in the background
      _lazyUpdateRoomStatus(list);

      // Filter for:
      // 1. Category is 'room'
      // 2. Status is booked, in use, or completed
      // 3. Created date is today
      list = list.where((tx) {
        final isRoom = tx.category.toLowerCase() == 'room';
        final statusLower = tx.status.toLowerCase();
        final isValidStatus = statusLower == 'booked' ||
            statusLower == 'in use' ||
            statusLower == 'completed';
        final isCreatedToday = tx.createdAt.year == today.year &&
            tx.createdAt.month == today.month &&
            tx.createdAt.day == today.day;
            
        final isRoutine = (tx.eventName?.toLowerCase().contains('rutin') ?? false) ||
                          (tx.details.toLowerCase().contains('rutin'));

        return isRoom && isValidStatus && isCreatedToday && !isRoutine;
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Get room submissions history (all room transactions except routine classes)
  Stream<List<TransactionModel>> getRoomSubmissionHistory() {
    return _firestore.collection('transactions').snapshots().map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Trigger lazy update
      _lazyUpdateRoomStatus(list);

      // Filter for:
      // 1. Category is 'room'
      // 2. Exclude "jadwal rutin kuliah"
      list = list.where((tx) {
        final isRoom = tx.category.toLowerCase() == 'room';
        final isRoutine = (tx.eventName?.toLowerCase().contains('rutin') ?? false) ||
                          (tx.details.toLowerCase().contains('rutin'));
        return isRoom && !isRoutine;
      }).toList();

      // Sort by newest created first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Upload Official Letter (Surat Peminjaman Resmi)
  Future<void> uploadOfficialLetter(TransactionModel tx, String fileUrl) async {
    try {
      await _firestore.collection('transactions').doc(tx.id).update({
        'officialLetterUrl': fileUrl,
      });
    } catch (e) {
      debugPrint("Failed to upload official letter: $e");
      rethrow;
    }
  }
  /// Search room submissions history by name, room, or details
  Stream<List<TransactionModel>> searchRoomSubmissionHistory(String query) {
    return getRoomSubmissionHistory().map((list) {
      if (query.isEmpty) return list;

      return list.where((tx) {
        final nameMatch =
            tx.borrowerName.toLowerCase().contains(query.toLowerCase());
        final roomMatch =
            tx.itemNames.toLowerCase().contains(query.toLowerCase());
        final detailsMatch =
            tx.details.toLowerCase().contains(query.toLowerCase());

        return nameMatch || roomMatch || detailsMatch;
      }).toList();
    });
  }

  /// Filter room submissions by status
  Stream<List<TransactionModel>> getRoomSubmissionHistoryByStatus(
      String? status) {
    return getRoomSubmissionHistory().map((list) {
      if (status == null || status.isEmpty) return list;

      return list
          .where((tx) => tx.status.toLowerCase() == status.toLowerCase())
          .toList();
    });
  }

  // Confirm submission removed (no longer needs approval)


  /// Format date for display
  String formatTanggal(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

  /// Format time for display
  String formatWaktu(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get user profile (for dashboard greeting)
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
}
