import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ManageAccountController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get manage account data
  Future<UserModel?> getManageAccountData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return UserModel.fromMap(userData);
        }
      }
      return null;
    } catch (e) {
      print('Error loading manage account data: $e');
      return null;
    }
  }

  // Update personal info
  Future<bool> updatePersonalInfo({
    required String fullName,
    required String nickname,
    required String studentID,
    required String ktm,
    required String birthDate,
  }) async {
    return await UserService.updatePersonalInfo(
      fullName: fullName,
      nickname: nickname,
      studentID: studentID,
      ktm: ktm,
      birthDate: birthDate,
    );
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await UserService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // Update contact info
  Future<bool> updateContact({
    required String email,
    required String phoneNumber,
  }) async {
    return await UserService.updateContact(
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}
