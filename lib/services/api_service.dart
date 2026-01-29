import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => AppConstants.baseUrl;
  String get authApiPath => AppConstants.authApiPath;
  String? _token;

  // HTTP client that ignores SSL certificates
  late http.Client _httpClient;

  void _initializeHttpClient() {
    _httpClient = http.Client();

    // Override HTTP client to ignore SSL certificates
    HttpOverrides.global = MyHttpOverrides();
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

  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
  }) async {
    if (!await _isConnected()) {
      throw Exception('No internet connection');
    }

    _initializeHttpClient();

    try {
      final uri = Uri.parse(url);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await _httpClient
              .post(
                uri,
                headers: _headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _httpClient
              .put(
                uri,
                headers: _headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _httpClient
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
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden - Insufficient permissions');
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Validation failed');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      throw Exception('Network connection failed');
    }
  }

  // AUTHENTICATION ENDPOINTS
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = '$baseUrl$authApiPath/login';
    final data = {'username': username, 'password': password};

    final response = await _makeRequest(
      'POST',
      url,
      data: data,
      requiresAuth: false,
    );

    if (response['token'] != null) {
      _token = response['token'];
    }

    return response;
  }

  Future<Map<String, dynamic>> logout() async {
    final url = '$baseUrl$authApiPath/logout';
    return await _makeRequest('POST', url);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final url = '$baseUrl$authApiPath/user-profile';
    return await _makeRequest('GET', url);
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final url = '$baseUrl$authApiPath/update-user-profile';
    return await _makeRequest('POST', url, data: profileData);
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final url = '$baseUrl$authApiPath/change-password';
    final data = {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    };
    return await _makeRequest('POST', url, data: data);
  }

  // TRIP MANAGEMENT ENDPOINTS
  Future<Map<String, dynamic>> getTripsForDate({
    required String date,
    String? origin,
    String? destination,
  }) async {
    final url = '$baseUrl/api/mobile/trips/by-date';
    final queryParams = <String, String>{'date': date};

    if (origin != null) queryParams['origin'] = origin;
    if (destination != null) queryParams['destination'] = destination;

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    return await _makeRequest('GET', uri.toString());
  }

  Future<Map<String, dynamic>> getTripSeats(String tripToken) async {
    final url = '$baseUrl/api/mobile/trips/$tripToken/seats';
    return await _makeRequest('GET', url);
  }

  Future<Map<String, dynamic>> checkSeatAvailability(
    String tripToken,
    List<int> seats,
  ) async {
    final url = '$baseUrl/api/mobile/trips/check-seats';
    final data = {'trip_token': tripToken, 'seats': seats};
    return await _makeRequest('POST', url, data: data);
  }

  Future<Map<String, dynamic>> createBooking({
    required String tripToken,
    required List<int> seats,
    required String firstName,
    required String lastName,
    required String phone,
    String? idNo,
    required String paymentMethod,
    String? paymentRef,
  }) async {
    final url = '$baseUrl/api/mobile/trips/book';
    final data = {
      'trip_token': tripToken,
      'seats': seats,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'id_no': idNo,
      'payment_method': paymentMethod,
      'payment_ref': paymentRef,
    };

    return await _makeRequest('POST', url, data: data);
  }

  // Submit mobile booking (for multiple seats with single passenger)
  Future<Map<String, dynamic>> submitMobileBooking(
    Map<String, dynamic> bookingData,
  ) async {
    final url = '$baseUrl/api/mobile/submit-seats';
    return await _makeRequest('POST', url, data: bookingData);
  }

  // Get trip manifest
  Future<Map<String, dynamic>> getTripManifest(String tripToken) async {
    final url = '$baseUrl/api/trip-manifest/$tripToken';
    return await _makeRequest('GET', url);
  }

  // Download manifest PDF
  Future<String> getManifestPdfUrl(String tripToken) async {
    return '$baseUrl/api/trip-manifest/$tripToken/pdf';
  }

  Future<Map<String, dynamic>> updatePayment(
    String bookingReference,
    String paymentReference,
    String paymentMethod,
  ) async {
    final url = '$baseUrl/api/mobile/trips/payment/update';
    final data = {
      'booking_reference': bookingReference,
      'payment_reference': paymentReference,
      'payment_method': paymentMethod,
    };
    return await _makeRequest('POST', url, data: data);
  }

  // Get default expenses for vehicle type
  Future<Map<String, dynamic>> getDefaultExpenses(String vehicleType) async {
    final url =
        '$baseUrl/api/mobile/default-expenses?vehicle_type=$vehicleType';
    return await _makeRequest('GET', url);
  }

  // Add trip expenses (updated with trip_token)
  Future<Map<String, dynamic>> addTripExpense(
    String tripToken,
    List<Map<String, dynamic>> expenses,
  ) async {
    final url = '$baseUrl/api/mobile/trips/$tripToken/expenses';
    final data = {
      'trip_token': tripToken, // Add this field for validation
      'expenses': expenses,
    };
    return await _makeRequest('POST', url, data: data);
  }

  // Get trip expenses
  Future<Map<String, dynamic>> getTripExpenses(String tripToken) async {
    final url = '$baseUrl/api/mobile/trips/$tripToken/expenses';
    return await _makeRequest('GET', url);
  }

  // Check booking payment status
  Future<Map<String, dynamic>> getBookingStatus(
    String tripToken,
    String phone,
  ) async {
    final url = '$baseUrl/api/mobile/booking?token=$tripToken&phone=$phone';
    return await _makeRequest('GET', url);
  }
  // Get trip manifest data

  // Get manifest PDF URL

  // Parcel management methods
  Future<Map<String, dynamic>> getParcels({
    String? status,
    int? page,
    String? search,
  }) async {
    var url = '$baseUrl/api/parcels';
    final queryParams = <String, String>{};

    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (search != null) queryParams['search'] = search;

    if (queryParams.isNotEmpty) {
      url +=
          '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    }

    return await _makeRequest('GET', url);
  }

  Future<Map<String, dynamic>> addParcel(
    Map<String, dynamic> parcelData,
  ) async {
    final url = '$baseUrl/api/parcels';
    return await _makeRequest('POST', url, data: parcelData);
  }

  Future<Map<String, dynamic>> updateParcel(
    int id,
    Map<String, dynamic> parcelData,
  ) async {
    final url = '$baseUrl/api/parcels/$id';
    return await _makeRequest('PUT', url, data: parcelData);
  }

  Future<Map<String, dynamic>> updateParcelStatus(
    int id,
    String status, [
    String? notes,
  ]) async {
    final url = '$baseUrl/api/parcels/$id/status';
    final data = {'status': status};
    if (notes != null && notes.isNotEmpty) data['notes'] = notes;
    return await _makeRequest('POST', url, data: data);
  }

  Future<Map<String, dynamic>> deleteParcel(int id) async {
    final url = '$baseUrl/api/parcels/$id';
    return await _makeRequest('DELETE', url);
  }

  Future<Map<String, dynamic>> getParcelDestinations() async {
    final url = '$baseUrl/api/parcel/destination';
    return await _makeRequest('GET', url);
  }

  // Trip management methods
  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    final url = '$baseUrl/api/trips';

    try {
      return await _makeRequest('POST', url, data: tripData);
    } catch (e) {
      return {'success': false, 'message': 'Failed to create trip: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTrip(
    String tripToken,
    Map<String, dynamic> tripData,
  ) async {
    final url = '$baseUrl/api/trips/$tripToken';

    try {
      return await _makeRequest('PUT', url, data: tripData);
    } catch (e) {
      return {'success': false, 'message': 'Failed to update trip: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteTrip(String tripToken) async {
    final url = '$baseUrl/api/trips/$tripToken';

    try {
      return await _makeRequest('DELETE', url);
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete trip: $e'};
    }
  }

  Future<Map<String, dynamic>> getTripDetails(String tripToken) async {
    final url = '$baseUrl/api/trips/$tripToken';

    try {
      return await _makeRequest('GET', url);
    } catch (e) {
      return {'success': false, 'message': 'Failed to get trip details: $e'};
    }
  }

  // Get dropdown options for trip creation
  Future<Map<String, dynamic>> getTripDropdownOptions() async {
    final url = '$baseUrl/api/trips/dropdown-options';

    try {
      return await _makeRequest('GET', url);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get dropdown options: $e',
        'data': {
          'routes': [],
          'vehicles': [],
          'drivers': [],
          'destinations': [],
          'vehicle_types': [],
        },
      };
    }
  }
}

// Custom HTTP overrides to ignore SSL certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
