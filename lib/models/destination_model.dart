// lib/models/destination_model.dart

/// Model class for Destination
/// Represents a destination/location in the trip management system
class DestinationModel {
  final int? id;
  final String? token;
  final String name;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DestinationModel({
    this.id,
    this.token,
    required this.name,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  /// Check if destination is active
  bool get isActive => status == 'Active';

  /// Factory constructor to create DestinationModel from JSON
  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      name: json['name'] as String? ?? json['destination'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert DestinationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'name': name,
      'destination': name,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  DestinationModel copyWith({
    int? id,
    String? token,
    String? name,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DestinationModel(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
