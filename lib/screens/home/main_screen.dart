import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/modern_drawer.dart';
import 'home_content.dart';
import '../reports/reports_screen.dart';
import '../trip/parcels_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  DateTime? _lastBackPress;
  bool _isFabOpen = false;

  // Bottom navigation screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeContent(), // Home/Trips
      const HomeContent(), // Bookings (same as home for now)
      const ReportsScreen(), // Reports
      ParcelsManagementScreen(), // Parcels
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: TranslinerTheme.lightGray,
        appBar: _buildModernAppBar(authProvider),
        drawer: const ModernDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: _buildSpeedDialFAB(authProvider),
        bottomNavigationBar: _buildModernBottomNav(user),
      ),
    );
  }

  void _handleBackPress() {
    final router = GoRouter.of(context);

    // Check if we can go back in router history
    if (router.canPop()) {
      router.pop();
      return;
    }

    // If not on home tab, go back to home tab
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    // If on home tab and can't go back, use double-tap-to-exit pattern
    final now = DateTime.now();
    final backPressInterval = _lastBackPress == null
        ? const Duration(seconds: 3)
        : now.difference(_lastBackPress!);

    if (backPressInterval > const Duration(seconds: 2)) {
      // First back press - show message
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: GoogleFonts.montserrat(),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: TranslinerTheme.charcoal,
        ),
      );
    } else {
      // Second back press within 2 seconds - exit app
      _lastBackPress = null;
      // Exit the app
      Navigator.of(context).pop();
    }
  }

  PreferredSizeWidget _buildModernAppBar(AuthProvider authProvider) {
    final user = authProvider.user;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TranslinerTheme.primaryRed,
              TranslinerTheme.primaryRed.withOpacity(0.8),
            ],
          ),
        ),
      ),
      title: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TransLine Cruiser',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Text(
                    settingsProvider.relativeDateString,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (user?.isAdmin == true || user?.isManager == true) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showBackdatingDialog(settingsProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Change',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        // Notifications
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: TranslinerTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No new notifications',
                    style: GoogleFonts.montserrat(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Notifications',
          ),
        ),
        // Profile
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _showProfileDialog,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                user?.initials ?? 'U',
                style: GoogleFonts.montserrat(
                  color: TranslinerTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernBottomNav(user) {
    final items = [
      _BottomNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        canAccess: true,
      ),
      _BottomNavItem(
        icon: Icons.directions_bus_rounded,
        label: 'Trips',
        canAccess: true,
      ),
      _BottomNavItem(
        icon: Icons.analytics_rounded,
        label: 'Reports',
        canAccess: user?.canViewReports ?? false,
      ),
      _BottomNavItem(
        icon: Icons.inventory_2_rounded,
        label: 'Parcels',
        canAccess: true,
      ),
    ];

    // Filter items based on access
    final accessibleItems = <_BottomNavItem>[];
    final indexMap = <int, int>{};

    for (var i = 0; i < items.length; i++) {
      if (items[i].canAccess) {
        indexMap[accessibleItems.length] = i;
        accessibleItems.add(items[i]);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(accessibleItems.length, (index) {
              final item = accessibleItems[index];
              final actualIndex = indexMap[index] ?? index;
              final isSelected = _currentIndex == actualIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = actualIndex;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                TranslinerTheme.primaryRed.withOpacity(0.15),
                                TranslinerTheme.primaryRed.withOpacity(0.05),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? TranslinerTheme.primaryRed
                              : TranslinerTheme.gray500,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? TranslinerTheme.primaryRed
                                : TranslinerTheme.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showBackdatingDialog(AppSettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TranslinerTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: TranslinerTheme.infoBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Select Date',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Admin/Manager can select any date backwards',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: TranslinerTheme.gray600,
                ),
              ),
              const SizedBox(height: 16),
              CalendarDatePicker(
                initialDate: settingsProvider.appDate.isBefore(DateTime(2020))
                    ? DateTime(2020)
                    : (settingsProvider.appDate.isAfter(DateTime.now().add(const Duration(days: 365)))
                        ? DateTime.now()
                        : settingsProvider.appDate),
                firstDate: DateTime(2020), // Can go back to 2020
                lastDate: DateTime.now().add(const Duration(days: 365)),
                currentDate: DateTime.now().add(const Duration(days: 365)), // Allow all past dates to be selectable
                onDateChanged: (date) {
                  settingsProvider.setAppDate(date);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Date changed to ${settingsProvider.appDateForDisplay}',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: TranslinerTheme.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: TranslinerTheme.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: TranslinerTheme.primaryRed.withOpacity(0.1),
              child: Text(
                user?.initials ?? 'U',
                style: GoogleFonts.montserrat(
                  color: TranslinerTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Unknown',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: TranslinerTheme.charcoal,
                    ),
                  ),
                  Text(
                    user?.primaryRole ?? 'User',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: TranslinerTheme.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow(Icons.email_rounded, user?.email ?? 'N/A'),
            _buildProfileRow(
                Icons.phone_rounded, user?.phone ?? 'Not provided'),
            const SizedBox(height: 16),
            Text(
              'Roles',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: TranslinerTheme.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (user?.roles ?? [])
                  .map(
                    (role) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TranslinerTheme.primaryRed.withOpacity(0.1),
                            TranslinerTheme.infoBlue.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TranslinerTheme.primaryRed.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        role.replaceAll('-', ' ').toUpperCase(),
                        style: GoogleFonts.montserrat(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.montserrat(
                color: TranslinerTheme.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: TranslinerTheme.gray600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.gray700,
              ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TranslinerTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: TranslinerTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.montserrat(
            color: TranslinerTheme.gray700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: TranslinerTheme.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
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

  Widget? _buildSpeedDialFAB(AuthProvider authProvider) {
    // Only show on home screen (index 0) and for users who can manage trips
    if (_currentIndex != 0 || !authProvider.canManageTrips) {
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed dial menu items (shown when FAB is expanded)
        if (_isFabOpen) ...[
          // Bulk Create Trips
          _buildSpeedDialItem(
            label: 'Bulk Create Trips',
            icon: Icons.playlist_add_rounded,
            gradient: LinearGradient(
              colors: [
                TranslinerTheme.successGreen,
                TranslinerTheme.successGreen.withOpacity(0.8),
              ],
            ),
            onTap: () {
              setState(() => _isFabOpen = false);
              context.go('/trip/bulk');
            },
          ),
          const SizedBox(height: 12),

          // Create New Trip
          _buildSpeedDialItem(
            label: 'Create New Trip',
            icon: Icons.add_rounded,
            gradient: TranslinerTheme.primaryGradient,
            onTap: () {
              setState(() => _isFabOpen = false);
              context.go('/trip/create');
            },
          ),
          const SizedBox(height: 16),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: () {
            setState(() => _isFabOpen = !_isFabOpen);
          },
          backgroundColor: TranslinerTheme.primaryRed,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isFabOpen ? 0.125 : 0, // Rotate 45 degrees when open
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.charcoal,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final bool canAccess;

  _BottomNavItem({
    required this.icon,
    required this.label,
    required this.canAccess,
  });
}
