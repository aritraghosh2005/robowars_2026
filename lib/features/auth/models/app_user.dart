import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { viewer, participant, admin }

class AppUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final String? fcmToken;
  final String? teamId;
  final String? teamRole;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.fcmToken,
    this.teamId,
    this.teamRole,
    this.onboardingCompleted = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      uid: documentId,
      displayName: map['displayName'] ?? '',
      email: map['email'],
      phone: map['phone'],
      avatarUrl: map['avatarUrl'],
      role: _parseRole(map['role']),
      fcmToken: map['fcmToken'],
      teamId: map['teamId'],
      teamRole: map['teamRole'],
      onboardingCompleted:
          map['onboardingCompleted'] as bool? ??
          ((map['phone'] as String?)?.trim().isNotEmpty ?? false),
      createdAt: _parseDate(map['createdAt']),
      lastLoginAt: _parseDate(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role.name,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (teamId != null) 'teamId': teamId,
      if (teamRole != null) 'teamRole': teamRole,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'participant':
        return UserRole.participant;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? fcmToken,
    String? teamId,
    String? teamRole,
    bool? onboardingCompleted,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      teamId: teamId ?? this.teamId,
      teamRole: teamRole ?? this.teamRole,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
