import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class RegisterController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // SendGrid Configuration
  // ⚠️ IMPORTANT: Ganti dengan API key Anda sendiri dari SendGrid
  static const String SENDGRID_API_KEY = 'SG.YOUR_SENDGRID_API_KEY_HERE'; // <-- GANTI DI SINI
  static const String SENDGRID_FROM_EMAIL = 'noreply@inventif.app'; // <-- Update dengan sender email Anda

  // Variable untuk store verification data sementara
  String? _verificationId;
  String? _tempPhoneNumber;
  String? _tempEmail;
  int? _resendToken;

  // === OTP VERIFICATION FLOW ===

  // Fungsi untuk kirim OTP ke nomor HP
  Future<Map<String, dynamic>> sendPhoneOTP(String phoneNumber) async {
    try {
      _tempPhoneNumber = phoneNumber;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-retrieve SMS (untuk Android)
          print('Phone auto-verified');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          print('OTP sent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return {
        'success': true,
        'message': 'OTP berhasil dikirim ke $phoneNumber',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim OTP: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk kirim OTP ke email menggunakan SendGrid
  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      _tempEmail = email;
      
      // Generate random OTP code (6 digits)
      String otpCode = (100000 + DateTime.now().microsecond % 900000).toString();
      
      // Simpan OTP temporary ke Firestore dengan expiry
      await _firestore.collection('otp_temp').doc(email).set({
        'code': otpCode,
        'email': email,
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
        'attempts': 0,
      });

      // Kirim email via SendGrid API
      bool emailSent = await _sendEmailViaSendGrid(
        recipientEmail: email,
        otpCode: otpCode,
      );

      if (!emailSent) {
        // Jika gagal kirim email, hapus OTP dari Firestore
        await _firestore.collection('otp_temp').doc(email).delete();
        return {
          'success': false,
          'message': 'Gagal mengirim OTP ke email. Pastikan SendGrid API key sudah dikonfigurasi.',
        };
      }

      return {
        'success': true,
        'message': 'OTP berhasil dikirim ke $email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim OTP: ${e.toString()}',
      };
    }
  }

  // Helper method untuk kirim email via SendGrid API
  Future<bool> _sendEmailViaSendGrid({
    required String recipientEmail,
    required String otpCode,
  }) async {
    try {
      // Cek apakah API key sudah dikonfigurasi
      if (SENDGRID_API_KEY == 'SG.YOUR_SENDGRID_API_KEY_HERE') {
        print('⚠️ SendGrid API key belum dikonfigurasi. Silahkan update di RegisterController.');
        print('📧 OTP Code untuk testing: $otpCode');
        // Untuk development, tetap return true agar flow lanjut
        return true;
      }

      const String sendgridUrl = 'https://api.sendgrid.com/v3/mail/send';

      final response = await http.post(
        Uri.parse(sendgridUrl),
        headers: {
          'Authorization': 'Bearer $SENDGRID_API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {
                  'email': recipientEmail,
                }
              ],
              'subject': 'InventIF - OTP Verification Code',
            }
          ],
          'from': {
            'email': SENDGRID_FROM_EMAIL,
            'name': 'InventIF App',
          },
          'content': [
            {
              'type': 'text/html',
              'value': _generateEmailHTML(otpCode),
            }
          ],
        }),
      );

      if (response.statusCode == 202) {
        print('✅ Email sent successfully to $recipientEmail');
        return true;
      } else {
        print('❌ SendGrid Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: ${e.toString()}');
      return false;
    }
  }

  // Generate HTML email template
  String _generateEmailHTML(String otpCode) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; background-color: #f4f4f4; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; }
            .header { background-color: #2A2C8F; color: white; padding: 20px; text-align: center; border-radius: 8px; }
            .content { padding: 20px; }
            .otp-box { background-color: #f0f0f0; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; }
            .otp-code { font-size: 32px; font-weight: bold; color: #2A2C8F; letter-spacing: 5px; }
            .footer { text-align: center; color: #888; font-size: 12px; margin-top: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>InventIF</h1>
                <p>Email Verification</p>
            </div>
            <div class="content">
                <h2>Verify Your Email</h2>
                <p>Your verification code is:</p>
                <div class="otp-box">
                    <div class="otp-code">$otpCode</div>
                </div>
                <p>This code will expire in 10 minutes.</p>
                <p>If you didn't request this code, please ignore this email.</p>
            </div>
            <div class="footer">
                <p>&copy; 2026 InventIF. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Fungsi untuk verify OTP dari nomor HP
  Future<Map<String, dynamic>> verifyPhoneOTP(String otpCode) async {
    try {
      if (_verificationId == null) {
        return {
          'success': false,
          'message': 'Verification ID not found. Please try again.',
        };
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      // Test credential dengan sign in temporary (untuk memverifikasi OTP valid)
      await _firebaseAuth.signInWithCredential(credential);
      
      // Logout dulu, baru buat user dengan email/password nanti
      await _firebaseAuth.signOut();

      return {
        'success': true,
        'phoneNumber': _tempPhoneNumber,
        'message': 'Phone verified successfully!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getOTPErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk verify OTP dari email
  Future<Map<String, dynamic>> verifyEmailOTP(String otpCode) async {
    try {
      if (_tempEmail == null) {
        return {
          'success': false,
          'message': 'Email not found. Please try again.',
        };
      }

      // Ambil OTP dari Firestore
      DocumentSnapshot docSnapshot =
          await _firestore.collection('otp_temp').doc(_tempEmail).get();

      if (!docSnapshot.exists) {
        return {
          'success': false,
          'message': 'OTP tidak ditemukan. Silahkan minta ulang.',
        };
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // Check expiry
      DateTime expiresAt = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection('otp_temp').doc(_tempEmail).delete();
        return {
          'success': false,
          'message': 'OTP sudah kadaluarsa. Silahkan minta ulang.',
        };
      }

      // Check OTP code
      if (data['code'] != otpCode) {
        // Increment attempts
        int attempts = data['attempts'] + 1;
        if (attempts >= 5) {
          await _firestore.collection('otp_temp').doc(_tempEmail).delete();
          return {
            'success': false,
            'message': 'Terlalu banyak percobaan. Silahkan minta ulang OTP.',
          };
        }
        await _firestore.collection('otp_temp').doc(_tempEmail).update({
          'attempts': attempts,
        });
        return {
          'success': false,
          'message': 'OTP salah. Silahkan coba lagi. (Percobaan: $attempts/5)',
        };
      }

      // OTP valid - hapus dari Firestore
      await _firestore.collection('otp_temp').doc(_tempEmail).delete();

      return {
        'success': true,
        'email': _tempEmail,
        'message': 'Email verified successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk create account setelah OTP verified
  Future<Map<String, dynamic>> createAccountAfterOTPVerification({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user di Firebase Auth
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Buat UserModel baru
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: 'user',
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Simpan ke Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      return {
        'success': true,
        'user': userCredential.user,
        'userData': newUser,
        'message': 'Account created successfully!',
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

  // Getter untuk verificationId
  String? getVerificationId() => _verificationId;

  // Reset temp data
  void resetTempData() {
    _verificationId = null;
    _tempPhoneNumber = null;
    _tempEmail = null;
    _resendToken = null;
  }

  // Fungsi untuk register dengan Email dan Password (tidak dipakai lagi, diganti dengan OTP flow)
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    try {
      // Validasi password match
      if (password != confirmPassword) {
        return {
          'success': false,
          'user': null,
          'userData': null,
          'message': 'Password tidak cocok!',
        };
      }

      // Validasi password strength
      if (password.length < 6) {
        return {
          'success': false,
          'user': null,
          'userData': null,
          'message': 'Password minimal 6 karakter!',
        };
      }

      // Buat user baru di Firebase Auth
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Buat user model baru
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: 'user', // Default role adalah 'user'
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Simpan user data ke Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      return {
        'success': true,
        'user': userCredential.user,
        'userData': newUser,
        'message': 'Register berhasil! Sekarang kamu bisa login.',
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

  // Fungsi untuk mapping error messages Firebase OTP
  String _getOTPErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'Kode OTP tidak valid!';
      case 'session-expired':
        return 'Sesi verification sudah expired. Silahkan minta ulang OTP.';
      case 'missing-verification-code':
        return 'Silahkan masukkan kode OTP!';
      case 'invalid-phone-number':
        return 'Format nomor telepon tidak valid!';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti!';
      default:
        return 'Terjadi kesalahan: $errorCode';
    }
  }

  // Fungsi untuk mapping error messages Firebase
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Password terlalu lemah!';
      case 'email-already-in-use':
        return 'Email ini sudah digunakan!';
      case 'invalid-email':
        return 'Format email tidak valid!';
      case 'operation-not-allowed':
        return 'Email/Password login tidak diaktifkan!';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti!';
      default:
        return 'Terjadi kesalahan: $errorCode';
    }
  }

  // Cek apakah email sudah terdaftar
  Future<bool> isEmailExists(String email) async {
    try {
      List<String> signInMethods =
          await _firebaseAuth.fetchSignInMethodsForEmail(email.trim());
      return signInMethods.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Fungsi untuk Google Sign In / Register
  Future<Map<String, dynamic>> signUpWithGoogle() async {
    try {
      // Logout dulu dari Google untuk force pilih akun
      await _googleSignIn.signOut();

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'user': null,
          'userData': null,
          'message': 'Google Sign In dibatalkan',
        };
      }

      // Get authentication details dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat credential untuk Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase dengan Google credential
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Cek apakah ini user baru atau lama
      bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Buat user model baru
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? googleUser.email,
          fullName: userCredential.user!.displayName ?? googleUser.displayName ?? 'User',
          profileImage: userCredential.user!.photoURL,
          role: 'user',
          createdAt: DateTime.now(),
          isActive: true,
        );

        // Simpan ke Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        return {
          'success': true,
          'user': userCredential.user,
          'userData': newUser,
          'isNewUser': true,
          'message': 'Google Sign Up berhasil! Silahkan lengkapi profil kamu.',
        };
      } else {
        // User sudah ada, ambil datanya dari Firestore
        UserModel? userData =
            await getUserDataFromFirestore(userCredential.user!.uid);

        return {
          'success': true,
          'user': userCredential.user,
          'userData': userData,
          'isNewUser': false,
          'message': 'Google Login berhasil!',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'user': null,
        'userData': null,
        'isNewUser': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'userData': null,
        'isNewUser': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

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

  // Fungsi untuk update profile user setelah complete
  Future<Map<String, dynamic>> updateUserProfile({
    required String uid,
    String? nickname,
    String? studentID,
    String? identifier,
    String? dateOfBirth,
    String? ktm,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (nickname != null && nickname.isNotEmpty) updateData['nickname'] = nickname;
      if (studentID != null && studentID.isNotEmpty) updateData['studentID'] = studentID;
      if (identifier != null && identifier.isNotEmpty) updateData['identifier'] = identifier;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) updateData['dateOfBirth'] = dateOfBirth;
      if (ktm != null && ktm.isNotEmpty) updateData['ktm'] = ktm;
      if (phoneNumber != null && phoneNumber.isNotEmpty) updateData['phoneNumber'] = phoneNumber;
      if (profileImage != null && profileImage.isNotEmpty) updateData['profileImage'] = profileImage;

      await _firestore.collection('users').doc(uid).update(updateData);

      return {
        'success': true,
        'message': 'Profil berhasil diupdate!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
