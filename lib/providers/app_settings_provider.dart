import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AppSettingsProvider extends ChangeNotifier {
  DateTime _appDate = DateTime.now().add(const Duration(days: 1));
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  bool _isOfflineMode = false;

  // Getters
  DateTime get appDate => _appDate;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get isOfflineMode => _isOfflineMode;

  // Get formatted app date for API calls
  String get appDateForApi => _appDate.toApiString();

  // Get formatted app date for display
  String get appDateForDisplay => _appDate.toDisplayString();

  // Initialize settings from shared preferences
  Future<void> initializeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load app date
      final savedDateString = prefs.getString(AppConstants.appDateKey);
      if (savedDateString != null) {
        final savedDate = DateTime.tryParse(savedDateString);
        if (savedDate != null) {
          _appDate = savedDate;
        }
      }

      // Load dark mode setting
      _isDarkMode = prefs.getBool('dark_mode') ?? false;

      // Load language setting
      _selectedLanguage = prefs.getString('language') ?? 'en';

      // Load offline mode setting
      _isOfflineMode = prefs.getBool('offline_mode') ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing app settings: $e');
    }
  }

  // Set app date
  Future<void> setAppDate(DateTime date) async {
    try {
      _appDate = date;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.appDateKey, date.toIso8601String());

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting app date: $e');
    }
  }

  // Set today as app date
  Future<void> setAppDateToToday() async {
    await setAppDate(DateTime.now());
  }

  // Set tomorrow as app date
  Future<void> setAppDateToTomorrow() async {
    await setAppDate(DateTime.now().add(const Duration(days: 1)));
  }

  // Increment app date by one day
  Future<void> incrementAppDate() async {
    await setAppDate(_appDate.add(const Duration(days: 1)));
  }

  // Decrement app date by one day
  Future<void> decrementAppDate() async {
    final newDate = _appDate.subtract(const Duration(days: 1));
    // Don't allow dates in the past
    if (newDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
      await setAppDate(newDate);
    }
  }

  // Check if app date is today
  bool get isAppDateToday {
    final today = DateTime.now();
    return _appDate.year == today.year &&
        _appDate.month == today.month &&
        _appDate.day == today.day;
  }

  // Check if app date is tomorrow
  bool get isAppDateTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _appDate.year == tomorrow.year &&
        _appDate.month == tomorrow.month &&
        _appDate.day == tomorrow.day;
  }

  // Get relative date string (Today, Tomorrow, or actual date)
  String get relativeDateString {
    if (isAppDateToday) return 'Today';
    if (isAppDateTomorrow) return 'Tomorrow';
    return appDateForDisplay;
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    try {
      _isDarkMode = !_isDarkMode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _isDarkMode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling dark mode: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    try {
      _selectedLanguage = languageCode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Toggle offline mode
  Future<void> toggleOfflineMode() async {
    try {
      _isOfflineMode = !_isOfflineMode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_mode', _isOfflineMode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling offline mode: $e');
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await setAppDate(DateTime.now().add(const Duration(days: 1)));

      _isDarkMode = false;
      _selectedLanguage = 'en';
      _isOfflineMode = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setBool('offline_mode', _isOfflineMode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Clear all settings data
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.appDateKey);
      await prefs.remove('dark_mode');
      await prefs.remove('language');
      await prefs.remove('offline_mode');

      // Reset to defaults
      _appDate = DateTime.now().add(const Duration(days: 1));
      _isDarkMode = false;
      _selectedLanguage = 'en';
      _isOfflineMode = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing settings: $e');
    }
  }

  // Get available date options for quick selection
  List<Map<String, dynamic>> get quickDateOptions {
    final now = DateTime.now();
    return [
      {'label': 'Today', 'date': now, 'isSelected': isAppDateToday},
      {
        'label': 'Tomorrow',
        'date': now.add(const Duration(days: 1)),
        'isSelected': isAppDateTomorrow,
      },
      {
        'label': 'Day After Tomorrow',
        'date': now.add(const Duration(days: 2)),
        'isSelected': _appDate.isAtSameMomentAs(
          now.add(const Duration(days: 2)),
        ),
      },
    ];
  }

  // Check if a specific date is the current app date
  bool isDateSelected(DateTime date) {
    return _appDate.year == date.year &&
        _appDate.month == date.month &&
        _appDate.day == date.day;
  }

  // Get number of days from today
  int get daysFromToday {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final appDateOnly = DateTime(_appDate.year, _appDate.month, _appDate.day);

    return appDateOnly.difference(todayOnly).inDays;
  }

  // Validate if app date is not in the past
  bool get isValidAppDate {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final appDateOnly = DateTime(_appDate.year, _appDate.month, _appDate.day);

    return appDateOnly.isAtSameMomentAs(todayOnly) ||
        appDateOnly.isAfter(todayOnly);
  }

  // Get app date warning if needed
  String? get appDateWarning {
    if (!isValidAppDate) {
      return 'Selected date is in the past';
    }

    final daysAhead = daysFromToday;
    if (daysAhead > 30) {
      return 'Selected date is more than 30 days ahead';
    }

    return null;
  }

  // Export settings for backup
  Map<String, dynamic> exportSettings() {
    return {
      'app_date': _appDate.toIso8601String(),
      'dark_mode': _isDarkMode,
      'language': _selectedLanguage,
      'offline_mode': _isOfflineMode,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings['app_date'] != null) {
        final date = DateTime.tryParse(settings['app_date']);
        if (date != null) {
          await setAppDate(date);
        }
      }

      if (settings['dark_mode'] != null) {
        _isDarkMode = settings['dark_mode'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dark_mode', _isDarkMode);
      }

      if (settings['language'] != null) {
        await setLanguage(settings['language']);
      }

      if (settings['offline_mode'] != null) {
        _isOfflineMode = settings['offline_mode'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('offline_mode', _isOfflineMode);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return false;
    }
  }
}
