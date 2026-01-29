// lib/models/trip_template_model.dart

/// Model class for a Trip within a Template
/// Represents a trip configuration that's part of a template
class TemplateTripsModel {
  final int? id;
  final int? templateId;
  final String vehicleType;
  final String route;
  final String origin;
  final String destination;
  final String? vehicle;
  final String? driver;
  final String departureTime;
  final String status;

  TemplateTripsModel({
    this.id,
    this.templateId,
    required this.vehicleType,
    required this.route,
    required this.origin,
    required this.destination,
    this.vehicle,
    this.driver,
    required this.departureTime,
    this.status = 'Active',
  });

  /// Get trip display name
  String get displayName => '$route - $departureTime';

  /// Check if trip is active
  bool get isActive => status == 'Active';

  /// Factory constructor to create TemplateTripsModel from JSON
  factory TemplateTripsModel.fromJson(Map<String, dynamic> json) {
    return TemplateTripsModel(
      id: json['id'] as int?,
      templateId: json['template'] as int? ?? json['template_id'] as int?,
      vehicleType: json['vehicle_type'] as String? ?? '',
      route: json['route'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      vehicle: json['vehicle'] as String?,
      driver: json['driver'] as String?,
      departureTime: json['departure_time'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
    );
  }

  /// Convert TemplateTripsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      'vehicle_type': vehicleType,
      'route': route,
      'origin': origin,
      'destination': destination,
      if (vehicle != null) 'vehicle': vehicle,
      if (driver != null) 'driver': driver,
      'departure_time': departureTime,
      'status': status,
    };
  }

  /// Create a copy with updated fields
  TemplateTripsModel copyWith({
    int? id,
    int? templateId,
    String? vehicleType,
    String? route,
    String? origin,
    String? destination,
    String? vehicle,
    String? driver,
    String? departureTime,
    String? status,
  }) {
    return TemplateTripsModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      vehicleType: vehicleType ?? this.vehicleType,
      route: route ?? this.route,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      vehicle: vehicle ?? this.vehicle,
      driver: driver ?? this.driver,
      departureTime: departureTime ?? this.departureTime,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'TemplateTripsModel(id: $id, route: $route, time: $departureTime)';
  }
}

/// Model class for Trip Template
/// Represents a reusable trip template with scheduled days
class TripTemplateModel {
  final int? id;
  final String name;
  final List<String> days;
  final String status;
  final List<TemplateTripsModel> trips;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripTemplateModel({
    this.id,
    required this.name,
    required this.days,
    this.status = 'Active',
    this.trips = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Check if template is active
  bool get isActive => status == 'Active';

  /// Get days as a comma-separated string
  String get daysString => days.join(', ');

  /// Get days as abbreviated string (Mon, Tue, etc.)
  String get daysAbbreviated {
    final abbreviations = days.map((day) {
      switch (day.toLowerCase()) {
        case 'monday':
          return 'Mon';
        case 'tuesday':
          return 'Tue';
        case 'wednesday':
          return 'Wed';
        case 'thursday':
          return 'Thu';
        case 'friday':
          return 'Fri';
        case 'saturday':
          return 'Sat';
        case 'sunday':
          return 'Sun';
        default:
          return day.substring(0, 3);
      }
    }).toList();
    return abbreviations.join(', ');
  }

  /// Get number of trips in template
  int get tripCount => trips.length;

  /// Check if template runs on a specific day
  bool runsOnDay(String day) {
    return days.any((d) => d.toLowerCase() == day.toLowerCase());
  }

  /// Check if template runs on a specific date
  bool runsOnDate(DateTime date) {
    final dayName = _getDayName(date.weekday);
    return runsOnDay(dayName);
  }

  /// Get day name from weekday number (1 = Monday, 7 = Sunday)
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// Factory constructor to create TripTemplateModel from JSON
  factory TripTemplateModel.fromJson(Map<String, dynamic> json) {
    // Parse days from comma-separated string or list
    List<String> daysList = [];
    final daysData = json['days'];
    if (daysData is String) {
      daysList = daysData.split(',').map((e) => e.trim()).toList();
    } else if (daysData is List) {
      daysList = daysData.map((e) => e.toString()).toList();
    }

    // Parse trips
    final tripsData = json['trips'] ?? [];
    final tripsList = (tripsData as List?)
            ?.map((e) => TemplateTripsModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return TripTemplateModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      days: daysList,
      status: json['status'] as String? ?? 'Active',
      trips: tripsList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convert TripTemplateModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'days': days,
      'status': status,
      'trips': trips.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  TripTemplateModel copyWith({
    int? id,
    String? name,
    List<String>? days,
    String? status,
    List<TemplateTripsModel>? trips,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      days: days ?? this.days,
      status: status ?? this.status,
      trips: trips ?? this.trips,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TripTemplateModel(id: $id, name: $name, days: $daysAbbreviated, trips: ${trips.length})';
  }
}

/// Model class for Dropdown Options
/// Represents all dropdown options for trip management
class DropdownOptionsModel {
  final List<OwnerModel> owners;
  final List<VehicleModel> vehicles;
  final List<DriverModel> drivers;
  final List<RouteModel> routes;
  final List<DestinationModel> destinations;
  final List<TripTemplateModel> templates;
  final List<String> vehicleTypes;
  final List<String> tripTypes;

  DropdownOptionsModel({
    this.owners = const [],
    this.vehicles = const [],
    this.drivers = const [],
    this.routes = const [],
    this.destinations = const [],
    this.templates = const [],
    this.vehicleTypes = const [],
    this.tripTypes = const [],
  });

  /// Factory constructor to create DropdownOptionsModel from JSON
  factory DropdownOptionsModel.fromJson(Map<String, dynamic> json) {
    return DropdownOptionsModel(
      owners: (json['owners'] as List?)
              ?.map((e) => OwnerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vehicles: (json['vehicles'] as List?)
              ?.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      drivers: (json['drivers'] as List?)
              ?.map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      routes: (json['routes'] as List?)
              ?.map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      destinations: (json['destinations'] as List?)
              ?.map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      templates: (json['templates'] as List?)
              ?.map((e) => TripTemplateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vehicleTypes: (json['vehicle_types'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tripTypes: (json['trip_types'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'DropdownOptionsModel(owners: ${owners.length}, vehicles: ${vehicles.length}, drivers: ${drivers.length}, routes: ${routes.length})';
  }
}

// Import required models
import 'owner_model.dart';
import 'vehicle_model.dart';
import 'driver_model.dart';
import 'route_model.dart';
import 'destination_model.dart';
