import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/modern_drawer.dart';
import '../trip/parcels_management_screen.dart';
import 'home_content.dart';
import 'trip_management_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Remove this line since we'll access the method differently
  // final GlobalKey<_HomeContentState> _homeContentKey = GlobalKey<_HomeContentState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TranslinerTheme.lightGray,
      appBar: _buildAppBar(),
      drawer: const ModernDrawer(),
      body: const HomeContent(), // Remove the key
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transliner Cruiser',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                settingsProvider.relativeDateString,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          );
        },
      ),
      actions: [
        // Create Trip Button (only show for authorized users)
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.canManageTrips) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showCreateTripModal,
                  tooltip: 'Create Trip',
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/settings'),
            tooltip: 'App Date',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Refreshing data...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: TranslinerTheme.charcoal,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Drawer(
          backgroundColor: TranslinerTheme.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(user),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Trips',
                onTap: () {
                  Navigator.of(context).pop();
                },
                isSelected: true,
              ),
              _buildDrawerItem(
                icon: Icons.calendar_today,
                title: 'App Date',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/settings');
                },
              ),
              if (authProvider.canAccessOperations) ...[
                const Divider(color: TranslinerTheme.gray100, thickness: 1),
                _buildExpandableDrawerItem(
                  icon: Icons.settings,
                  title: 'Operations',
                  children: [
                    if (authProvider.canManageTrips) ...[
                      _buildSubDrawerItem(
                        title: 'Drivers',
                        icon: Icons.person,
                        onTap: () => _navigateToOperations('drivers'),
                      ),
                      _buildSubDrawerItem(
                        title: 'Vehicles',
                        icon: Icons.directions_bus,
                        onTap: () => _navigateToOperations('vehicles'),
                      ),
                      _buildSubDrawerItem(
                        title: 'Routes',
                        icon: Icons.route,
                        onTap: () => _navigateToOperations('routes'),
                      ),
                      _buildSubDrawerItem(
                        title: 'Destinations',
                        icon: Icons.location_on,
                        onTap: () => _navigateToOperations('destinations'),
                      ),
                      _buildSubDrawerItem(
                        title: 'Parcels',
                        icon: Icons.inventory_2,
                        onTap: () => _navigateToParcels(),
                      ),
                    ],
                    if (authProvider.hasAnyRole(['admin', 'super-admin'])) ...[
                      _buildSubDrawerItem(
                        title: 'Owners',
                        icon: Icons.business,
                        onTap: () => _navigateToOperations('owners'),
                      ),
                      _buildSubDrawerItem(
                        title: 'Expense Types',
                        icon: Icons.money,
                        onTap: () => _navigateToOperations('expenses'),
                      ),
                    ],
                  ],
                ),
              ],
              const Divider(color: TranslinerTheme.gray100, thickness: 1),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () {
                  Navigator.of(context).pop();
                  _showProfileDialog();
                },
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/settings');
                },
              ),
              const Divider(color: TranslinerTheme.gray100, thickness: 1),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _handleLogout(),
                textColor: TranslinerTheme.errorRed,
              ),
              const SizedBox(height: 20),
              _buildAppInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(user) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: TranslinerTheme.primaryGradient,
      ),
      child: UserAccountsDrawerHeader(
        decoration: const BoxDecoration(color: Colors.transparent),
        accountName: Text(
          user?.displayName ?? 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: TranslinerTheme.white,
          ),
        ),
        accountEmail: Text(
          user?.email ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        currentAccountPicture: Container(
          decoration: BoxDecoration(
            color: TranslinerTheme.white,
            shape: BoxShape.circle,
            boxShadow: TranslinerShadows.primaryShadow,
          ),
          child: CircleAvatar(
            backgroundColor: TranslinerTheme.white,
            child: Text(
              user?.initials ?? 'U',
              style: const TextStyle(
                color: TranslinerTheme.primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        currentAccountPictureSize: const Size.square(72),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              color: TranslinerTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TranslinerTheme.primaryRed.withOpacity(0.3),
                width: 1,
              ),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? TranslinerTheme.primaryRed
              : (textColor ?? TranslinerTheme.charcoal),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? TranslinerTheme.primaryRed
                : (textColor ?? TranslinerTheme.charcoal),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubDrawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      child: ListTile(
        leading: Icon(icon, color: TranslinerTheme.gray600, size: 20),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: TranslinerTheme.gray600),
        ),
        contentPadding: const EdgeInsets.only(left: 56, right: 16),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildExpandableDrawerItem({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ExpansionTile(
        leading: Icon(icon, color: TranslinerTheme.charcoal),
        title: Text(
          title,
          style: const TextStyle(
            color: TranslinerTheme.charcoal,
            fontWeight: FontWeight.normal,
          ),
        ),
        iconColor: TranslinerTheme.primaryRed,
        collapsedIconColor: TranslinerTheme.gray600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        children: children,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Padding(
      padding: TranslinerSpacing.cardPadding,
      child: Column(
        children: [
          Text(
            'Transliner Cruiser v1.0.0',
            style: const TextStyle(
              color: TranslinerTheme.gray600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'by TenzaTech',
            style: const TextStyle(
              color: TranslinerTheme.gray600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToOperations(String type) {
    Navigator.of(context).pop();
    context.go('/operations?type=$type');
  }

  void _navigateToParcels() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ParcelsManagementScreen()),
    );
  }

  void _showCreateTripModal() {
    // Direct modal call instead of using key reference
    // showDialog(
    //   context: context,
    // //  builder: (context) => _TripManagementModal(
    //     // onSaved: () {
    //     //   Navigator.of(context).pop();
    //     //   ScaffoldMessenger.of(context).showSnackBar(
    //     //     const SnackBar(
    //     //       content: Text('Trip created successfully'),
    //     //       backgroundColor: TranslinerTheme.successGreen,
    //     //       behavior: SnackBarBehavior.floating,
    //     //     ),
    //     //   );
    //     // },
    //   ),
    // );
  }

  void _showProfileDialog() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TranslinerTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: TranslinerTheme.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Name', user?.displayName ?? 'N/A'),
            _buildProfileRow('Email', user?.email ?? 'N/A'),
            _buildProfileRow('Phone', user?.phone ?? 'N/A'),
            _buildProfileRow('Role', user?.primaryRole ?? 'N/A'),
            const SizedBox(height: 16),
            if (user?.roles.isNotEmpty == true) ...[
              const Text(
                'Permissions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: TranslinerTheme.charcoal,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: user!.roles
                    .map(
                      (role) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TranslinerTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TranslinerTheme.primaryRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          role.replaceAll('-', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.primaryRed,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: TranslinerTheme.gray600,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: TranslinerTheme.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: TranslinerTheme.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TranslinerTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: TranslinerTheme.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: TranslinerTheme.charcoal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: TranslinerTheme.gray600,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        context.go('/login');
      }
    }
  }
}
