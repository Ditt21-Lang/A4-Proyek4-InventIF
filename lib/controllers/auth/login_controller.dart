import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../notifications_controller.dart';
import 'package:flutter/material.dart';

class LoginController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function for email/password login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Retrieve user data from Firestore
      UserModel? userData =
          await getUserDataFromFirestore(userCredential.user!.uid);

      // Load notifications for the logged-in user
      await NotificationsController.instance.reloadForUser();

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
    } on SocketException {
      return {
        'success': false,
        'user': null,
        'userData': null,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'userData': null,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Function to send password reset email
  Future<Map<String, dynamic>> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter your email address first.'
      };
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset link has been sent to your email!',
      };
    } on FirebaseAuthException catch (e) {
      // Debugging line
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');

      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      // Debugging line
      debugPrint('GENERAL ERROR: $e');

      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // == Firestore User Management ==

  // Retrieve user data from Firestore by UID
  Future<UserModel?> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Get current user UID
  String? getCurrentUserUID() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Map Firebase auth error codes to user-friendly English messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email is not registered in our system.';
      case 'wrong-password':
        return 'The password you entered is incorrect.';
      case 'invalid-email':
        return 'Invalid email format. Use a @polban.ac.id address.';
      case 'invalid-credential':
        return 'Email not registered or wrong password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with upper/lower case and numbers.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
