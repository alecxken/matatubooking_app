// lib/models/driver_model.dart

/// Model class for Driver
/// Represents a driver in the trip management system
class DriverModel {
  final int? id;
  final String? token;
  final String firstName;
  final String otherName;
  final String phone;
  final String? idNo;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverModel({
    this.id,
    this.token,
    required this.firstName,
    required this.otherName,
    required this.phone,
    this.idNo,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  /// Full name of the driver
  String get name => '$firstName $otherName';

  /// Check if driver is active
  bool get isActive => status == 'Active';

  /// Factory constructor to create DriverModel from JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      firstName: json['first_name'] as String? ?? json['name']?.toString().split(' ').first ?? '',
      otherName: json['other_name'] as String? ?? json['name']?.toString().split(' ').skip(1).join(' ') ?? '',
      phone: json['phone'] as String? ?? '',
      idNo: json['id_no'] as String?,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert DriverModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'first_name': firstName,
      'other_name': otherName,
      'phone': phone,
      if (idNo != null) 'id_no': idNo,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  DriverModel copyWith({
    int? id,
    String? token,
    String? firstName,
    String? otherName,
    String? phone,
    String? idNo,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      token: token ?? this.token,
      firstName: firstName ?? this.firstName,
      otherName: otherName ?? this.otherName,
      phone: phone ?? this.phone,
      idNo: idNo ?? this.idNo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DriverModel(id: $id, name: $name, phone: $phone, status: $status)';
  }
}
