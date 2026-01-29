// lib/models/route_model.dart

/// Model class for Route Subroute (Route Detail)
/// Represents a specific source-destination combination within a route
class SubrouteModel {
  final int? id;
  final String? refToken;
  final int? routeId;
  final String source;
  final String destination;
  final double fare;
  final String status;

  SubrouteModel({
    this.id,
    this.refToken,
    this.routeId,
    required this.source,
    required this.destination,
    required this.fare,
    this.status = 'Active',
  });

  /// Get subroute display name
  String get displayName => '$source → $destination';

  /// Check if subroute is active
  bool get isActive => status == 'Active';

  /// Factory constructor to create SubrouteModel from JSON
  factory SubrouteModel.fromJson(Map<String, dynamic> json) {
    return SubrouteModel(
      id: json['id'] as int?,
      refToken: json['ref_token'] as String?,
      routeId: json['route_id'] as int?,
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Active',
    );
  }

  /// Convert SubrouteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (refToken != null) 'ref_token': refToken,
      if (routeId != null) 'route_id': routeId,
      'source': source,
      'destination': destination,
      'fare': fare,
      'status': status,
    };
  }

  /// Create a copy with updated fields
  SubrouteModel copyWith({
    int? id,
    String? refToken,
    int? routeId,
    String? source,
    String? destination,
    double? fare,
    String? status,
  }) {
    return SubrouteModel(
      id: id ?? this.id,
      refToken: refToken ?? this.refToken,
      routeId: routeId ?? this.routeId,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      fare: fare ?? this.fare,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'SubrouteModel(id: $id, $source → $destination, fare: $fare)';
  }
}

/// Model class for Route
/// Represents a route in the trip management system
class RouteModel {
  final int? id;
  final String? token;
  final String name;
  final String? direction;
  final double? fareId;
  final String status;
  final List<SubrouteModel> subroutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RouteModel({
    this.id,
    this.token,
    required this.name,
    this.direction,
    this.fareId,
    this.status = 'Active',
    this.subroutes = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Check if route is active
  bool get isActive => status == 'Active';

  /// Get route display name (name + direction if available)
  String get displayName => direction != null ? '$name ($direction)' : name;

  /// Get number of subroutes
  int get subrouteCount => subroutes.length;

  /// Factory constructor to create RouteModel from JSON
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'name' and 'route' fields for name
    final routeName = json['name'] as String? ?? json['route'] as String? ?? '';

    // Handle subroutes from 'routedeta' or 'subroutes' field
    final subroutesData = json['routedeta'] ?? json['subroutes'] ?? [];
    final subroutesList = (subroutesData as List?)
            ?.map((e) => SubrouteModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return RouteModel(
      id: json['id'] as int?,
      token: json['token'] as String?,
      name: routeName,
      direction: json['direction'] as String?,
      fareId: (json['fare_id'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'Active',
      subroutes: subroutesList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert RouteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      'route': name,
      'name': name,
      if (direction != null) 'direction': direction,
      if (fareId != null) 'fare_id': fareId,
      'status': status,
      'routedeta': subroutes.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  RouteModel copyWith({
    int? id,
    String? token,
    String? name,
    String? direction,
    double? fareId,
    String? status,
    List<SubrouteModel>? subroutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      direction: direction ?? this.direction,
      fareId: fareId ?? this.fareId,
      status: status ?? this.status,
      subroutes: subroutes ?? this.subroutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RouteModel(id: $id, name: $name, direction: $direction, subroutes: ${subroutes.length})';
  }
}
