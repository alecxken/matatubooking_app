import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/route_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

class RoutesManagementScreen extends StatefulWidget {
  const RoutesManagementScreen({super.key});

  @override
  State<RoutesManagementScreen> createState() => _RoutesManagementScreenState();
}

class _RoutesManagementScreenState extends State<RoutesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TripManagementProvider>().fetchRoutes();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<RouteModel> _getFilteredRoutes(List<RouteModel> routes) {
    if (_searchQuery.isEmpty) return routes;

    return routes.where((route) {
      return route.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (route.direction?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Routes Management',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildRoutesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRouteDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Route',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TranslinerTheme.primaryRed,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search routes...',
          hintStyle: GoogleFonts.montserrat(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: TranslinerTheme.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: TranslinerTheme.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TranslinerTheme.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRoutesList() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        if (_isLoading && provider.routes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final filteredRoutes = _getFilteredRoutes(provider.routes);

        if (filteredRoutes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.route : Icons.search_off,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No routes found'
                      : 'No routes match your search',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: TranslinerTheme.gray600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first route',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: TranslinerTheme.gray500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadRoutes,
          color: TranslinerTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRoutes.length,
            itemBuilder: (context, index) {
              final route = filteredRoutes[index];
              return _buildRouteCard(route);
            },
          ),
        );
      },
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TranslinerTheme.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRouteDialog(route: route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TranslinerTheme.infoBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: TranslinerTheme.infoBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.charcoal,
                          ),
                        ),
                        if (route.direction != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            route.direction!,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: TranslinerTheme.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: route.isActive
                          ? TranslinerTheme.successGreen.withOpacity(0.1)
                          : TranslinerTheme.gray300,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: route.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray400,
                      ),
                    ),
                    child: Text(
                      route.status,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: route.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: TranslinerTheme.gray600),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showRouteDialog(route: route);
                      } else if (value == 'delete') {
                        _confirmDelete(route);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20, color: TranslinerTheme.infoBlue),
                            const SizedBox(width: 8),
                            Text('Edit', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: TranslinerTheme.errorRed),
                            const SizedBox(width: 8),
                            Text('Delete', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (route.subroutes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: TranslinerTheme.gray600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${route.subrouteCount} subroute${route.subrouteCount != 1 ? 's' : ''}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: TranslinerTheme.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...route.subroutes.take(3).map((subroute) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const SizedBox(width: 22),
                          Icon(
                            Icons.subdirectory_arrow_right,
                            size: 14,
                            color: TranslinerTheme.gray500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              subroute.displayName,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: TranslinerTheme.gray700,
                              ),
                            ),
                          ),
                          Text(
                            'KES ${subroute.fare.toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TranslinerTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (route.subrouteCount > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 4),
                    child: Text(
                      '+ ${route.subrouteCount - 3} more',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: TranslinerTheme.gray500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRouteDialog({RouteModel? route}) {
    final isEditing = route != null;
    final nameController = TextEditingController(text: route?.name ?? '');
    final directionController = TextEditingController(text: route?.direction ?? '');
    String selectedStatus = route?.status ?? 'Active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                child: Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: TranslinerTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEditing ? 'Edit Route' : 'Add New Route',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: TranslinerTheme.charcoal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Route Name *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Nairobi - Mombasa',
                      hintStyle: GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.route),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: directionController,
                    decoration: InputDecoration(
                      labelText: 'Direction (Optional)',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Northbound, Southbound',
                      hintStyle: GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.arrow_forward),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.montserrat(),
                      prefixIcon: const Icon(Icons.toggle_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Active', 'Inactive'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status, style: GoogleFonts.montserrat()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: TranslinerTheme.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter route name',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: TranslinerTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final newRoute = RouteModel(
                  id: route?.id,
                  token: route?.token,
                  name: nameController.text.trim(),
                  direction: directionController.text.trim().isNotEmpty
                      ? directionController.text.trim()
                      : null,
                  status: selectedStatus,
                  subroutes: route?.subroutes ?? [],
                );

                Navigator.of(context).pop();

                final provider = context.read<TripManagementProvider>();
                bool success;

                if (isEditing) {
                  success = await provider.updateRoute(route.id!, newRoute);
                } else {
                  final created = await provider.createRoute(newRoute);
                  success = created != null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEditing
                                ? 'Route updated successfully'
                                : 'Route created successfully'
                            : 'Failed to ${isEditing ? 'update' : 'create'} route',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: success
                          ? TranslinerTheme.successGreen
                          : TranslinerTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: TranslinerTheme.infoBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update' : 'Create',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(RouteModel route) async {
    final confirmed = await showDialog<bool>(
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
                Icons.warning_rounded,
                color: TranslinerTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Route',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${route.name}"? This action cannot be undone.',
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
              'Delete',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TripManagementProvider>().deleteRoute(route.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Route deleted successfully' : 'Failed to delete route',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: success
                ? TranslinerTheme.successGreen
                : TranslinerTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
