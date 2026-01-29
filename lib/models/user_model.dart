import 'dart:convert';
import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final List<String> roles;
  final List<String> permissions;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.roles,
    required this.permissions,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      firstName: _extractFirstName(map['name'] ?? ''),
      lastName: _extractLastName(map['name'] ?? ''),
      email: map['email'] ?? '',
      phone: map['phone'],
      roles: _parseStringList(map['roles']),
      permissions: _parseStringList(map['permissions']),
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateTime.tryParse(map['email_verified_at'])
          : null,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to extract first name from full name
  static String _extractFirstName(String fullName) {
    if (fullName.isEmpty) return '';
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  // Helper method to extract last name from full name
  static String _extractLastName(String fullName) {
    if (fullName.isEmpty) return '';
    final parts = fullName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  factory UserModel.fromJson(String jsonString) {
    return UserModel.fromMap(json.decode(jsonString));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'roles': roles,
      'permissions': permissions,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) {
        if (item is Map && item.containsKey('name')) {
          return item['name'].toString();
        }
        return item.toString();
      }).toList();
    }
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return [data];
      }
    }
    return [];
  }

  String get fullName => '$firstName $lastName';

  String get displayName {
    final name = fullName.trim();
    return name.isEmpty ? email : name;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isEmpty ? email[0].toUpperCase() : '$first$last';
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasAnyRole(List<String> roleList) {
    return roles.any((userRole) => roleList.contains(userRole));
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissionList) {
    return permissions.any((userPerm) => permissionList.contains(userPerm));
  }

  bool get isAdmin {
    return hasAnyRole(['admin', 'super-admin']);
  }

  bool get isManager {
    return hasAnyRole(['admin', 'super-admin', 'manager']);
  }

  bool get isDriver {
    return hasRole('driver');
  }

  bool get isOperator {
    return hasAnyRole(['operator', 'booking-agent']);
  }

  String get primaryRole {
    if (roles.isEmpty) return 'User';

    const rolePriority = [
      'super-admin',
      'admin',
      'manager',
      'operator',
      'booking-agent',
      'driver',
      'conductor',
      'user',
    ];

    for (String role in rolePriority) {
      if (roles.contains(role)) {
        return role.replaceAll('-', ' ').toUpperCase();
      }
    }

    return roles.first.replaceAll('-', ' ').toUpperCase();
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    List<String>? roles,
    List<String>? permissions,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $fullName, email: $email, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }

  // UI Helper methods
  Color get roleColor {
    if (isAdmin) return const Color(0xFFE53E3E);
    if (isManager) return const Color(0xFF3182CE);
    if (isDriver) return const Color(0xFF38A169);
    if (isOperator) return const Color(0xFFD69E2E);
    return const Color(0xFF718096);
  }

  IconData get roleIcon {
    if (isAdmin) return Icons.admin_panel_settings;
    if (isManager) return Icons.manage_accounts;
    if (isDriver) return Icons.directions_bus;
    if (isOperator) return Icons.support_agent;
    return Icons.person;
  }

  bool get canManageUsers => hasAnyRole(['admin', 'super-admin', 'manager']);
  bool get canManageTrips =>
      hasAnyRole(['admin', 'super-admin', 'manager', 'operator']);
  bool get canViewReports => hasAnyRole(['admin', 'super-admin', 'manager']);
  bool get canManageFleet => hasAnyRole(['admin', 'super-admin', 'manager']);
  bool get canBookSeats => !hasRole('driver') || hasPermission('book-seats');
  bool get canViewFinancials => hasAnyRole(['admin', 'super-admin', 'manager']);
}
