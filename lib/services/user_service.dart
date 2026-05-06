import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update personal info
  static Future<bool> updatePersonalInfo({
    required String fullName,
    required String nickname,
    required String studentID,
    required String ktm,
    required String birthDate,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'fullName': fullName,
          'nickname': nickname,
          'studentID': studentID,
          'ktm': ktm,
          'dateOfBirth': birthDate,
        });
        
        // Update display name di Firebase Auth
        await currentUser.updateDisplayName(fullName);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating personal info: $e');
      return false;
    }
  }

  // Change password
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      
      await currentUser.reauthenticateWithCredential(credential);
      
      // Update password
      await currentUser.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Update contact info
  static Future<bool> updateContact({
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'email': email,
          'phoneNumber': phoneNumber,
        });
        
        // Update email di Firebase Auth jika berbeda
        if (email != currentUser.email) {
          await currentUser.verifyBeforeUpdateEmail(email);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating contact info: $e');
      return false;
    }
  }
}
