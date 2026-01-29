// lib/models/owner_model.dart

/// Model class for Vehicle Owner
/// Represents a vehicle owner in the trip management system
class OwnerModel {
  final int? id;
  final String? token;
  final String firstName;
  final String otherName;
  final String phone;
  final String? email;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OwnerModel({
    this.id,
    this.token,
    required this.firstName,
    required this.otherName,
    required this.phone,
    this.email,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  /// Full name of the owner
  String get fullName => '$firstName $otherName';

  /// Check if owner is active
  bool get isActive => status == 'Active';

  /// Factory constructor to create OwnerModel from JSON
  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      firstName: json['first_name'] as String? ?? '',
      otherName: json['other_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert OwnerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'first_name': firstName,
      'other_name': otherName,
      'phone': phone,
      if (email != null) 'email': email,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  OwnerModel copyWith({
    int? id,
    String? token,
    String? firstName,
    String? otherName,
    String? phone,
    String? email,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerModel(
      id: id ?? this.id,
      token: token ?? this.token,
      firstName: firstName ?? this.firstName,
      otherName: otherName ?? this.otherName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'OwnerModel(id: $id, fullName: $fullName, phone: $phone, status: $status)';
  }
}
