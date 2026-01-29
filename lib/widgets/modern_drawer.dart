// lib/widgets/modern_drawer.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/transliner_theme.dart';

/// Modern Glassy Futuristic Drawer
/// Features:
/// - Glassmorphism design
/// - Montserrat font
/// - Role-based menu items
/// - Smooth animations
/// - Elegant gradients
class ModernDrawer extends StatefulWidget {
  const ModernDrawer({super.key});

  @override
  State<ModernDrawer> createState() => _ModernDrawerState();
}

class _ModernDrawerState extends State<ModernDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final menuItems = _getMenuItemsForRole(authProvider);

        return Drawer(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TranslinerTheme.primaryRed.withOpacity(0.05),
                  TranslinerTheme.infoBlue.withOpacity(0.05),
                  TranslinerTheme.primaryRed.withOpacity(0.03),
                ],
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildModernHeader(user, authProvider),
                        const SizedBox(height: 16),
                        ...menuItems.map((item) => _buildMenuItem(item)),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(user, AuthProvider authProvider) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: TranslinerTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: TranslinerTheme.primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar with glassmorphic effect
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            user?.initials ?? 'U',
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  user?.displayName ?? 'Unknown User',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    user?.primaryRole?.toUpperCase() ?? 'USER',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item) {
    if (item.children.isNotEmpty) {
      return _buildExpandableMenuItem(item);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: item.isSelected
                  ? TranslinerTheme.primaryRed.withOpacity(0.15)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isSelected
                    ? TranslinerTheme.primaryRed.withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.isSelected
                        ? TranslinerTheme.primaryRed.withOpacity(0.2)
                        : item.iconColor?.withOpacity(0.1) ??
                            TranslinerTheme.gray600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isSelected
                        ? TranslinerTheme.primaryRed
                        : item.iconColor ?? TranslinerTheme.charcoal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: item.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: item.isSelected
                          ? TranslinerTheme.primaryRed
                          : item.titleColor ?? TranslinerTheme.charcoal,
                    ),
                  ),
                ),
                if (item.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TranslinerTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.badge!,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem(DrawerMenuItem item) {
    final isExpanded = _expandedSection == item.title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedSection = isExpanded ? null : item.title;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isExpanded
                      ? TranslinerTheme.primaryRed.withOpacity(0.1)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? TranslinerTheme.primaryRed.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? TranslinerTheme.primaryRed.withOpacity(0.2)
                            : item.iconColor?.withOpacity(0.1) ??
                                TranslinerTheme.gray600.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: isExpanded
                            ? TranslinerTheme.primaryRed
                            : item.iconColor ?? TranslinerTheme.charcoal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: isExpanded
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isExpanded
                              ? TranslinerTheme.primaryRed
                              : TranslinerTheme.charcoal,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isExpanded
                          ? TranslinerTheme.primaryRed
                          : TranslinerTheme.gray600,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Submenu items
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(left: 20, top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: item.children.map((child) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: child.onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: child.isSelected
                              ? TranslinerTheme.primaryRed.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              child.icon,
                              size: 18,
                              color: child.isSelected
                                  ? TranslinerTheme.primaryRed
                                  : TranslinerTheme.gray600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                child.title,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: child.isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: child.isSelected
                                      ? TranslinerTheme.primaryRed
                                      : TranslinerTheme.gray600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TransLine Cruiser',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0 • by TenzaTech',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: TranslinerTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  List<DrawerMenuItem> _getMenuItemsForRole(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return [];

    // Use UserModel's built-in role helpers for more reliable checking
    final isAdmin = user.isAdmin;
    final isManager = user.isManager;
    final isSupervisor = user.hasAnyRole(['supervisor', 'admin', 'super-admin']);
    final isClerk = user.hasAnyRole(['clerk', 'booking-agent', 'operator']);
    final isOwner = user.hasRole('owner');

    // Debug print to check roles
    debugPrint('ModernDrawer - User roles: ${user.roles}');
    debugPrint('ModernDrawer - isAdmin: $isAdmin, isManager: $isManager');

    List<DrawerMenuItem> items = [];

    // Dashboard / Home (Everyone)
    items.add(DrawerMenuItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      onTap: () {
        Navigator.pop(context);
      },
      isSelected: true,
    ));

    // Trips (Everyone)
    items.add(DrawerMenuItem(
      icon: Icons.directions_bus_rounded,
      title: 'Trips',
      onTap: () {
        Navigator.pop(context);
      },
    ));

    // Reports (Admin, Manager, Supervisor, Owner)
    if (isAdmin || isManager || isSupervisor || isOwner) {
      items.add(DrawerMenuItem(
        icon: Icons.analytics_rounded,
        title: 'Reports',
        iconColor: TranslinerTheme.infoBlue,
        onTap: () {
          Navigator.pop(context);
          context.go('/reports');
        },
      ));
    }

    // Parcels (Everyone can view, Clerk/Manager can manage)
    items.add(DrawerMenuItem(
      icon: Icons.inventory_2_rounded,
      title: 'Parcels',
      iconColor: TranslinerTheme.warningYellow,
      onTap: () {
        Navigator.pop(context);
        context.go('/parcels');
      },
    ));

    // Trip Management (Admin, Manager, Supervisor)
    if (isAdmin || isManager || isSupervisor) {
      items.add(DrawerMenuItem(
        icon: Icons.settings_applications_rounded,
        title: 'Trip Management',
        iconColor: TranslinerTheme.primaryRed,
        children: [
          DrawerMenuItem(
            icon: Icons.route_rounded,
            title: 'Routes',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/routes');
            },
          ),
          DrawerMenuItem(
            icon: Icons.location_on_rounded,
            title: 'Destinations',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/destinations');
            },
          ),
          if (isAdmin || isManager) ...[
            DrawerMenuItem(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Expense Types',
              onTap: () {
                Navigator.pop(context);
                context.go('/operations/expenses');
              },
            ),
          ],
        ],
      ));
    }

    // Fleet Management (Admin, Manager)
    if (isAdmin || isManager) {
      items.add(DrawerMenuItem(
        icon: Icons.local_shipping_rounded,
        title: 'Fleet',
        children: [
          DrawerMenuItem(
            icon: Icons.directions_bus_filled_rounded,
            title: 'Vehicles',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/vehicles');
            },
          ),
          DrawerMenuItem(
            icon: Icons.person_rounded,
            title: 'Drivers',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/drivers');
            },
          ),
        ],
      ));
    }

    // Administration (Admin only)
    if (isAdmin) {
      items.add(DrawerMenuItem(
        icon: Icons.admin_panel_settings_rounded,
        title: 'Administration',
        iconColor: TranslinerTheme.errorRed,
        children: [
          DrawerMenuItem(
            icon: Icons.business_rounded,
            title: 'Owners',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/owners');
            },
          ),
          DrawerMenuItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Expense Types',
            onTap: () {
              Navigator.pop(context);
              context.go('/operations/expenses');
            },
          ),
          DrawerMenuItem(
            icon: Icons.people_rounded,
            title: 'Users',
            onTap: () {
              Navigator.pop(context);
              // TODO: Add users management screen
            },
          ),
        ],
      ));
    }

    // Divider
    items.add(DrawerMenuItem(
      icon: Icons.settings_rounded,
      title: 'Settings',
      onTap: () {
        Navigator.pop(context);
        context.go('/settings');
      },
    ));

    // Logout
    items.add(DrawerMenuItem(
      icon: Icons.logout_rounded,
      title: 'Logout',
      titleColor: TranslinerTheme.errorRed,
      iconColor: TranslinerTheme.errorRed,
      onTap: () => _handleLogout(),
    ));

    return items;
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
            ),
            child: Text('Logout', style: GoogleFonts.montserrat()),
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

/// Drawer Menu Item Model
class DrawerMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? iconColor;
  final Color? titleColor;
  final String? badge;
  final List<DrawerMenuItem> children;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.isSelected = false,
    this.iconColor,
    this.titleColor,
    this.badge,
    this.children = const [],
  });
}
