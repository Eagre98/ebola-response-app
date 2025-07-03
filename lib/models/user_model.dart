import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  normalUser,
  medicalTeam,
  pendingApproval // New role for users awaiting approval
}

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy; // UID of admin who approved
  final bool isApproved;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.isApproved = false,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'isApproved': isApproved,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => UserRole.normalUser,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: map['approvedBy'],
      isApproved: map['isApproved'] ?? false,
    );
  }

  // Get full name
  String get fullName => '$firstName $lastName';

  // Check if user can access admin features
  bool get isAdmin => role == UserRole.admin && isApproved;

  // Check if user can access medical team features
  bool get isMedicalTeam =>
      (role == UserRole.medicalTeam || role == UserRole.admin) && isApproved;

  // Check if user needs approval
  bool get needsApproval => role == UserRole.pendingApproval || !isApproved;

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    bool? isApproved,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
