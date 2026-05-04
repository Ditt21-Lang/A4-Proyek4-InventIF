import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String role; // 'user', 'teknisi', 'TU', etc.
  final String? profileImage;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert UserModel to JSON (untuk menyimpan ke Firestore)
  // Map field names sesuai Firestore structure
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'Email': email, 
      'Fullname': fullName, 
      'phoneNumber': phoneNumber,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  // Convert JSON dari Firestore ke UserModel
  // Read field names sesuai Firestore structure
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['Email'] ?? map['email'] ?? '',
      fullName: map['Fullname'] ?? map['fullName'], 
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? 'user',
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with - untuk membuat copy dengan beberapa field yang diubah
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? profileImage,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, role: $role, isActive: $isActive)';
  }
}
