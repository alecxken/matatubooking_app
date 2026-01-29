import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/vehicle_model.dart';
import '../../models/owner_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

class VehiclesManagementScreen extends StatefulWidget {
  const VehiclesManagementScreen({super.key});

  @override
  State<VehiclesManagementScreen> createState() =>
      _VehiclesManagementScreenState();
}

class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<TripManagementProvider>();
      await Future.wait([
        provider.fetchVehicles(),
        provider.fetchOwners(), // Need owners for dropdown
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<VehicleModel> _getFilteredVehicles(List<VehicleModel> vehicles) {
    if (_searchQuery.isEmpty) return vehicles;

    return vehicles.where((vehicle) {
      return vehicle.regNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.vehicleType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.vehicleOwner.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Vehicles Management',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildVehiclesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVehicleDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Vehicle',
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
          hintText: 'Search vehicles...',
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

  Widget _buildVehiclesList() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        if (_isLoading && provider.vehicles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final filteredVehicles = _getFilteredVehicles(provider.vehicles);

        if (filteredVehicles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.directions_bus : Icons.search_off,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No vehicles found'
                      : 'No vehicles match your search',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: TranslinerTheme.gray600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first vehicle',
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
          onRefresh: _loadData,
          color: TranslinerTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = filteredVehicles[index];
              return _buildVehicleCard(vehicle);
            },
          ),
        );
      },
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TranslinerTheme.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showVehicleDialog(vehicle: vehicle),
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
                      Icons.directions_bus_rounded,
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
                          vehicle.regNo,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicle.vehicleType,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: TranslinerTheme.gray600,
                          ),
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
                      color: vehicle.isActive
                          ? TranslinerTheme.successGreen.withOpacity(0.1)
                          : TranslinerTheme.gray300,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: vehicle.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray400,
                      ),
                    ),
                    child: Text(
                      vehicle.status,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: vehicle.isActive
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
                        _showVehicleDialog(vehicle: vehicle);
                      } else if (value == 'delete') {
                        _confirmDelete(vehicle);
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
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.event_seat,
                    '${vehicle.seats} seats',
                    TranslinerTheme.infoBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person_outline,
                      vehicle.vehicleOwner,
                      TranslinerTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleDialog({VehicleModel? vehicle}) {
    final isEditing = vehicle != null;
    final regNoController = TextEditingController(text: vehicle?.regNo ?? '');
    final vehicleTypeController = TextEditingController(text: vehicle?.vehicleType ?? '');
    final seatsController = TextEditingController(text: vehicle?.seats.toString() ?? '');
    String selectedStatus = vehicle?.status ?? 'Active';
    String? selectedOwner = vehicle?.vehicleOwner;

    final provider = context.read<TripManagementProvider>();
    final owners = provider.owners;

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
                  isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
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
                    controller: regNoController,
                    decoration: InputDecoration(
                      labelText: 'Registration Number *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., KBZ 123A',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vehicleTypeController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Type *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Bus, Minibus, Van',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: seatsController,
                    decoration: InputDecoration(
                      labelText: 'Number of Seats *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., 14, 33, 51',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.event_seat),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  if (owners.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TranslinerTheme.warningYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TranslinerTheme.warningYellow,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: TranslinerTheme.warningYellow),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No owners found. Please add owners first.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: TranslinerTheme.charcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedOwner,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Owner *',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: Text('Select owner',
                          style: GoogleFonts.montserrat()),
                      items: owners.map((owner) {
                        return DropdownMenuItem<String>(
                          value: owner.fullName,
                          child: Text(owner.fullName,
                              style: GoogleFonts.montserrat()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedOwner = value;
                        });
                      },
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
                if (regNoController.text.trim().isEmpty) {
                  _showError(context, 'Please enter registration number');
                  return;
                }
                if (vehicleTypeController.text.trim().isEmpty) {
                  _showError(context, 'Please enter vehicle type');
                  return;
                }
                if (seatsController.text.trim().isEmpty) {
                  _showError(context, 'Please enter number of seats');
                  return;
                }
                if (selectedOwner == null || selectedOwner!.isEmpty) {
                  _showError(context, 'Please select vehicle owner');
                  return;
                }

                final seats = int.tryParse(seatsController.text.trim());
                if (seats == null || seats <= 0) {
                  _showError(context, 'Please enter valid number of seats');
                  return;
                }

                final newVehicle = VehicleModel(
                  id: vehicle?.id,
                  token: vehicle?.token,
                  regNo: regNoController.text.trim().toUpperCase(),
                  vehicleType: vehicleTypeController.text.trim(),
                  vehicleOwner: selectedOwner!,
                  seats: seats,
                  status: selectedStatus,
                );

                Navigator.of(context).pop();

                final provider = context.read<TripManagementProvider>();
                bool success;

                if (isEditing) {
                  success = await provider.updateVehicle(vehicle.id!, newVehicle);
                } else {
                  final created = await provider.createVehicle(newVehicle);
                  success = created != null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEditing
                                ? 'Vehicle updated successfully'
                                : 'Vehicle created successfully'
                            : 'Failed to ${isEditing ? 'update' : 'create'} vehicle',
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

  Future<void> _confirmDelete(VehicleModel vehicle) async {
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
              'Delete Vehicle',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete vehicle "${vehicle.regNo}"? This action cannot be undone.',
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
          await context.read<TripManagementProvider>().deleteVehicle(vehicle.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Vehicle deleted successfully'
                  : 'Failed to delete vehicle',
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
