import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LoginController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk login dengan Email dan Password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Ambil user data dari Firestore
      UserModel? userData = await getUserDataFromFirestore(userCredential.user!.uid);

      return {
        'success': true,
        'user': userCredential.user,
        'userData': userData,
        'message': 'Login successful!',
      };
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'user': null,
        'userData': null,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'userData': null,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk Forgot Password - mengirim reset email
  // ONPROGRESS
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message':
            'Password reset email has been sent. Check your inbox or spam folder.',
      };
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // == Firestore User Management ==

  // Ambil user data dari Firestore berdasarkan UID
  Future<UserModel?> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Cek apakah user sudah login
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Ambil UID user yang sedang login
  String? getCurrentUserUID() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Stream untuk listen perubahan user authentication
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Fungsi untuk mendapatkan pesan error yang user-friendly
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email is not registered in our system.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
