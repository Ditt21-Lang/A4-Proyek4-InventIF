import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Variable untuk store verification data sementara
  String? _verificationId;
  String? _tempPhoneNumber;
  String? _tempEmail;
  int? _resendToken;
  String? _verifiedSmsCode; // Simpan smsCode setelah verifikasi

  // === OTP VERIFICATION FLOW ===

  // Fungsi untuk kirim OTP ke nomor HP
  Future<Map<String, dynamic>> sendPhoneOTP(String phoneNumber) async {
    try {
      _tempPhoneNumber = phoneNumber;
      
      // Pastikan format +62
      if (phoneNumber.startsWith('08')) {
        phoneNumber = '+62${phoneNumber.substring(1)}';
        _tempPhoneNumber = phoneNumber;
      }

      // Gunakan Completer untuk menunggu callback
      final completer = Completer<Map<String, dynamic>>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Verifikasi otomatis (hanya Android)
          print('Nomor telepon terverifikasi secara otomatis');
        },
        verificationFailed: (FirebaseAuthException e) {
          // Dipanggil jika ada error (contoh: nomor tidak valid)
          print('ERROR CODE: ${e.code}');
          print('ERROR MESSAGE: ${e.message}');
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': _getPhoneSendErrorMessage(e.code),
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // OTP berhasil dikirim - simpan verificationId
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'message': 'OTP successfully sent to $phoneNumber',
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );

      return await completer.future;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    }
  }

  String _getPhoneSendErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Use format +62-xxx-xxxx-xxxx';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again tomorrow or contact admin.';
      case 'app-not-authorized':
        return 'App not authorized. Check SHA-1 in Firebase Console.';
      case 'missing-client-identifier':
        return 'SafetyNet/Play Integrity not configured.';
      default:
        return 'Failed to send OTP: $code';
    }
  }

  // Fungsi untuk mengirim OTP ke email menggunakan EmailJS
  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      // Validate that email is from Polban domain
      if (!email.toLowerCase().endsWith('@polban.ac.id')) {
        return {
          'success': false,
          'message': 'Only Polban email (@polban.ac.id) is allowed to register',
        };
      }
      
      _tempEmail = email;

      // Generate OTP
      final random = Random.secure();
      String otpCode = List.generate(6, (_) => random.nextInt(10)).join();

      // Simpan ke Firestore dulu (untuk verifikasi nanti)
      await _firestore.collection('otp_temp').doc(email).set({
        'code': otpCode,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 10)),
        ),
        'attempts': 0,
      });

      print('=== DEBUG EMAILJS START ===');
      print('Kirim email ke: $email');
      print('Kode OTP: $otpCode');

      // Kirim email via EmailJS
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': 'service_6m7dkml',   
          'template_id': 'template_o8ktbyy', 
          'user_id': 'C8NOE45fXb296PWuF',
          'template_params': {
            'to_email': email,
            'otp_code': otpCode,
          },
        }),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('=== DEBUG EMAILJS END ===');

      if (response.statusCode == 200) {
        print('Email berhasil dikirim!');
        return {
          'success': true,
          'message': 'OTP successfully sent to $email. Check your inbox!',
        };
      } else {
        // Jika EmailJS gagal, hapus OTP dari Firestore
        await _firestore.collection('otp_temp').doc(email).delete();
        print('EmailJS Error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to send email. Try again. (${response.body})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk verifikasi OTP dari nomor telepon
  Future<Map<String, dynamic>> verifyPhoneOTP(String otpCode) async {
    try {
      if (_verificationId == null) {
        return {
          'success': false,
          'message': 'Session expired. Please resend OTP.',
        };
      }

      // Buat credential untuk verifikasi kevaliditasan OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      // Masuk sementara hanya untuk validasi OTP
      await _firebaseAuth.signInWithCredential(credential);

      // Simpan smsCode sebelum sign out
      // Akan digunakan lagi di createAccountAfterOTPVerification
      _verifiedSmsCode = otpCode;

      // Keluar setelah menyimpan smsCode
      await _firebaseAuth.signOut();

      return {
        'success': true,
        'phoneNumber': _tempPhoneNumber,
        'message': 'Phone number successfully verified!',
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

  // Fungsi untuk verifikasi OTP dari email
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
          'message': 'OTP not found. Please request again.',
        };
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // Cek kadaluarsa
      DateTime expiresAt = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection('otp_temp').doc(_tempEmail).delete();
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Cek kode OTP
      if (data['code'] != otpCode) {
        // Tambah percobaan
        int attempts = data['attempts'] + 1;
        if (attempts >= 5) {
          await _firestore.collection('otp_temp').doc(_tempEmail).delete();
          return {
            'success': false,
            'message': 'Too many attempts. Please request a new OTP.',
          };
        }
        await _firestore.collection('otp_temp').doc(_tempEmail).update({
          'attempts': attempts,
        });
        return {
          'success': false,
          'message': 'Incorrect OTP. Please try again. (Attempts: $attempts/5)',
        };
      }

      // OTP valid - hapus dari Firestore
      await _firestore.collection('otp_temp').doc(_tempEmail).delete();

      return {
        'success': true,
        'email': _tempEmail,
        'message': 'Email successfully verified!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk membuat akun setelah OTP diverifikasi
  Future<Map<String, dynamic>> createAccountAfterOTPVerification({
    required String identity,   // email atau nomor telepon
    required String password,
    required String fullName,
    required bool isPhone,
  }) async {
    try {
      UserCredential userCredential;

      if (isPhone) {
        // Jalur telepon: gunakan PhoneAuthCredential, tidak perlu email/password
        if (_verificationId == null || _verifiedSmsCode == null) {
          return {
            'success': false,
            'user': null,
            'userData': null,
            'message': 'Sesi berakhir. Silakan coba daftar lagi.',
          };
        }

        PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _verifiedSmsCode!,
        );

        userCredential =
            await _firebaseAuth.signInWithCredential(phoneCredential);

      } else {
        // Jalur email: gunakan email + password seperti biasanya
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: identity.trim(),
          password: password,
        );
      }

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        identifier: '', // NIM/Identifier akan diisi saat profile completion
        email: isPhone ? '' : identity.trim(),
        fullName: fullName.trim(),
        ktm: '', // KTM akan diupload saat profile completion
        phoneNumber: isPhone ? _tempPhoneNumber : null,
        role: 'user',
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      // Reset all temp data after success
      resetTempData();

      return {
        'success': true,
        'user': userCredential.user,
        'userData': newUser,
        'message': 'Account created successfully!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'user': null,
        'userData': null,
        'message': _getErrorMessage(e.code),
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

  // Getter untuk verificationId
  String? getVerificationId() => _verificationId;

  // Reset data sementara
  void resetTempData() {
    _verificationId = null;
    _tempPhoneNumber = null;
    _tempEmail = null;
    _resendToken = null;
    _verifiedSmsCode = null;
  }

  // Function to map Firebase OTP error messages
  String _getOTPErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'Invalid OTP code!';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP.';
      case 'missing-verification-code':
        return 'Please enter OTP code!';
      case 'invalid-phone-number':
        return 'Invalid phone number format!';
      case 'too-many-requests':
        return 'Too many attempts. Try again later!';
      default:
        return 'An error occurred: $errorCode';
    }
  }

  // Function to map Firebase error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Password is too weak!';
      case 'email-already-in-use':
        return 'This email is already in use!';
      case 'invalid-email':
        return 'Invalid email format!';
      case 'operation-not-allowed':
        return 'Email/Password login is not enabled!';
      case 'too-many-requests':
        return 'Too many attempts. Try again later!';
      default:
        return 'An error occurred: $errorCode';
    }
  }

  // Check if email already exists
  // Function to check if email already exists
  Future<bool> isEmailExists(String email) async {
    try {
      // Check in Firestore users collection
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Function for Google Sign In / Register
  Future<Map<String, dynamic>> signUpWithGoogle() async {
    try {
      // Logout from Google first to force account selection
      await _googleSignIn.signOut();

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'user': null,
          'userData': null,
          'message': 'Google Sign In cancelled',
        };
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if this is a new user or existing
      bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create new user model
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          identifier: '',
          email: userCredential.user!.email ?? googleUser.email,
          fullName: userCredential.user!.displayName ?? googleUser.displayName ?? 'User',
          ktm: null,
          profileImage: userCredential.user!.photoURL,
          role: 'user',
          createdAt: DateTime.now(),
          isActive: true,
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        return {
          'success': true,
          'user': userCredential.user,
          'userData': newUser,
          'isNewUser': true,
          'message': 'Google Sign Up successful! Please complete your profile.',
        };
      } else {
        // User already exists, get data from Firestore
        UserModel? userData =
            await getUserDataFromFirestore(userCredential.user!.uid);

        return {
          'success': true,
          'user': userCredential.user,
          'userData': userData,
          'isNewUser': false,
          'message': 'Google Login successful!',
        };
      }
    } on FirebaseAuthException catch (e) {
      // TAMBAH INI — print error spesifik
      print('GOOGLE ERROR CODE: ${e.code}');
      print('GOOGLE ERROR MESSAGE: ${e.message}');
      String message = _getErrorMessage(e.code);
      return {
        'success': false,
        'user': null,
        'userData': null,
        'isNewUser': false,
        'message': 'Error: ${e.code} - ${e.message}',
      };
    } catch (e) {
      // Catch ALL errors termasuk PlatformException
      print('GOOGLE CATCH ERROR: ${e.toString()}');
      
      // Handle Android error code 10 (DEVELOPER_ERROR)
      String errorMsg = e.toString();
      if (errorMsg.contains('error code: 10') || errorMsg.contains('ApiException: 10')) {
        return {
          'success': false,
          'user': null,
          'userData': null,
          'isNewUser': false,
          'message': 'Developer Error (Code 10): SHA-1 fingerprint mismatch. Check Firebase Console.',
        };
      }
      
      return {
        'success': false,
        'user': null,
        'userData': null,
        'isNewUser': false,
        'message': e.toString(),
      };
    }
  }

  // Get user data from Firestore by UID
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

  // Function to update user profile after completion
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
        'message': 'Profile updated successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
