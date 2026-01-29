import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class TripProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Trip data - updated to handle API response format
  Map<String, dynamic> _trips = {
    'to_nairobi': [],
    'from_nairobi': [],
    'others': [],
  };
  Map<String, List<SeatModel>> _tripSeats = {};
  Map<String, ManifestModel> _tripManifests = {};
  Map<String, List<ExpenseModel>> _tripExpenses = {};

  // Current selections
  List<int> _selectedSeats = [];
  String? _currentTripToken;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get trips => _trips;
  List<int> get selectedSeats => _selectedSeats;
  String? get currentTripToken => _currentTripToken;

  // Get trips by direction - updated to work with Map format
  List<Map<String, dynamic>> getTripsToNairobi() {
    return List<Map<String, dynamic>>.from(_trips['to_nairobi'] ?? []);
  }

  List<Map<String, dynamic>> getTripsFromNairobi() {
    return List<Map<String, dynamic>>.from(_trips['from_nairobi'] ?? []);
  }

  List<Map<String, dynamic>> getOtherTrips() {
    return List<Map<String, dynamic>>.from(_trips['others'] ?? []);
  }

  // Get seats for a trip
  List<SeatModel> getTripSeats(String tripToken) {
    return _tripSeats[tripToken] ?? [];
  }

  // Get manifest for a trip
  ManifestModel? getTripManifest(String tripToken) {
    return _tripManifests[tripToken];
  }

  // Get expenses for a trip
  List<ExpenseModel> getTripExpenses(String tripToken) {
    return _tripExpenses[tripToken] ?? [];
  }

  // Load trips for a specific date
  Future<void> loadTripsForDate(
    String date, {
    String? origin,
    String? destination,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getTripsForDate(
        date: date,
        origin: origin,
        destination: destination,
      );

      if (response['success'] == true) {
        final tripsData = response['trips'] as Map<String, dynamic>;

        // Store the trips data directly as received from API
        _trips = tripsData;

        // Cache the data
        await _cacheTripsData(date, response);

        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load trips');
      }
    } catch (e) {
      debugPrint('Error loading trips: $e');
      // Try to load from cache if available
      final cachedData = await _loadCachedTripsData(date);
      if (cachedData != null && cachedData['trips'] != null) {
        _trips = cachedData['trips'] as Map<String, dynamic>;
        _setLoading(false);
        notifyListeners();
      } else {
        _setError('Failed to load trips. Please check your connection.');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Set current trip for detail view
  void setCurrentTrip(String tripToken) {
    _currentTripToken = tripToken;
    notifyListeners();
  }

  // Load seats for a trip
  Future<void> loadTripSeats(String tripToken) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getTripSeats(tripToken);

      if (response['success'] == true) {
        final seatsData = response['seats']['map'] as List<dynamic>;
        final seats = seatsData
            .map((seatData) => SeatModel.fromMap(seatData))
            .toList();

        _tripSeats[tripToken] = seats;
        _currentTripToken = tripToken;

        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load seats');
      }
    } catch (e) {
      _setError('Failed to load seats. Please check your connection.');
      debugPrint('Error loading trip seats: $e');
    }
  }

  // Check seat availability
  Future<bool> checkSeatAvailability(String tripToken, List<int> seats) async {
    try {
      final response = await _apiService.checkSeatAvailability(
        tripToken,
        seats,
      );

      return response['success'] == true && response['all_available'] == true;
    } catch (e) {
      debugPrint('Error checking seat availability: $e');
      return false;
    }
  }

  // Create booking
  Future<BookingModel?> createBooking({
    required String tripToken,
    required List<int> seats,
    required String firstName,
    required String lastName,
    required String phone,
    String? idNo,
    required String paymentMethod,
    String? paymentRef,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.createBooking(
        tripToken: tripToken,
        seats: seats,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        idNo: idNo,
        paymentMethod: paymentMethod,
        paymentRef: paymentRef,
      );

      if (response['success'] == true) {
        _setLoading(false);

        // Clear selected seats after successful booking
        _selectedSeats.clear();

        // Refresh trip seats to show updated availability
        await loadTripSeats(tripToken);

        return BookingModel.fromMap(response['booking']);
      } else {
        _setError(response['message'] ?? 'Booking failed');
        return null;
      }
    } catch (e) {
      _setError('Booking failed. Please try again.');
      debugPrint('Error creating booking: $e');
      return null;
    }
  }

  // Update payment
  Future<bool> updatePayment({
    required String bookingReference,
    required String paymentMethod,
    required String paymentRef,
    required double paymentAmount,
  }) async {
    try {
      final response = await _apiService.updatePayment(
        bookingReference,
        paymentRef,
        paymentMethod,
      );

      if (response['success'] == true) {
        // Refresh current trip seats if available
        if (_currentTripToken != null) {
          await loadTripSeats(_currentTripToken!);
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error updating payment: $e');
      return false;
    }
  }

  // Add trip expense
  Future<bool> addTripExpense(
    String tripToken,
    List<Map<String, dynamic>> expenses,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.addTripExpense(tripToken, expenses);

      if (response['success'] == true) {
        // Refresh expenses
        await loadTripExpenses(tripToken);
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to add expense');
        return false;
      }
    } catch (e) {
      _setError('Failed to add expense. Please try again.');
      debugPrint('Error adding trip expense: $e');
      return false;
    }
  }

  // Load trip expenses
  Future<void> loadTripExpenses(String tripToken) async {
    try {
      final response = await _apiService.getTripExpenses(tripToken);

      if (response['success'] == true) {
        final expensesData = response['expenses'] as List<dynamic>;
        final expenses = expensesData
            .map((data) => ExpenseModel.fromMap(data))
            .toList();

        _tripExpenses[tripToken] = expenses;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading trip expenses: $e');
    }
  }

  // Load trip manifest
  Future<void> loadTripManifest(String tripToken) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getTripManifest(tripToken);

      if (response['success'] == true) {
        final manifest = ManifestModel.fromMap(response);
        _tripManifests[tripToken] = manifest;

        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load manifest');
      }
    } catch (e) {
      _setError('Failed to load manifest. Please check your connection.');
      debugPrint('Error loading trip manifest: $e');
    }
  }

  // Seat selection methods
  void selectSeat(int seatNo) {
    if (!_selectedSeats.contains(seatNo)) {
      _selectedSeats.add(seatNo);
      notifyListeners();
    }
  }

  void deselectSeat(int seatNo) {
    _selectedSeats.remove(seatNo);
    notifyListeners();
  }

  void toggleSeatSelection(int seatNo) {
    if (_selectedSeats.contains(seatNo)) {
      deselectSeat(seatNo);
    } else {
      selectSeat(seatNo);
    }
  }

  void clearSelectedSeats() {
    _selectedSeats.clear();
    notifyListeners();
  }

  bool isSeatSelected(int seatNo) {
    return _selectedSeats.contains(seatNo);
  }

  // Calculate total fare for selected seats
  double calculateTotalFare() {
    if (_currentTripToken == null) return 0;

    final trip = getCurrentTrip();
    if (trip != null) {
      final fare = double.tryParse(trip['fare']?.toString() ?? '0') ?? 0.0;
      return fare * _selectedSeats.length;
    }

    return 0;
  }

  // Get current trip details - FIXED to work with Map data
  Map<String, dynamic>? getCurrentTrip() {
    if (_currentTripToken == null) return null;

    // Search through all trip categories
    for (String direction in ['to_nairobi', 'from_nairobi', 'others']) {
      final directionTrips = _trips[direction] as List<dynamic>? ?? [];
      for (var trip in directionTrips) {
        if (trip is Map<String, dynamic> &&
            trip['token'] == _currentTripToken) {
          return trip;
        }
      }
    }

    return null;
  }

  // Validation methods
  bool canSelectSeat(int seatNo) {
    if (_currentTripToken == null) return false;

    final seats = getTripSeats(_currentTripToken!);
    final seat = seats.firstWhere(
      (seat) => seat.seatNo == seatNo,
      orElse: () => SeatModel(seatNo: seatNo, status: 'unavailable'),
    );

    return seat.isAvailable;
  }

  // Cache management
  Future<void> _cacheTripsData(String date, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('trips_$date', data.toString());
      await prefs.setInt(
        'trips_${date}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Failed to cache trips data: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadCachedTripsData(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('trips_$date');
      final timestamp = prefs.getInt('trips_${date}_timestamp');

      if (dataString != null && timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        // Cache is valid for 1 hour
        if (age <= 3600000) {
          // Note: You might need to implement proper JSON parsing here
          // This is a simplified version
          return {}; // Return parsed data
        }
      }
    } catch (e) {
      debugPrint('Failed to load cached trips data: $e');
    }
    return null;
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Clear all data
  void clearAllData() {
    _trips = {'to_nairobi': [], 'from_nairobi': [], 'others': []};
    _tripSeats.clear();
    _tripManifests.clear();
    _tripExpenses.clear();
    _selectedSeats.clear();
    _currentTripToken = null;
    _error = null;
    notifyListeners();
  }

  // Get trip statistics - updated to work with Map format
  Map<String, int> getTripStats() {
    final toNairobi = _trips['to_nairobi'] as List<dynamic>? ?? [];
    final fromNairobi = _trips['from_nairobi'] as List<dynamic>? ?? [];
    final others = _trips['others'] as List<dynamic>? ?? [];

    return {
      'total': toNairobi.length + fromNairobi.length + others.length,
      'to_nairobi': toNairobi.length,
      'from_nairobi': fromNairobi.length,
      'others': others.length,
    };
  }

  // Search trips - updated to work with Map format
  List<Map<String, dynamic>> searchTrips(String query) {
    final List<Map<String, dynamic>> allTrips = [];

    // Collect all trips from all directions
    for (String direction in ['to_nairobi', 'from_nairobi', 'others']) {
      final directionTrips = _trips[direction] as List<dynamic>? ?? [];
      for (var trip in directionTrips) {
        if (trip is Map<String, dynamic>) {
          allTrips.add(trip);
        }
      }
    }

    if (query.isEmpty) return allTrips;

    final lowercaseQuery = query.toLowerCase();

    return allTrips.where((trip) {
      final origin = trip['origin']?.toString().toLowerCase() ?? '';
      final destination = trip['destination']?.toString().toLowerCase() ?? '';
      final route = trip['route']?.toString().toLowerCase() ?? '';

      return origin.contains(lowercaseQuery) ||
          destination.contains(lowercaseQuery) ||
          route.contains(lowercaseQuery);
    }).toList();
  }
}
