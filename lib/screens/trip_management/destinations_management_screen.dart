import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/destination_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

class DestinationsManagementScreen extends StatefulWidget {
  const DestinationsManagementScreen({super.key});

  @override
  State<DestinationsManagementScreen> createState() =>
      _DestinationsManagementScreenState();
}

class _DestinationsManagementScreenState
    extends State<DestinationsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TripManagementProvider>().fetchDestinations();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DestinationModel> _getFilteredDestinations(
      List<DestinationModel> destinations) {
    if (_searchQuery.isEmpty) return destinations;

    return destinations.where((destination) {
      return destination.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Destinations Management',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDestinations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildDestinationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDestinationDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Destination',
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
          hintText: 'Search destinations...',
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
            borderSide: const BorderSide(
                color: TranslinerTheme.primaryRed, width: 2),
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

  Widget _buildDestinationsList() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        if (_isLoading && provider.destinations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final filteredDestinations =
            _getFilteredDestinations(provider.destinations);

        if (filteredDestinations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.location_on : Icons.search_off,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No destinations found'
                      : 'No destinations match your search',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: TranslinerTheme.gray600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first destination',
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
          onRefresh: _loadDestinations,
          color: TranslinerTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDestinations.length,
            itemBuilder: (context, index) {
              final destination = filteredDestinations[index];
              return _buildDestinationCard(destination);
            },
          ),
        );
      },
    );
  }

  Widget _buildDestinationCard(DestinationModel destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TranslinerTheme.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDestinationDialog(destination: destination),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TranslinerTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: TranslinerTheme.infoBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: destination.isActive
                      ? TranslinerTheme.successGreen.withOpacity(0.1)
                      : TranslinerTheme.gray300,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: destination.isActive
                        ? TranslinerTheme.successGreen
                        : TranslinerTheme.gray400,
                  ),
                ),
                child: Text(
                  destination.status,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: destination.isActive
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
                    _showDestinationDialog(destination: destination);
                  } else if (value == 'delete') {
                    _confirmDelete(destination);
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
        ),
      ),
    );
  }

  void _showDestinationDialog({DestinationModel? destination}) {
    final isEditing = destination != null;
    final nameController = TextEditingController(text: destination?.name ?? '');
    String selectedStatus = destination?.status ?? 'Active';

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
                isEditing ? 'Edit Destination' : 'Add New Destination',
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
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Destination Name *',
                    labelStyle: GoogleFonts.montserrat(),
                    hintText: 'e.g., Nairobi, Mombasa, Kisumu',
                    hintStyle: GoogleFonts.montserrat(
                        color: TranslinerTheme.gray400),
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
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
                        'Please enter destination name',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: TranslinerTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final newDestination = DestinationModel(
                  id: destination?.id,
                  token: destination?.token,
                  name: nameController.text.trim(),
                  status: selectedStatus,
                );

                Navigator.of(context).pop();

                final provider = context.read<TripManagementProvider>();
                bool success;

                if (isEditing) {
                  success = await provider.updateDestination(
                      destination.id!, newDestination);
                } else {
                  final created = await provider.createDestination(newDestination);
                  success = created != null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEditing
                                ? 'Destination updated successfully'
                                : 'Destination created successfully'
                            : 'Failed to ${isEditing ? 'update' : 'create'} destination',
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

  Future<void> _confirmDelete(DestinationModel destination) async {
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
              'Delete Destination',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${destination.name}"? This action cannot be undone.',
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
      final success = await context
          .read<TripManagementProvider>()
          .deleteDestination(destination.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Destination deleted successfully'
                  : 'Failed to delete destination',
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
