import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/transliner_theme.dart';
import '../../services/api_service.dart';
import 'parcel_print_screen.dart';

class ParcelsManagementScreen extends StatefulWidget {
  final String? tripToken;

  const ParcelsManagementScreen({super.key, this.tripToken});

  @override
  State<ParcelsManagementScreen> createState() =>
      _ParcelsManagementScreenState();
}

class _ParcelsManagementScreenState extends State<ParcelsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> parcels = [];
  List<Map<String, dynamic>> destinations = [];
  bool isLoading = true;
  bool isLoadingParcels = false;
  bool isLoadingDestinations = false;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([_loadParcels(), _loadDestinations()]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadParcels() async {
    if (isLoadingParcels) return; // Prevent duplicate calls

    setState(() => isLoadingParcels = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getParcels(
        status: selectedStatus == 'all' ? null : selectedStatus,
      );

      if (response['success'] && mounted) {
        setState(() {
          parcels = List<Map<String, dynamic>>.from(
            response['data']['data'] ?? [],
          );
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load parcels: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingParcels = false);
      }
    }
  }

  Future<void> _loadDestinations() async {
    if (isLoadingDestinations) return; // Prevent duplicate calls

    setState(() => isLoadingDestinations = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getParcelDestinations();

      if (response['success'] && mounted) {
        setState(() {
          destinations = List<Map<String, dynamic>>.from(
            response['data'] ?? [],
          );
        });
      }
    } catch (e) {
      print('Failed to load destinations: $e');
      // Don't show error for destinations as it's not critical
    } finally {
      if (mounted) {
        setState(() => isLoadingDestinations = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text('Parcel Management'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddParcelDialog(),
            tooltip: 'Add Parcel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'All Parcels', icon: Icon(Icons.inventory_2, size: 20)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics, size: 20)),
          ],
        ),
      ),
      body: isLoading
          ? _buildLoading()
          : TabBarView(
              controller: _tabController,
              children: [_buildParcelsTab(), _buildStatsTab()],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddParcelDialog(),
        backgroundColor: TranslinerTheme.primaryRed,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('New Parcel', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TranslinerTheme.primaryRed),
          SizedBox(height: 16),
          Text('Loading parcels...'),
        ],
      ),
    );
  }

  Widget _buildParcelsTab() {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(child: _buildParcelsList()),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: TranslinerDecorations.premiumCard,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: TranslinerTheme.primaryRed),
              SizedBox(width: 8),
              Text(
                'Filter Parcels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TranslinerTheme.charcoal,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                SizedBox(width: 8),
                _buildFilterChip('In Transit', 'in_transit'),
                SizedBox(width: 8),
                _buildFilterChip('Received', 'received'),
                SizedBox(width: 8),
                _buildFilterChip('Collected', 'collected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => selectedStatus = value);
        _loadParcels();
      },
      selectedColor: TranslinerTheme.primaryRed.withOpacity(0.2),
      checkmarkColor: TranslinerTheme.primaryRed,
      labelStyle: TextStyle(
        color: isSelected
            ? TranslinerTheme.primaryRed
            : TranslinerTheme.gray600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildParcelsList() {
    if (parcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: TranslinerTheme.gray400,
            ),
            SizedBox(height: 16),
            Text(
              'No parcels found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first parcel to get started',
              style: TextStyle(color: TranslinerTheme.gray600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: parcels.length,
      itemBuilder: (context, index) {
        final parcel = parcels[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: TranslinerDecorations.premiumCard,
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(parcel['status']),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory_2, color: Colors.white, size: 20),
            ),
            title: Text(
              parcel['parcel_id'] ?? 'Unknown ID',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: ${parcel['sender_name'] ?? 'Unknown'}'),
                Text('To: ${parcel['recipient_name'] ?? 'Unknown'}'),
                Text('Destination: ${parcel['destination'] ?? 'Unknown'}'),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(parcel['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(parcel['status']).withOpacity(0.3),
                ),
              ),
              child: Text(
                _formatStatus(parcel['status']),
                style: TextStyle(
                  color: _getStatusColor(parcel['status']),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParcelDetail('Type', parcel['parcel_type']),
                    _buildParcelDetail('Value', 'KES ${parcel['value'] ?? 0}'),
                    _buildParcelDetail('Fee', 'KES ${parcel['fee'] ?? 0}'),
                    _buildParcelDetail('Payment', parcel['payment_method']),
                    if (parcel['description'] != null &&
                        parcel['description'].toString().isNotEmpty)
                      _buildParcelDetail('Description', parcel['description']),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _updateParcelStatus(parcel),
                          icon: Icon(Icons.update, size: 16),
                          label: Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TranslinerTheme.infoBlue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(80, 32),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _printParcelLabel(parcel),
                          icon: Icon(Icons.print, size: 16),
                          label: Text('Print'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TranslinerTheme.successGreen,
                            foregroundColor: Colors.white,
                            minimumSize: Size(80, 32),
                          ),
                        ),
                        if (parcel['status'] == 'pending')
                          ElevatedButton.icon(
                            onPressed: () => _deleteParcel(parcel['id']),
                            icon: Icon(Icons.delete, size: 16),
                            label: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TranslinerTheme.errorRed,
                              foregroundColor: Colors.white,
                              minimumSize: Size(80, 32),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParcelDetail(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: TranslinerTheme.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(color: TranslinerTheme.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = _calculateStats();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsCard(
            'Total Parcels',
            stats['total'].toString(),
            Icons.inventory_2,
            TranslinerTheme.primaryRed,
          ),
          SizedBox(height: 12),
          _buildStatsCard(
            'Pending',
            stats['pending'].toString(),
            Icons.schedule,
            TranslinerTheme.warningYellow,
          ),
          SizedBox(height: 12),
          _buildStatsCard(
            'In Transit',
            stats['in_transit'].toString(),
            Icons.local_shipping,
            TranslinerTheme.infoBlue,
          ),
          SizedBox(height: 12),
          _buildStatsCard(
            'Delivered',
            stats['delivered'].toString(),
            Icons.check_circle,
            TranslinerTheme.successGreen,
          ),
          SizedBox(height: 12),
          _buildStatsCard(
            'Total Revenue',
            'KES ${stats['revenue']}',
            Icons.monetization_on,
            TranslinerTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TranslinerTheme.gray600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final total = parcels.length;
    final pending = parcels.where((p) => p['status'] == 'pending').length;
    final inTransit = parcels.where((p) => p['status'] == 'in_transit').length;
    final delivered = parcels
        .where((p) => ['received', 'collected'].contains(p['status']))
        .length;
    final revenue = parcels.fold<double>(
      0,
      (sum, p) => sum + (double.tryParse(p['fee']?.toString() ?? '0') ?? 0),
    );

    return {
      'total': total,
      'pending': pending,
      'in_transit': inTransit,
      'delivered': delivered,
      'revenue': revenue.toStringAsFixed(0),
    };
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return TranslinerTheme.warningYellow;
      case 'in_transit':
        return TranslinerTheme.infoBlue;
      case 'received':
        return TranslinerTheme.successGreen;
      case 'collected':
        return TranslinerTheme.successGreen;
      case 'returned':
        return TranslinerTheme.errorRed;
      default:
        return TranslinerTheme.gray600;
    }
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'in_transit':
        return 'In Transit';
      case 'pending':
        return 'Pending';
      case 'received':
        return 'Received';
      case 'collected':
        return 'Collected';
      case 'returned':
        return 'Returned';
      default:
        return 'Unknown';
    }
  }

  void _showAddParcelDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddParcelDialog(
        destinations: destinations,
        onParcelAdded: () {
          _loadParcels();
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  void _updateParcelStatus(Map<String, dynamic> parcel) {
    showDialog(
      context: context,
      builder: (context) => _UpdateStatusDialog(
        parcel: parcel,
        onStatusUpdated: () {
          _loadParcels();
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  void _editParcel(Map<String, dynamic> parcel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditParcelDialog(
        parcel: parcel,
        destinations: destinations,
        onParcelUpdated: () {
          _loadParcels();
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  void _deleteParcel(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Parcel'),
        content: Text('Are you sure you want to delete this parcel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(int id) async {
    try {
      final apiService = ApiService();
      final response = await apiService.deleteParcel(id);

      if (response['success']) {
        _showSuccess('Parcel deleted successfully');
        _loadParcels();
      } else {
        _showError(response['message'] ?? 'Failed to delete parcel');
      }
    } catch (e) {
      _showError('Failed to delete parcel: $e');
    }
  }

  void _printParcelLabel(Map<String, dynamic> parcel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelPrintScreen(parcel: parcel),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.errorRed,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.successGreen,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Add Parcel Dialog
class _AddParcelDialog extends StatefulWidget {
  final List<Map<String, dynamic>> destinations;
  final VoidCallback onParcelAdded;

  const _AddParcelDialog({
    required this.destinations,
    required this.onParcelAdded,
  });

  @override
  State<_AddParcelDialog> createState() => _AddParcelDialogState();
}

class _AddParcelDialogState extends State<_AddParcelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senderNameController = TextEditingController();
  final _senderMobileController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientMobileController = TextEditingController();
  final _parcelTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _feeController = TextEditingController();

  String selectedDestination = '';
  String selectedPaymentMethod = 'cash';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TranslinerTheme.primaryRed,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
                Text(
                  'Add New Parcel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      'Sender Name',
                      _senderNameController,
                      Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Sender Mobile',
                      _senderMobileController,
                      Icons.phone,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Recipient Name',
                      _recipientNameController,
                      Icons.person_outline,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Recipient Mobile',
                      _recipientMobileController,
                      Icons.phone,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Parcel Type',
                      _parcelTypeController,
                      Icons.category,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      Icons.description,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    _buildDropdown(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Value (KES)',
                            _valueController,
                            Icons.monetization_on,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Fee (KES)',
                            _feeController,
                            Icons.payment,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildPaymentMethodDropdown(),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitParcel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TranslinerTheme.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Add Parcel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) =>
          value?.isEmpty == true ? '$label is required' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDestination.isEmpty ? null : selectedDestination,
      decoration: InputDecoration(
        labelText: 'Destination',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: widget.destinations.map<DropdownMenuItem<String>>((dest) {
        return DropdownMenuItem<String>(
          value: dest['name']?.toString() ?? '',
          child: Text(dest['name']?.toString() ?? ''),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedDestination = value ?? ''),
      validator: (value) =>
          value?.isEmpty == true ? 'Destination is required' : null,
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPaymentMethod,
      decoration: InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: Icon(Icons.payment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        DropdownMenuItem(value: 'cash', child: Text('Cash')),
        DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
        DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
        DropdownMenuItem(value: 'card', child: Text('Card')),
      ],
      onChanged: (value) =>
          setState(() => selectedPaymentMethod = value ?? 'cash'),
    );
  }

  Future<void> _submitParcel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.addParcel({
        'sender_name': _senderNameController.text,
        'sender_mobile': _senderMobileController.text,
        'recipient_name': _recipientNameController.text,
        'recipient_mobile': _recipientMobileController.text,
        'parcel_type': _parcelTypeController.text,
        'description': _descriptionController.text,
        'destination': selectedDestination,
        'value': double.tryParse(_valueController.text) ?? 0,
        'fee': double.tryParse(_feeController.text) ?? 0,
        'payment_method': selectedPaymentMethod,
      });

      if (response['success']) {
        widget.onParcelAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parcel added successfully'),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add parcel: $e'),
          backgroundColor: TranslinerTheme.errorRed,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderMobileController.dispose();
    _recipientNameController.dispose();
    _recipientMobileController.dispose();
    _parcelTypeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _feeController.dispose();
    super.dispose();
  }
}

// Update Status Dialog
class _UpdateStatusDialog extends StatefulWidget {
  final Map<String, dynamic> parcel;
  final VoidCallback onStatusUpdated;

  const _UpdateStatusDialog({
    required this.parcel,
    required this.onStatusUpdated,
  });

  @override
  State<_UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<_UpdateStatusDialog> {
  String selectedStatus = '';
  final _notesController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.parcel['status'] ?? 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Parcel Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in_transit', child: Text('In Transit')),
              DropdownMenuItem(value: 'received', child: Text('Received')),
              DropdownMenuItem(value: 'collected', child: Text('Collected')),
              DropdownMenuItem(value: 'returned', child: Text('Returned')),
            ],
            onChanged: (value) =>
                setState(() => selectedStatus = value ?? 'pending'),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _updateStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: TranslinerTheme.primaryRed,
          ),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('Update', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _updateStatus() async {
    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.updateParcelStatus(
        widget.parcel['id'],
        selectedStatus,
        _notesController.text,
      );

      if (response['success']) {
        widget.onStatusUpdated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: TranslinerTheme.errorRed,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Edit Parcel Dialog (simplified version)
class _EditParcelDialog extends StatelessWidget {
  final Map<String, dynamic> parcel;
  final List<Map<String, dynamic>> destinations;
  final VoidCallback onParcelUpdated;

  const _EditParcelDialog({
    required this.parcel,
    required this.destinations,
    required this.onParcelUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Edit Parcel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Edit functionality coming soon...'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
