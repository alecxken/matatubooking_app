import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_settings_provider.dart';
import '../../utils/constants.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSection(settingsProvider),
                const SizedBox(height: AppSizes.marginLarge),
                _buildPreferencesSection(settingsProvider),
                const SizedBox(height: AppSizes.marginLarge),
                _buildAppInfoSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection(AppSettingsProvider settingsProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'App Date Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current date display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current App Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settingsProvider.appDateForDisplay,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '(${settingsProvider.relativeDateString})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick date options
            const Text(
              'Quick Select',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickDateButton(
                    'Today',
                    () => settingsProvider.setAppDateToToday(),
                    settingsProvider.isAppDateToday,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickDateButton(
                    'Tomorrow',
                    () => settingsProvider.setAppDateToTomorrow(),
                    settingsProvider.isAppDateTomorrow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Custom date picker
            const Text(
              'Custom Date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDatePicker(context, settingsProvider),
                icon: const Icon(Icons.date_range),
                label: const Text('Select Custom Date'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),

            // Date warning
            if (settingsProvider.appDateWarning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.statusWarning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.statusWarning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        settingsProvider.appDateWarning!,
                        style: TextStyle(color: AppColors.statusWarning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(
    String label,
    VoidCallback onPressed,
    bool isSelected,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : null,
        foregroundColor: isSelected ? Colors.white : AppColors.primary,
        side: BorderSide(color: AppColors.primary),
      ),
      child: Text(label),
    );
  }

  Widget _buildPreferencesSection(AppSettingsProvider settingsProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'App Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dark mode toggle
            ListTile(
              leading: Icon(
                settingsProvider.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppColors.textSecondary,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                settingsProvider.isDarkMode
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              trailing: Switch(
                value: settingsProvider.isDarkMode,
                onChanged: (_) => settingsProvider.toggleDarkMode(),
                activeColor: AppColors.primary,
              ),
            ),

            const Divider(),

            // Offline mode toggle
            ListTile(
              leading: Icon(
                settingsProvider.isOfflineMode ? Icons.cloud_off : Icons.cloud,
                color: AppColors.textSecondary,
              ),
              title: const Text('Offline Mode'),
              subtitle: Text(
                settingsProvider.isOfflineMode
                    ? 'Use cached data when offline'
                    : 'Always fetch latest data',
              ),
              trailing: Switch(
                value: settingsProvider.isOfflineMode,
                onChanged: (_) => settingsProvider.toggleOfflineMode(),
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'App Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow('App Name', AppConstants.appName),
            _buildInfoRow('Version', AppConstants.appVersion),
            _buildInfoRow('Developer', 'TenzaTech'),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAboutDialog,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _contactSupport,
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Support'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    AppSettingsProvider settingsProvider,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: settingsProvider.appDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      await settingsProvider.setAppDate(selectedDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'App date updated to ${selectedDate.toDisplayString()}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConstants.appName,
        applicationVersion: AppConstants.appVersion,
        applicationIcon: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 32,
          ),
        ),
        children: [
          const Text(
            'A comprehensive mobile solution for bus booking and trip management in Kenya.',
          ),
          const SizedBox(height: 16),
          const Text('Developed by TenzaTech'),
          const SizedBox(height: 8),
          const Text('© 2024 TenzaTech. All rights reserved.'),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Get in touch with our support team:'),
            SizedBox(height: 12),
            Text('📧 Email: tech@tenzatech.co.ke'),
            Text('📱 Phone: +254 700 000 000'),
            Text('🌐 Website: www.tenzatech.co.ke'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement email launch
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }
}
