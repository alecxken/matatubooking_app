// lib/screens/trip_management/owner_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/owner_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

/// Owner Management Screen
/// Complete CRUD implementation for vehicle owners
/// This serves as a reference implementation for other management screens
class OwnerManagementScreen extends StatefulWidget {
  const OwnerManagementScreen({super.key});

  @override
  State<OwnerManagementScreen> createState() => _OwnerManagementScreenState();
}

class _OwnerManagementScreenState extends State<OwnerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    final provider = context.read<TripManagementProvider>();
    await provider.fetchOwners();
  }

  List<OwnerModel> _getFilteredOwners(List<OwnerModel> owners) {
    return owners.where((owner) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          owner.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          owner.phone.contains(_searchQuery) ||
          (owner.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      // Apply status filter
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && owner.isActive) ||
          (_statusFilter == 'Inactive' && !owner.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showAddEditDialog({OwnerModel? owner}) {
    showDialog(
      context: context,
      builder: (context) => _OwnerFormDialog(owner: owner),
    );
  }

  void _showDeleteConfirmation(OwnerModel owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Owner'),
        content: Text(
          'Are you sure you want to delete ${owner.fullName}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteOwner(owner);
            },
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOwner(OwnerModel owner) async {
    final provider = context.read<TripManagementProvider>();
    final success = await provider.deleteOwner(owner.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Owner deleted successfully'
                : 'Failed to delete owner: ${provider.ownersError}',
          ),
          backgroundColor:
              success ? TranslinerTheme.successGreen : TranslinerTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Owner Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOwners,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: TranslinerSpacing.pagePadding,
            color: TranslinerTheme.white,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, phone, or email',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                TranslinerSpacing.verticalSpaceSM,

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      TranslinerSpacing.horizontalSpaceSM,
                      _buildFilterChip('Active'),
                      TranslinerSpacing.horizontalSpaceSM,
                      _buildFilterChip('Inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Owners List
          Expanded(
            child: Consumer<TripManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingOwners) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.ownersError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: TranslinerTheme.errorRed,
                        ),
                        TranslinerSpacing.verticalSpaceMD,
                        Text(
                          'Error loading owners',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TranslinerSpacing.verticalSpaceSM,
                        Text(
                          provider.ownersError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TranslinerSpacing.verticalSpaceMD,
                        FilledButton.icon(
                          onPressed: _loadOwners,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredOwners = _getFilteredOwners(provider.owners);

                if (filteredOwners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.person_add_outlined,
                          size: 64,
                          color: TranslinerTheme.gray400,
                        ),
                        TranslinerSpacing.verticalSpaceMD,
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No owners found'
                              : 'No owners yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TranslinerSpacing.verticalSpaceSM,
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try adjusting your search or filters'
                              : 'Add your first vehicle owner to get started',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_searchQuery.isEmpty) ...[
                          TranslinerSpacing.verticalSpaceMD,
                          FilledButton.icon(
                            onPressed: () => _showAddEditDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Owner'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadOwners,
                  child: ListView.separated(
                    padding: TranslinerSpacing.pagePadding,
                    itemCount: filteredOwners.length,
                    separatorBuilder: (context, index) =>
                        TranslinerSpacing.verticalSpaceMD,
                    itemBuilder: (context, index) {
                      final owner = filteredOwners[index];
                      return _OwnerCard(
                        owner: owner,
                        onEdit: () => _showAddEditDialog(owner: owner),
                        onDelete: () => _showDeleteConfirmation(owner),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Owner'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _statusFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = label;
        });
      },
      selectedColor: TranslinerTheme.primaryContainer,
      checkmarkColor: TranslinerTheme.primaryRed,
    );
  }
}

// ============================================================================
// OWNER CARD WIDGET
// ============================================================================

class _OwnerCard extends StatelessWidget {
  final OwnerModel owner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OwnerCard({
    required this.owner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: TranslinerRadius.borderLG,
        child: Padding(
          padding: TranslinerSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: TranslinerTheme.primaryContainer,
                    child: Text(
                      owner.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: TranslinerTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TranslinerSpacing.horizontalSpaceMD,

                  // Owner Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TranslinerSpacing.verticalSpaceXS,
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: TranslinerTheme.gray600,
                            ),
                            TranslinerSpacing.horizontalSpaceXS,
                            Text(
                              owner.phone,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (owner.email != null) ...[
                          TranslinerSpacing.verticalSpaceXS,
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: TranslinerTheme.gray600,
                              ),
                              TranslinerSpacing.horizontalSpaceXS,
                              Expanded(
                                child: Text(
                                  owner.email!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: owner.isActive
                          ? TranslinerTheme.successContainer
                          : TranslinerTheme.gray200,
                      borderRadius: TranslinerRadius.borderSM,
                    ),
                    child: Text(
                      owner.status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: owner.isActive
                                ? TranslinerTheme.successGreen
                                : TranslinerTheme.gray600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              // Actions
              TranslinerSpacing.verticalSpaceSM,
              const Divider(),
              TranslinerSpacing.verticalSpaceXS,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  TranslinerSpacing.horizontalSpaceSM,
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: TranslinerTheme.errorRed,
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
}

// ============================================================================
// OWNER FORM DIALOG
// ============================================================================

class _OwnerFormDialog extends StatefulWidget {
  final OwnerModel? owner;

  const _OwnerFormDialog({this.owner});

  @override
  State<_OwnerFormDialog> createState() => _OwnerFormDialogState();
}

class _OwnerFormDialogState extends State<_OwnerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _otherNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late String _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.owner?.firstName ?? '');
    _otherNameController =
        TextEditingController(text: widget.owner?.otherName ?? '');
    _phoneController = TextEditingController(text: widget.owner?.phone ?? '');
    _emailController = TextEditingController(text: widget.owner?.email ?? '');
    _status = widget.owner?.status ?? 'Active';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _otherNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveOwner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final owner = OwnerModel(
      id: widget.owner?.id,
      firstName: _firstNameController.text.trim(),
      otherName: _otherNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      status: _status,
    );

    final provider = context.read<TripManagementProvider>();
    final bool success;

    if (widget.owner == null) {
      final result = await provider.createOwner(owner);
      success = result != null;
    } else {
      success = await provider.updateOwner(widget.owner!.id!, owner);
    }

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.owner == null
                  ? 'Owner created successfully'
                  : 'Owner updated successfully',
            ),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.ownersError}'),
            backgroundColor: TranslinerTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.owner == null ? 'Add Owner' : 'Edit Owner'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter first name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              TranslinerSpacing.verticalSpaceMD,
              TextFormField(
                controller: _otherNameController,
                decoration: const InputDecoration(
                  labelText: 'Other Name',
                  hintText: 'Enter other name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Other name is required';
                  }
                  return null;
                },
              ),
              TranslinerSpacing.verticalSpaceMD,
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+254700000000',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              TranslinerSpacing.verticalSpaceMD,
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'owner@example.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      !value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              TranslinerSpacing.verticalSpaceMD,
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                ),
                items: ['Active', 'Inactive']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveOwner,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.owner == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
