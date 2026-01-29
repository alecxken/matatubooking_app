import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  // Check if user has specific role
  bool hasRole(String role) {
    if (_user == null) return false;
    return _user!.roles.contains(role);
  }

  // Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    if (_user == null) return false;
    return _user!.roles.any((userRole) => roles.contains(userRole));
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_user == null) return false;
    return _user!.permissions.contains(permission);
  }

  // Initialize auth state on app start
  Future<void> initializeAuth() async {
    try {
      _token = await _secureStorage.read(key: AppConstants.authTokenKey);

      if (_token != null) {
        final userJson = await _secureStorage.read(
          key: AppConstants.userDataKey,
        );
        if (userJson != null) {
          _user = UserModel.fromJson(userJson);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await logout();
    }
  }

  // Login method
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.login(username, password);

      if (response['token'] != null) {
        _token = response['token'];

        // Create user from API response format
        final userData = {
          'id': 1, // Default ID, update if your API provides user ID
          'name': response['name'] ?? '',
          'email': response['email'] ?? '',
          'username': response['username'] ?? username,
          'roles': response['roles'] ?? [],
          'permissions': response['permissions'] ?? [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        _user = UserModel.fromMap(userData);

        // Store credentials securely
        await _secureStorage.write(
          key: AppConstants.authTokenKey,
          value: _token!,
        );
        await _secureStorage.write(
          key: AppConstants.userDataKey,
          value: _user!.toJson(),
        );

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? AppStrings.loginFailed;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _setLoading(false);
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Call API logout endpoint if authenticated
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      // Clear local storage regardless of API call result
      await _secureStorage.deleteAll();
      _token = null;
      _user = null;
      _error = null;
      notifyListeners();
    }
  }

  // Refresh user profile
  Future<void> refreshUserProfile() async {
    if (_token == null) return;

    try {
      final response = await _apiService.getUserProfile();
      if (response['success'] == true) {
        _user = UserModel.fromMap(response['user']);
        await _secureStorage.write(
          key: AppConstants.userDataKey,
          value: _user!.toJson(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    if (_token == null) return false;

    _setLoading(true);
    try {
      final response = await _apiService.updateUserProfile(profileData);
      if (response['success'] == true) {
        _user = UserModel.fromMap(response['user']);
        await _secureStorage.write(
          key: AppConstants.userDataKey,
          value: _user!.toJson(),
        );
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Update failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _setLoading(false);
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_token == null) return false;

    _setLoading(true);
    try {
      final response = await _apiService.changePassword(
        currentPassword,
        newPassword,
      );
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Password change failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _setLoading(false);
      debugPrint('Change password error: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get user display name
  String get userDisplayName {
    if (_user == null) return 'Unknown User';
    return '${_user!.firstName} ${_user!.lastName}';
  }

  // Get user initials for avatar
  String get userInitials {
    if (_user == null) return 'U';
    return '${_user!.firstName[0]}${_user!.lastName[0]}'.toUpperCase();
  }

  // Check if user can access operations
  bool get canAccessOperations {
    return hasAnyRole(AppConstants.adminRoles) ||
        hasAnyRole(AppConstants.managerRoles);
  }

  // Check if user can manage trips
  bool get canManageTrips {
    return hasAnyRole(AppConstants.adminRoles) ||
        hasAnyRole(AppConstants.managerRoles) ||
        hasAnyRole(AppConstants.operatorRoles);
  }

  // Check if user can book seats
  bool get canBookSeats {
    return !hasAnyRole(AppConstants.driverRoles) || hasPermission('book-seats');
  }

  // Check if user can view manifests
  bool get canViewManifests {
    return hasAnyRole(AppConstants.adminRoles) ||
        hasAnyRole(AppConstants.managerRoles) ||
        hasAnyRole(AppConstants.driverRoles);
  }
}
