// lib/models/vehicle_model.dart

import 'owner_model.dart';

/// Model class for Vehicle
/// Represents a vehicle in the fleet management system
class VehicleModel {
  final int? id;
  final String? token;
  final String regNo;
  final String vehicleType;
  final String vehicleOwner;
  final int seats;
  final String status;
  final OwnerModel? owner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    this.id,
    this.token,
    required this.regNo,
    required this.vehicleType,
    required this.vehicleOwner,
    required this.seats,
    this.status = 'Active',
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if vehicle is active
  bool get isActive => status == 'Active';

  /// Get vehicle display name (reg no + type)
  String get displayName => '$regNo ($vehicleType)';

  /// Factory constructor to create VehicleModel from JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      regNo: json['reg_no'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehicleOwner: json['vehicle_owner'] as String? ?? '',
      seats: json['seats'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
      owner: json['owner'] != null
          ? OwnerModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert VehicleModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'reg_no': regNo,
      'vehicle_type': vehicleType,
      'vehicle_owner': vehicleOwner,
      'seats': seats,
      'status': status,
      if (owner != null) 'owner': owner!.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  VehicleModel copyWith({
    int? id,
    String? token,
    String? regNo,
    String? vehicleType,
    String? vehicleOwner,
    int? seats,
    String? status,
    OwnerModel? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      token: token ?? this.token,
      regNo: regNo ?? this.regNo,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleOwner: vehicleOwner ?? this.vehicleOwner,
      seats: seats ?? this.seats,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'VehicleModel(id: $id, regNo: $regNo, type: $vehicleType, seats: $seats, status: $status)';
  }
}
