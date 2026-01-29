import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.canAccessOperations) {
            return const ErrorDisplayWidget(
              message: 'You do not have permission to access operations',
              icon: Icons.security,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(authProvider),
                const SizedBox(height: AppSizes.marginLarge),
                _buildFleetManagementSection(authProvider),
                const SizedBox(height: AppSizes.marginLarge),
                if (authProvider.hasAnyRole(AppConstants.adminRoles))
                  _buildAdminSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    authProvider.userInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.userDisplayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Role: ${authProvider.user?.primaryRole ?? "User"}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Manage your fleet operations, track vehicles, and monitor trips.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetManagementSection(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Fleet Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of operation cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                if (authProvider.canManageTrips) ...[
                  _buildOperationCard(
                    title: 'Drivers',
                    subtitle: 'Manage driver information',
                    icon: Icons.person,
                    color: Colors.blue,
                    onTap: () => _showComingSoon('Driver Management'),
                  ),
                  _buildOperationCard(
                    title: 'Vehicles',
                    subtitle: 'Fleet vehicle details',
                    icon: Icons.directions_bus,
                    color: Colors.green,
                    onTap: () => _showComingSoon('Vehicle Management'),
                  ),
                  _buildOperationCard(
                    title: 'Routes',
                    subtitle: 'Route configuration',
                    icon: Icons.route,
                    color: Colors.orange,
                    onTap: () => _showComingSoon('Route Management'),
                  ),
                  _buildOperationCard(
                    title: 'Destinations',
                    subtitle: 'Destination points',
                    icon: Icons.location_on,
                    color: Colors.red,
                    onTap: () => _showComingSoon('Destination Management'),
                  ),
                ],
              ],
            ),

            if (!authProvider.canManageTrips) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.statusWarning),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Limited access: Contact your administrator for fleet management permissions.',
                        style: TextStyle(fontSize: 14),
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

  Widget _buildAdminSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppColors.statusError),
                const SizedBox(width: 8),
                Text(
                  'Admin Operations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusError,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildOperationCard(
                  title: 'Owners',
                  subtitle: 'Vehicle owners',
                  icon: Icons.business,
                  color: Colors.purple,
                  onTap: () => context.go('/operations/owners'),
                ),
                _buildOperationCard(
                  title: 'Expenses',
                  subtitle: 'Expense categories',
                  icon: Icons.money,
                  color: Colors.teal,
                  onTap: () => _showComingSoon('Expense Management'),
                ),
                _buildOperationCard(
                  title: 'Users',
                  subtitle: 'User management',
                  icon: Icons.people,
                  color: Colors.indigo,
                  onTap: () => _showComingSoon('User Management'),
                ),
                _buildOperationCard(
                  title: 'Reports',
                  subtitle: 'System reports',
                  icon: Icons.analytics,
                  color: Colors.amber,
                  onTap: () => _showComingSoon('Advanced Reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.construction,
          color: AppColors.statusWarning,
          size: 48,
        ),
        title: const Text('Coming Soon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$feature is currently under development.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusInfo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, color: AppColors.statusInfo, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This feature will be available in the next update.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showNotificationPreferences();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Notify Me'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You\'ll be notified when new features are available'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Placeholder screens that could be implemented
class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const LoadingState(
        title: 'Driver Management',
        subtitle: 'Feature under development',
        icon: Icons.construction,
        iconColor: AppColors.statusWarning,
      ),
    );
  }
}

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const LoadingState(
        title: 'Vehicle Management',
        subtitle: 'Feature under development',
        icon: Icons.construction,
        iconColor: AppColors.statusWarning,
      ),
    );
  }
}
