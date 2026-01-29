import 'package:flutter/material.dart';

// Application Constants
class AppConstants {
  // App Information
  static const String appName = 'Transliner Cruiser';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://cruizer.tenzatech.co.ke';
  static const String apiVersion = 'api';
  static const String authApiPath = '/api/auth';
  static const String authApiUrl = '$baseUrl/$apiVersion/auth';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String appDateKey = 'app_date';

  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentMpesaExpress = 'mpesa-express';
  static const String paymentMpesaC2B = 'mpesa-c2b';

  // User Roles
  static const List<String> adminRoles = ['admin', 'super-admin'];
  static const List<String> managerRoles = ['admin', 'super-admin', 'manager'];
  static const List<String> operatorRoles = ['operator', 'booking-agent'];
  static const List<String> driverRoles = ['driver'];
}

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFDC2626);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Status Colors
  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusInfo = Color(0xFF3B82F6);

  // Seat Colors
  static const Color seatAvailable = Color(0xFF16A34A);
  static const Color seatBooked = Color(0xFFDC2626);
  static const Color seatSelected = Color(0xFF3B82F6);
  static const Color seatDisabled = Color(0xFF9CA3AF);

  // UI Elements
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFD1D5DB);
}

// App Sizes
class AppSizes {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Margin
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Component Sizes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double cardElevation = 2.0;
}

// App Strings
class AppStrings {
  static const String loginFailed =
      'Login failed. Please check your credentials.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';

  // Menu Items
  static const String trips = 'Trips';
  static const String appDate = 'App Date';
  static const String operations = 'Operations';
  static const String drivers = 'Drivers';
  static const String vehicles = 'Vehicles';
  static const String routes = 'Routes';
  static const String destinations = 'Destinations';
  static const String owners = 'Owners';
  static const String expenseTypes = 'Expense Types';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String logout = 'Logout';
}

// Validation Helpers
class AppValidation {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Kenya phone number validation
    if (!RegExp(r'^(\+254|254|0)?[17]\d{8}$').hasMatch(cleanPhone)) {
      return 'Enter a valid Kenyan phone number';
    }

    return null;
  }

  static String? validateIdNumber(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final cleanId = value.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanId.length < 6 || cleanId.length > 8) {
        return 'ID number must be 6-8 digits';
      }
    }
    return null;
  }
}

// Extension methods
extension StringExtensions on String {
  String toDisplayString() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    return split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

extension DateTimeExtensions on DateTime {
  String toDisplayString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final thisDate = DateTime(year, month, day);

    if (thisDate == today) {
      return 'Today';
    } else if (thisDate == tomorrow) {
      return 'Tomorrow';
    } else if (thisDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    }
  }

  String toApiDateString() {
    return '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String toApiString() {
    return toApiDateString();
  }
}
