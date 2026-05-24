import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class CoordinatorDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get today's room submissions (status: Waiting/Pending)
  Stream<List<TransactionModel>> getTodayRoomSubmissions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore.collection('transactions').snapshots().map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Filter for:
      // 1. Category is 'room'
      // 2. Status is 'Waiting' or 'Pending'
      // 3. Start date is today
      // 4. Sort by newest first
      list = list.where((tx) {
        final isRoom = tx.category.toLowerCase() == 'room';
        final isPending = tx.status == 'Waiting' ||
            tx.status == 'Pending' ||
            tx.status == 'pending_coordinator';
        final isToday = tx.startDate.year == today.year &&
            tx.startDate.month == today.month &&
            tx.startDate.day == today.day;

        return isRoom && isPending && isToday;
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Get room submissions history (status: Approved/Completed)
  Stream<List<TransactionModel>> getRoomSubmissionHistory() {
    return _firestore.collection('transactions').snapshots().map((snapshot) {
      var list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Filter for:
      // 1. Category is 'room'
      // 2. Status is 'Approved', 'Completed', 'confirmed', etc
      // 3. Sort by newest first
      list = list.where((tx) {
        final isRoom = tx.category.toLowerCase() == 'room';
        final isApproved = tx.status == 'Approved' ||
            tx.status == 'Completed' ||
            tx.status == 'completed' ||
            tx.status == 'confirmed' ||
            tx.status == 'coordinator_confirmed';

        return isRoom && isApproved;
      }).toList();

      list.sort((a, b) => b.startDate.compareTo(a.startDate));
      return list;
    });
  }

  /// Search room submissions history
  Stream<List<TransactionModel>> searchRoomSubmissionHistory(String query) {
    return getRoomSubmissionHistory().map((list) {
      if (query.isEmpty) return list;

      return list.where((tx) {
        final nameMatch =
            tx.borrowerName.toLowerCase().contains(query.toLowerCase());
        final roomMatch = tx.itemNames.toLowerCase().contains(query.toLowerCase());
        final detailsMatch =
            tx.details.toLowerCase().contains(query.toLowerCase());

        return nameMatch || roomMatch || detailsMatch;
      }).toList();
    });
  }

  /// Confirm submission (update status to confirmed)
  Future<void> confirmSubmission(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.transactionId)
          .update({
        'status': 'coordinator_confirmed',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error confirming submission: $e');
      rethrow;
    }
  }

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

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
}
