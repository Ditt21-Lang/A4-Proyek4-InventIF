import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'dart:io';
import '../../services/cloudinary_service.dart';

class ManageAccountController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get manage account data
  Future<UserModel?> getManageAccountData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

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
    required String identifier,
    required String ktm,
    required String birthDate,
    required String kelas,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // 1. Upload gambar ke Cloudinary jika user memilih foto baru
      if (imageFile != null) {
        final CloudinaryService cloudinary = CloudinaryService();
        imageUrl = await cloudinary.uploadFile(imageFile, 'profile_images');
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // 2. Siapkan data teks yang akan diupdate
        Map<String, dynamic> updateData = {
          'fullName': fullName,
          'nickname': nickname,
          'identifier': identifier,
          'ktm': ktm,
          'dateOfBirth': birthDate,
          'kelas': kelas,
        };

        // 3. Jika upload gambar berhasil, tambahkan URL-nya ke dalam data Firestore
        if (imageUrl != null) {
          updateData['profileImage'] = imageUrl;
        }

        // 4. Update Firestore secara langsung (tanpa melalui UserService agar lebih ringkas)
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updateData);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile info: $e');
      return false;
    }
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
