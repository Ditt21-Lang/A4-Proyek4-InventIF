import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String identifier;
  final String email;
  final String fullName;
  final String? nickname;
  final String? dateOfBirth;
  final String? kelas;
  final String? ktm;
  final String? phoneNumber;
  final String? profileImage;
  final String role; // 'user', 'teknisi', 'coordinator'
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.identifier,
    required this.email,
    required this.fullName,
    this.nickname,
    this.dateOfBirth,
    this.kelas,
    required this.ktm,
    this.phoneNumber,
    this.profileImage,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert UserModel to JSON (untuk menyimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'identifier': identifier,
      'email': email,
      'fullName': fullName,
      'nickname': nickname ?? '',
      'dateOfBirth': dateOfBirth ?? '',
      'kelas': kelas ?? '',
      'ktm': ktm ?? '',
      'phoneNumber': phoneNumber ?? '',
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  // Convert JSON dari Firestore ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      identifier: map['identifier'] ?? '',
      email: map['Email'] ?? map['email'] ?? '',
      fullName: map['Fullname'] ?? map['fullName'] ?? 'User',
      nickname: map['nickname'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      kelas: map['kelas'] ?? '',
      ktm: map['ktm'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'],
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with - untuk membuat copy dengan beberapa field yang diubah
  UserModel copyWith({
    String? uid,
    String? identifier,
    String? email,
    String? fullName,
    String? nickname,
    String? dateOfBirth,
    String? kelas,
    String? ktm,
    String? phoneNumber,
    String? profileImage,
    String? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      identifier: identifier ?? this.identifier,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      kelas: kelas ?? this.kelas,
      ktm: ktm ?? this.ktm,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, identifier: $identifier, email: $email, fullName: $fullName, nickname: $nickname, dateOfBirth: $dateOfBirth, kelas: $kelas, ktm: $ktm, phoneNumber: $phoneNumber, profileImage: $profileImage, role: $role, createdAt: $createdAt, isActive: $isActive)';
  }
}
