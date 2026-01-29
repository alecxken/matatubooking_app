import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/driver_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

class DriversManagementScreen extends StatefulWidget {
  const DriversManagementScreen({super.key});

  @override
  State<DriversManagementScreen> createState() =>
      _DriversManagementScreenState();
}

class _DriversManagementScreenState extends State<DriversManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TripManagementProvider>().fetchDrivers();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DriverModel> _getFilteredDrivers(List<DriverModel> drivers) {
    if (_searchQuery.isEmpty) return drivers;

    return drivers.where((driver) {
      return driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.phone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (driver.idNo?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Drivers Management',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrivers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildDriversList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDriverDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Driver',
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
          hintText: 'Search drivers...',
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
            borderSide:
                const BorderSide(color: TranslinerTheme.primaryRed, width: 2),
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

  Widget _buildDriversList() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        if (_isLoading && provider.drivers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final filteredDrivers = _getFilteredDrivers(provider.drivers);

        if (filteredDrivers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.person : Icons.search_off,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No drivers found'
                      : 'No drivers match your search',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: TranslinerTheme.gray600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first driver',
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
          onRefresh: _loadDrivers,
          color: TranslinerTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDrivers.length,
            itemBuilder: (context, index) {
              final driver = filteredDrivers[index];
              return _buildDriverCard(driver);
            },
          ),
        );
      },
    );
  }

  Widget _buildDriverCard(DriverModel driver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TranslinerTheme.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDriverDialog(driver: driver),
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
                      Icons.person_rounded,
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
                          driver.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 12,
                              color: TranslinerTheme.gray600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver.phone,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: TranslinerTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: driver.isActive
                          ? TranslinerTheme.successGreen.withOpacity(0.1)
                          : TranslinerTheme.gray300,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: driver.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray400,
                      ),
                    ),
                    child: Text(
                      driver.status,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: driver.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: TranslinerTheme.gray600),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showDriverDialog(driver: driver);
                      } else if (value == 'delete') {
                        _confirmDelete(driver);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit,
                                size: 20, color: TranslinerTheme.infoBlue),
                            const SizedBox(width: 8),
                            Text('Edit', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 20, color: TranslinerTheme.errorRed),
                            const SizedBox(width: 8),
                            Text('Delete', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (driver.idNo != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 14,
                      color: TranslinerTheme.gray600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ID: ${driver.idNo}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: TranslinerTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDialog({DriverModel? driver}) {
    final isEditing = driver != null;
    final firstNameController =
        TextEditingController(text: driver?.firstName ?? '');
    final otherNameController =
        TextEditingController(text: driver?.otherName ?? '');
    final phoneController = TextEditingController(text: driver?.phone ?? '');
    final idNoController = TextEditingController(text: driver?.idNo ?? '');
    String selectedStatus = driver?.status ?? 'Active';

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
              Expanded(
                child: Text(
                  isEditing ? 'Edit Driver' : 'Add New Driver',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
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
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., John',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otherNameController,
                    decoration: InputDecoration(
                      labelText: 'Other Names *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Doe Smith',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., 0712345678',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: idNoController,
                    decoration: InputDecoration(
                      labelText: 'ID Number (Optional)',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., 12345678',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                // Validation
                if (firstNameController.text.trim().isEmpty) {
                  _showError(context, 'Please enter first name');
                  return;
                }
                if (otherNameController.text.trim().isEmpty) {
                  _showError(context, 'Please enter other names');
                  return;
                }
                if (phoneController.text.trim().isEmpty) {
                  _showError(context, 'Please enter phone number');
                  return;
                }

                final newDriver = DriverModel(
                  id: driver?.id,
                  token: driver?.token,
                  firstName: firstNameController.text.trim(),
                  otherName: otherNameController.text.trim(),
                  phone: phoneController.text.trim(),
                  idNo: idNoController.text.trim().isNotEmpty
                      ? idNoController.text.trim()
                      : null,
                  status: selectedStatus,
                );

                Navigator.of(context).pop();

                final provider = context.read<TripManagementProvider>();
                bool success;

                if (isEditing) {
                  success = await provider.updateDriver(driver.id!, newDriver);
                } else {
                  final created = await provider.createDriver(newDriver);
                  success = created != null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEditing
                                ? 'Driver updated successfully'
                                : 'Driver created successfully'
                            : 'Failed to ${isEditing ? 'update' : 'create'} driver',
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: TranslinerTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(DriverModel driver) async {
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
              'Delete Driver',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete driver "${driver.name}"? This action cannot be undone.',
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
      final success =
          await context.read<TripManagementProvider>().deleteDriver(driver.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Driver deleted successfully'
                  : 'Failed to delete driver',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor:
                success ? TranslinerTheme.successGreen : TranslinerTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
