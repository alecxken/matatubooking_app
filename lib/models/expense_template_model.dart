// lib/models/expense_template_model.dart

/// Model class for Expense Template
/// Represents a default expense template for trip expenses
class ExpenseTemplateModel {
  final int? id;
  final String? token;
  final String name;
  final double amount;
  final String? description;
  final String? vehicleType;
  final String? route;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseTemplateModel({
    this.id,
    this.token,
    required this.name,
    required this.amount,
    this.description,
    this.vehicleType,
    this.route,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  /// Check if expense template is active
  bool get isActive => status == 'Active';

  /// Get display name with vehicle type and route
  String get displayName {
    final parts = <String>[name];
    if (vehicleType != null && vehicleType!.isNotEmpty) {
      parts.add('($vehicleType)');
    }
    if (route != null && route!.isNotEmpty) {
      parts.add('- $route');
    }
    return parts.join(' ');
  }

  /// Factory constructor to create ExpenseTemplateModel from JSON
  factory ExpenseTemplateModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'desc' and 'description' fields
    final desc = json['desc'] as String? ??
                 json['description'] as String? ??
                 json['vehicle_type'] as String?;

    return ExpenseTemplateModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      name: json['name'] as String? ?? json['expense_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: desc,
      vehicleType: json['desc'] as String? ?? json['vehicle_type'] as String?,
      route: json['route'] as String?,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert ExpenseTemplateModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'expense_name': name,
      'name': name,
      'amount': amount,
      if (description != null) 'description': description,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (vehicleType != null) 'desc': vehicleType,
      if (route != null) 'route': route,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ExpenseTemplateModel copyWith({
    int? id,
    String? token,
    String? name,
    double? amount,
    String? description,
    String? vehicleType,
    String? route,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseTemplateModel(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      vehicleType: vehicleType ?? this.vehicleType,
      route: route ?? this.route,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseTemplateModel(id: $id, name: $name, amount: $amount, vehicleType: $vehicleType)';
  }
}
