// lib/services/trip_management_api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/owner_model.dart';
import '../models/vehicle_model.dart';
import '../models/driver_model.dart';
import '../models/route_model.dart';
import '../models/destination_model.dart';
import '../models/expense_template_model.dart';
import '../models/trip_template_model.dart';

/// Trip Management API Service
/// Handles all API calls related to trip management:
/// - Owners, Vehicles, Drivers, Routes, Destinations
/// - Expense Templates, Trip Templates
/// - Bulk Trip Creation
class TripManagementApiService {
  static final TripManagementApiService _instance =
      TripManagementApiService._internal();
  factory TripManagementApiService() => _instance;
  TripManagementApiService._internal();

  String get baseUrl => AppConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final uri = Uri.parse(url);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: _headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: _headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: _headers)
              .timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('API Request: $method $url');
      debugPrint('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return responseData is Map<String, dynamic>
            ? responseData
            : {'data': responseData};
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Request failed');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // OWNER MANAGEMENT
  // ============================================================================

  /// Get all owners
  Future<List<OwnerModel>> getOwners() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/owners',
    );

    final List<dynamic> ownersData = response['data'] ?? [];
    return ownersData.map((json) => OwnerModel.fromJson(json)).toList();
  }

  /// Get single owner by ID
  Future<OwnerModel> getOwner(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/owners/$id',
    );

    return OwnerModel.fromJson(response['data']);
  }

  /// Create new owner
  Future<OwnerModel> createOwner(OwnerModel owner) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/owners',
      data: owner.toJson(),
    );

    return OwnerModel.fromJson(response['data']);
  }

  /// Update owner
  Future<OwnerModel> updateOwner(int id, OwnerModel owner) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/owners/$id',
      data: owner.toJson(),
    );

    return OwnerModel.fromJson(response['data']);
  }

  /// Delete owner
  Future<void> deleteOwner(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/owners/$id',
    );
  }

  // ============================================================================
  // VEHICLE MANAGEMENT
  // ============================================================================

  /// Get all vehicles
  Future<List<VehicleModel>> getVehicles() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/vehicles',
    );

    final List<dynamic> vehiclesData = response['data'] ?? [];
    return vehiclesData.map((json) => VehicleModel.fromJson(json)).toList();
  }

  /// Get single vehicle by ID
  Future<VehicleModel> getVehicle(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/vehicles/$id',
    );

    return VehicleModel.fromJson(response['data']);
  }

  /// Create new vehicle
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/vehicles',
      data: vehicle.toJson(),
    );

    return VehicleModel.fromJson(response['data']);
  }

  /// Update vehicle
  Future<VehicleModel> updateVehicle(int id, VehicleModel vehicle) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/vehicles/$id',
      data: vehicle.toJson(),
    );

    return VehicleModel.fromJson(response['data']);
  }

  /// Delete vehicle
  Future<void> deleteVehicle(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/vehicles/$id',
    );
  }

  // ============================================================================
  // DRIVER MANAGEMENT
  // ============================================================================

  /// Get all drivers
  Future<List<DriverModel>> getDrivers() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/drivers',
    );

    final List<dynamic> driversData = response['data'] ?? [];
    return driversData.map((json) => DriverModel.fromJson(json)).toList();
  }

  /// Get single driver by ID
  Future<DriverModel> getDriver(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/drivers/$id',
    );

    return DriverModel.fromJson(response['data']);
  }

  /// Create new driver
  Future<DriverModel> createDriver(DriverModel driver) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/drivers',
      data: driver.toJson(),
    );

    return DriverModel.fromJson(response['data']);
  }

  /// Update driver
  Future<DriverModel> updateDriver(int id, DriverModel driver) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/drivers/$id',
      data: driver.toJson(),
    );

    return DriverModel.fromJson(response['data']);
  }

  /// Delete driver
  Future<void> deleteDriver(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/drivers/$id',
    );
  }

  // ============================================================================
  // ROUTE MANAGEMENT
  // ============================================================================

  /// Get all routes
  Future<List<RouteModel>> getRoutes() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/routes',
    );

    final List<dynamic> routesData = response['data'] ?? [];
    return routesData.map((json) => RouteModel.fromJson(json)).toList();
  }

  /// Get single route by ID
  Future<RouteModel> getRoute(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/routes/$id',
    );

    return RouteModel.fromJson(response['data']);
  }

  /// Create new route
  Future<RouteModel> createRoute(RouteModel route) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/routes',
      data: {
        'route': route.name,
        'direction': route.direction,
        'fare_id': route.fareId,
      },
    );

    return RouteModel.fromJson(response['data']);
  }

  /// Update route
  Future<RouteModel> updateRoute(int id, RouteModel route) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/routes/$id',
      data: {
        'route': route.name,
        'direction': route.direction,
        'fare_id': route.fareId,
      },
    );

    return RouteModel.fromJson(response['data']);
  }

  /// Delete route
  Future<void> deleteRoute(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/routes/$id',
    );
  }

  /// Add subroute to route
  Future<SubrouteModel> addSubroute(SubrouteModel subroute) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/routes/subroutes',
      data: subroute.toJson(),
    );

    return SubrouteModel.fromJson(response['data']);
  }

  /// Get fare for route
  Future<double> getRouteFare(
      String routeName, String source, String destination) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/routes/$routeName/fare/$source/$destination',
    );

    return (response['data']['fare'] as num).toDouble();
  }

  // ============================================================================
  // DESTINATION MANAGEMENT
  // ============================================================================

  /// Get all destinations
  Future<List<DestinationModel>> getDestinations() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/destinations',
    );

    final List<dynamic> destinationsData = response['data'] ?? [];
    return destinationsData
        .map((json) => DestinationModel.fromJson(json))
        .toList();
  }

  /// Get single destination by ID
  Future<DestinationModel> getDestination(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/destinations/$id',
    );

    return DestinationModel.fromJson(response['data']);
  }

  /// Create new destination(s) - supports comma-separated bulk creation
  Future<List<DestinationModel>> createDestinations(String destinations) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/destinations',
      data: {'destination': destinations},
    );

    final List<dynamic> destinationsData = response['data'];
    return destinationsData
        .map((json) => DestinationModel.fromJson(json))
        .toList();
  }

  /// Update destination
  Future<DestinationModel> updateDestination(
      int id, DestinationModel destination) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/destinations/$id',
      data: {'name': destination.name},
    );

    return DestinationModel.fromJson(response['data']);
  }

  /// Delete destination
  Future<void> deleteDestination(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/destinations/$id',
    );
  }

  // ============================================================================
  // EXPENSE MANAGEMENT
  // ============================================================================

  /// Get all expense templates
  Future<List<ExpenseTemplateModel>> getExpenseTemplates() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/expenses',
    );

    final List<dynamic> expensesData = response['data'] ?? [];
    return expensesData
        .map((json) => ExpenseTemplateModel.fromJson(json))
        .toList();
  }

  /// Get single expense template by ID
  Future<ExpenseTemplateModel> getExpenseTemplate(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/expenses/$id',
    );

    return ExpenseTemplateModel.fromJson(response['data']);
  }

  /// Get default expenses for vehicle type
  Future<List<ExpenseTemplateModel>> getDefaultExpenses(
      {String? vehicleType}) async {
    final queryParams =
        vehicleType != null ? '?vehicle_type=$vehicleType' : '';
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/expenses/defaults$queryParams',
    );

    final List<dynamic> expensesData = response['data'] ?? [];
    return expensesData
        .map((json) => ExpenseTemplateModel.fromJson(json))
        .toList();
  }

  /// Create new expense template
  Future<List<ExpenseTemplateModel>> createExpenseTemplate(
      ExpenseTemplateModel expense,
      {List<String>? vehicleTypes}) async {
    final data = {
      'expense_name': expense.name,
      'amount': expense.amount,
      'route': expense.route,
      'vehicle_type': vehicleTypes ?? (expense.vehicleType != null ? [expense.vehicleType!] : []),
      'status': expense.status,
    };

    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/expenses',
      data: data,
    );

    final List<dynamic> expensesData = response['data'];
    return expensesData
        .map((json) => ExpenseTemplateModel.fromJson(json))
        .toList();
  }

  /// Update expense template
  Future<ExpenseTemplateModel> updateExpenseTemplate(
      int id, ExpenseTemplateModel expense) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/expenses/$id',
      data: expense.toJson(),
    );

    return ExpenseTemplateModel.fromJson(response['data']);
  }

  /// Delete expense template
  Future<void> deleteExpenseTemplate(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/expenses/$id',
    );
  }

  /// Record trip expenses
  Future<void> recordTripExpenses(
    String tripToken,
    String vehicle,
    List<Map<String, dynamic>> expenses,
  ) async {
    await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/expenses/trip-expenses',
      data: {
        'trip_token': tripToken,
        'vehicle': vehicle,
        'expenses': expenses,
      },
    );
  }

  // ============================================================================
  // TEMPLATE MANAGEMENT
  // ============================================================================

  /// Get all trip templates
  Future<List<TripTemplateModel>> getTemplates() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/templates',
    );

    final List<dynamic> templatesData = response['data'] ?? [];
    return templatesData
        .map((json) => TripTemplateModel.fromJson(json))
        .toList();
  }

  /// Get single template by ID
  Future<TripTemplateModel> getTemplate(int id) async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/templates/$id',
    );

    return TripTemplateModel.fromJson(response['data']);
  }

  /// Create new template
  Future<TripTemplateModel> createTemplate(TripTemplateModel template) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/templates',
      data: {
        'name': template.name,
        'days': template.days,
        'status': template.status,
      },
    );

    return TripTemplateModel.fromJson(response['data']);
  }

  /// Update template
  Future<TripTemplateModel> updateTemplate(
      int id, TripTemplateModel template) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/templates/$id',
      data: {
        'name': template.name,
        'days': template.days,
        'status': template.status,
      },
    );

    return TripTemplateModel.fromJson(response['data']);
  }

  /// Delete template
  Future<void> deleteTemplate(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/templates/$id',
    );
  }

  /// Add trip to template
  Future<TemplateTripsModel> addTripToTemplate(
      TemplateTripsModel trip) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/templates/trips',
      data: trip.toJson(),
    );

    return TemplateTripsModel.fromJson(response['data']);
  }

  // ============================================================================
  // TRIP CREATION
  // ============================================================================

  /// Create single trip
  Future<Map<String, dynamic>> createSingleTrip(
      Map<String, dynamic> tripData) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/trips-crud/single',
      data: tripData,
    );

    return response;
  }

  /// Create bulk trips from template
  Future<Map<String, dynamic>> createBulkTrips({
    required int templateId,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _makeRequest(
      'POST',
      '$baseUrl/api/trip-management/trips-crud/bulk',
      data: {
        'template_id': templateId,
        'from_date': fromDate,
        'to_date': toDate,
      },
    );

    return response;
  }

  /// Update trip
  Future<Map<String, dynamic>> updateTrip(
      int id, Map<String, dynamic> tripData) async {
    final response = await _makeRequest(
      'PUT',
      '$baseUrl/api/trip-management/trips-crud/$id',
      data: tripData,
    );

    return response;
  }

  /// Delete trip
  Future<void> deleteTrip(int id) async {
    await _makeRequest(
      'DELETE',
      '$baseUrl/api/trip-management/trips-crud/$id',
    );
  }

  /// Get dropdown options for trip creation
  Future<DropdownOptionsModel> getDropdownOptions() async {
    final response = await _makeRequest(
      'GET',
      '$baseUrl/api/trip-management/trips-crud/dropdown-options',
    );

    return DropdownOptionsModel.fromJson(response['data']);
  }
}
