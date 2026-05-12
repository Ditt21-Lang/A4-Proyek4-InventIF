import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user profile data
  Future<UserModel?> getUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return UserModel.fromMap(userData);
        } else {
          return UserModel(
            uid: currentUser.uid,
            identifier: '',
            email: currentUser.email ?? '',
            fullName: currentUser.displayName ?? 'User',
            ktm: '',
            role: 'user',
            createdAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  // Sign out user
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print('Error signing out: $e');
      return false;
    }
  }
}
