// lib/providers/trip_management_provider.dart

import 'package:flutter/foundation.dart';
import '../models/owner_model.dart';
import '../models/vehicle_model.dart';
import '../models/driver_model.dart';
import '../models/route_model.dart';
import '../models/destination_model.dart';
import '../models/expense_template_model.dart';
import '../models/trip_template_model.dart';
import '../services/trip_management_api_service.dart';

/// Trip Management Provider
/// Manages state for all trip management entities
class TripManagementProvider extends ChangeNotifier {
  final TripManagementApiService _apiService = TripManagementApiService();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // Owners
  List<OwnerModel> _owners = [];
  bool _isLoadingOwners = false;
  String? _ownersError;

  // Vehicles
  List<VehicleModel> _vehicles = [];
  bool _isLoadingVehicles = false;
  String? _vehiclesError;

  // Drivers
  List<DriverModel> _drivers = [];
  bool _isLoadingDrivers = false;
  String? _driversError;

  // Routes
  List<RouteModel> _routes = [];
  bool _isLoadingRoutes = false;
  String? _routesError;

  // Destinations
  List<DestinationModel> _destinations = [];
  bool _isLoadingDestinations = false;
  String? _destinationsError;

  // Expense Templates
  List<ExpenseTemplateModel> _expenseTemplates = [];
  bool _isLoadingExpenses = false;
  String? _expensesError;

  // Trip Templates
  List<TripTemplateModel> _tripTemplates = [];
  bool _isLoadingTemplates = false;
  String? _templatesError;

  // Dropdown Options
  DropdownOptionsModel? _dropdownOptions;
  bool _isLoadingDropdownOptions = false;
  String? _dropdownOptionsError;

  // ============================================================================
  // GETTERS
  // ============================================================================

  // Owners
  List<OwnerModel> get owners => _owners;
  bool get isLoadingOwners => _isLoadingOwners;
  String? get ownersError => _ownersError;
  List<OwnerModel> get activeOwners =>
      _owners.where((owner) => owner.isActive).toList();

  // Vehicles
  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoadingVehicles => _isLoadingVehicles;
  String? get vehiclesError => _vehiclesError;
  List<VehicleModel> get activeVehicles =>
      _vehicles.where((vehicle) => vehicle.isActive).toList();

  // Drivers
  List<DriverModel> get drivers => _drivers;
  bool get isLoadingDrivers => _isLoadingDrivers;
  String? get driversError => _driversError;
  List<DriverModel> get activeDrivers =>
      _drivers.where((driver) => driver.isActive).toList();

  // Routes
  List<RouteModel> get routes => _routes;
  bool get isLoadingRoutes => _isLoadingRoutes;
  String? get routesError => _routesError;
  List<RouteModel> get activeRoutes =>
      _routes.where((route) => route.isActive).toList();

  // Destinations
  List<DestinationModel> get destinations => _destinations;
  bool get isLoadingDestinations => _isLoadingDestinations;
  String? get destinationsError => _destinationsError;
  List<DestinationModel> get activeDestinations =>
      _destinations.where((dest) => dest.isActive).toList();

  // Expense Templates
  List<ExpenseTemplateModel> get expenseTemplates => _expenseTemplates;
  bool get isLoadingExpenses => _isLoadingExpenses;
  String? get expensesError => _expensesError;
  List<ExpenseTemplateModel> get activeExpenseTemplates =>
      _expenseTemplates.where((expense) => expense.isActive).toList();

  // Trip Templates
  List<TripTemplateModel> get tripTemplates => _tripTemplates;
  bool get isLoadingTemplates => _isLoadingTemplates;
  String? get templatesError => _templatesError;
  List<TripTemplateModel> get activeTripTemplates =>
      _tripTemplates.where((template) => template.isActive).toList();

  // Dropdown Options
  DropdownOptionsModel? get dropdownOptions => _dropdownOptions;
  bool get isLoadingDropdownOptions => _isLoadingDropdownOptions;
  String? get dropdownOptionsError => _dropdownOptionsError;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void setToken(String token) {
    _apiService.setToken(token);
  }

  /// Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      fetchOwners(),
      fetchVehicles(),
      fetchDrivers(),
      fetchRoutes(),
      fetchDestinations(),
      fetchExpenseTemplates(),
      fetchTripTemplates(),
    ]);
  }

  // ============================================================================
  // OWNER METHODS
  // ============================================================================

  Future<void> fetchOwners() async {
    _isLoadingOwners = true;
    _ownersError = null;
    notifyListeners();

    try {
      _owners = await _apiService.getOwners();
    } catch (e) {
      _ownersError = e.toString();
    } finally {
      _isLoadingOwners = false;
      notifyListeners();
    }
  }

  Future<OwnerModel?> createOwner(OwnerModel owner) async {
    try {
      final newOwner = await _apiService.createOwner(owner);
      _owners.insert(0, newOwner);
      notifyListeners();
      return newOwner;
    } catch (e) {
      _ownersError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOwner(int id, OwnerModel owner) async {
    try {
      final updatedOwner = await _apiService.updateOwner(id, owner);
      final index = _owners.indexWhere((o) => o.id == id);
      if (index != -1) {
        _owners[index] = updatedOwner;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _ownersError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOwner(int id) async {
    try {
      await _apiService.deleteOwner(id);
      _owners.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _ownersError = e.toString();
      notifyListeners();
      return false;
    }
  }

  OwnerModel? getOwnerById(int id) {
    try {
      return _owners.firstWhere((owner) => owner.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearOwnersError() {
    _ownersError = null;
    notifyListeners();
  }

  // ============================================================================
  // VEHICLE METHODS
  // ============================================================================

  Future<void> fetchVehicles() async {
    _isLoadingVehicles = true;
    _vehiclesError = null;
    notifyListeners();

    try {
      _vehicles = await _apiService.getVehicles();
    } catch (e) {
      _vehiclesError = e.toString();
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  Future<VehicleModel?> createVehicle(VehicleModel vehicle) async {
    try {
      final newVehicle = await _apiService.createVehicle(vehicle);
      _vehicles.insert(0, newVehicle);
      notifyListeners();
      return newVehicle;
    } catch (e) {
      _vehiclesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateVehicle(int id, VehicleModel vehicle) async {
    try {
      final updatedVehicle = await _apiService.updateVehicle(id, vehicle);
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _vehiclesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await _apiService.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _vehiclesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<VehicleModel> getVehiclesByType(String type) {
    return _vehicles.where((v) => v.vehicleType == type).toList();
  }

  void clearVehiclesError() {
    _vehiclesError = null;
    notifyListeners();
  }

  // ============================================================================
  // DRIVER METHODS
  // ============================================================================

  Future<void> fetchDrivers() async {
    _isLoadingDrivers = true;
    _driversError = null;
    notifyListeners();

    try {
      _drivers = await _apiService.getDrivers();
    } catch (e) {
      _driversError = e.toString();
    } finally {
      _isLoadingDrivers = false;
      notifyListeners();
    }
  }

  Future<DriverModel?> createDriver(DriverModel driver) async {
    try {
      final newDriver = await _apiService.createDriver(driver);
      _drivers.insert(0, newDriver);
      notifyListeners();
      return newDriver;
    } catch (e) {
      _driversError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDriver(int id, DriverModel driver) async {
    try {
      final updatedDriver = await _apiService.updateDriver(id, driver);
      final index = _drivers.indexWhere((d) => d.id == id);
      if (index != -1) {
        _drivers[index] = updatedDriver;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _driversError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDriver(int id) async {
    try {
      await _apiService.deleteDriver(id);
      _drivers.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _driversError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearDriversError() {
    _driversError = null;
    notifyListeners();
  }

  // ============================================================================
  // ROUTE METHODS
  // ============================================================================

  Future<void> fetchRoutes() async {
    _isLoadingRoutes = true;
    _routesError = null;
    notifyListeners();

    try {
      _routes = await _apiService.getRoutes();
    } catch (e) {
      _routesError = e.toString();
    } finally {
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  Future<RouteModel?> createRoute(RouteModel route) async {
    try {
      final newRoute = await _apiService.createRoute(route);
      _routes.insert(0, newRoute);
      notifyListeners();
      return newRoute;
    } catch (e) {
      _routesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRoute(int id, RouteModel route) async {
    try {
      final updatedRoute = await _apiService.updateRoute(id, route);
      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routes[index] = updatedRoute;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _routesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoute(int id) async {
    try {
      await _apiService.deleteRoute(id);
      _routes.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _routesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<SubrouteModel?> addSubroute(SubrouteModel subroute) async {
    try {
      final newSubroute = await _apiService.addSubroute(subroute);
      // Update the parent route with the new subroute
      final routeIndex = _routes.indexWhere((r) => r.id == subroute.routeId);
      if (routeIndex != -1) {
        final updatedSubroutes = [
          ..._routes[routeIndex].subroutes,
          newSubroute
        ];
        _routes[routeIndex] =
            _routes[routeIndex].copyWith(subroutes: updatedSubroutes);
        notifyListeners();
      }
      return newSubroute;
    } catch (e) {
      _routesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearRoutesError() {
    _routesError = null;
    notifyListeners();
  }

  // ============================================================================
  // DESTINATION METHODS
  // ============================================================================

  Future<void> fetchDestinations() async {
    _isLoadingDestinations = true;
    _destinationsError = null;
    notifyListeners();

    try {
      _destinations = await _apiService.getDestinations();
    } catch (e) {
      _destinationsError = e.toString();
    } finally {
      _isLoadingDestinations = false;
      notifyListeners();
    }
  }

  Future<List<DestinationModel>?> createDestinations(String destinations) async {
    try {
      final newDestinations = await _apiService.createDestinations(destinations);
      _destinations.insertAll(0, newDestinations);
      notifyListeners();
      return newDestinations;
    } catch (e) {
      _destinationsError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDestination(int id, DestinationModel destination) async {
    try {
      final updatedDestination =
          await _apiService.updateDestination(id, destination);
      final index = _destinations.indexWhere((d) => d.id == id);
      if (index != -1) {
        _destinations[index] = updatedDestination;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _destinationsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDestination(int id) async {
    try {
      await _apiService.deleteDestination(id);
      _destinations.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _destinationsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearDestinationsError() {
    _destinationsError = null;
    notifyListeners();
  }

  // ============================================================================
  // EXPENSE TEMPLATE METHODS
  // ============================================================================

  Future<void> fetchExpenseTemplates() async {
    _isLoadingExpenses = true;
    _expensesError = null;
    notifyListeners();

    try {
      _expenseTemplates = await _apiService.getExpenseTemplates();
    } catch (e) {
      _expensesError = e.toString();
    } finally {
      _isLoadingExpenses = false;
      notifyListeners();
    }
  }

  Future<List<ExpenseTemplateModel>?> createExpenseTemplate(
    ExpenseTemplateModel expense, {
    List<String>? vehicleTypes,
  }) async {
    try {
      final newExpenses = await _apiService.createExpenseTemplate(
        expense,
        vehicleTypes: vehicleTypes,
      );
      _expenseTemplates.insertAll(0, newExpenses);
      notifyListeners();
      return newExpenses;
    } catch (e) {
      _expensesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExpenseTemplate(
      int id, ExpenseTemplateModel expense) async {
    try {
      final updatedExpense =
          await _apiService.updateExpenseTemplate(id, expense);
      final index = _expenseTemplates.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenseTemplates[index] = updatedExpense;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _expensesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpenseTemplate(int id) async {
    try {
      await _apiService.deleteExpenseTemplate(id);
      _expenseTemplates.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _expensesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<ExpenseTemplateModel>> getDefaultExpenses({
    String? vehicleType,
  }) async {
    try {
      return await _apiService.getDefaultExpenses(vehicleType: vehicleType);
    } catch (e) {
      _expensesError = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearExpensesError() {
    _expensesError = null;
    notifyListeners();
  }

  // ============================================================================
  // TRIP TEMPLATE METHODS
  // ============================================================================

  Future<void> fetchTripTemplates() async {
    _isLoadingTemplates = true;
    _templatesError = null;
    notifyListeners();

    try {
      _tripTemplates = await _apiService.getTemplates();
    } catch (e) {
      _templatesError = e.toString();
    } finally {
      _isLoadingTemplates = false;
      notifyListeners();
    }
  }

  Future<TripTemplateModel?> createTripTemplate(
      TripTemplateModel template) async {
    try {
      final newTemplate = await _apiService.createTemplate(template);
      _tripTemplates.insert(0, newTemplate);
      notifyListeners();
      return newTemplate;
    } catch (e) {
      _templatesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateTripTemplate(int id, TripTemplateModel template) async {
    try {
      final updatedTemplate = await _apiService.updateTemplate(id, template);
      final index = _tripTemplates.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tripTemplates[index] = updatedTemplate;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _templatesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTripTemplate(int id) async {
    try {
      await _apiService.deleteTemplate(id);
      _tripTemplates.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _templatesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<TemplateTripsModel?> addTripToTemplate(
      TemplateTripsModel trip) async {
    try {
      final newTrip = await _apiService.addTripToTemplate(trip);
      // Update the parent template with the new trip
      final templateIndex =
          _tripTemplates.indexWhere((t) => t.id == trip.templateId);
      if (templateIndex != -1) {
        final updatedTrips = [..._tripTemplates[templateIndex].trips, newTrip];
        _tripTemplates[templateIndex] =
            _tripTemplates[templateIndex].copyWith(trips: updatedTrips);
        notifyListeners();
      }
      return newTrip;
    } catch (e) {
      _templatesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearTemplatesError() {
    _templatesError = null;
    notifyListeners();
  }

  // ============================================================================
  // DROPDOWN OPTIONS
  // ============================================================================

  Future<void> fetchDropdownOptions() async {
    _isLoadingDropdownOptions = true;
    _dropdownOptionsError = null;
    notifyListeners();

    try {
      _dropdownOptions = await _apiService.getDropdownOptions();
    } catch (e) {
      _dropdownOptionsError = e.toString();
    } finally {
      _isLoadingDropdownOptions = false;
      notifyListeners();
    }
  }

  void clearDropdownOptionsError() {
    _dropdownOptionsError = null;
    notifyListeners();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  void clearAllErrors() {
    _ownersError = null;
    _vehiclesError = null;
    _driversError = null;
    _routesError = null;
    _destinationsError = null;
    _expensesError = null;
    _templatesError = null;
    _dropdownOptionsError = null;
    notifyListeners();
  }

  void reset() {
    _owners = [];
    _vehicles = [];
    _drivers = [];
    _routes = [];
    _destinations = [];
    _expenseTemplates = [];
    _tripTemplates = [];
    _dropdownOptions = null;
    clearAllErrors();
  }
}
