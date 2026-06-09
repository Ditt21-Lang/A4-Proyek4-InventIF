import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../notifications_controller.dart';
import 'package:flutter/material.dart';

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
      UserModel? userData =
          await getUserDataFromFirestore(userCredential.user!.uid);

      // Muat notifikasi untuk user yang sedang login
      await NotificationsController.instance.reloadForUser();

      return {
        'success': true,
        'user': userCredential.user,
        'userData': userData,
        'message': 'Login berhasil!',
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
        'message': 'Tidak ada koneksi internet. Periksa jaringan Anda.',
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

  // Fungsi untuk mengirim email Reset Password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Harap masukkan email Anda terlebih dahulu.'
      };
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Tautan reset password telah dikirim ke email Anda!',
      };
    } on FirebaseAuthException catch (e) {
      // TAMBAHKAN BARIS INI UNTUK DEBUGGING
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');

      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      // TAMBAHKAN BARIS INI UNTUK DEBUGGING
      debugPrint('GENERAL ERROR: $e');

      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
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
        return 'Email tidak terdaftar di sistem kami.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'invalid-email':
        return 'Format email tidak valid. Gunakan email @polban.ac.id.';
      case 'invalid-credential':
        return 'Email tidak terdaftar atau password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 8 karakter dengan huruf besar, kecil, dan angka.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
