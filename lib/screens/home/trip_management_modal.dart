import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../services/api_service.dart';

// Trip Management Modal
class _TripManagementModal extends StatefulWidget {
  final Map<String, dynamic>? trip;
  final bool isEdit;
  final bool isDuplicate;
  final VoidCallback onSaved;

  const _TripManagementModal({
    this.trip,
    this.isEdit = false,
    this.isDuplicate = false,
    required this.onSaved,
  });

  @override
  State<_TripManagementModal> createState() => _TripManagementModalState();
}

class _TripManagementModalState extends State<_TripManagementModal> {
  final _formKey = GlobalKey<FormState>();
  final _routeController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _tripTypeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Dropdown options
  List<String> vehicleTypes = [
    '14 Seater',
    '22 Seater',
    '32 Seater',
    '51 Seater',
  ];
  List<String> tripTypes = ['Terminal Booking', 'Advance Booking', 'Charter'];
  List<String> routes = [
    'Nairobi - Mombasa',
    'Nairobi - Kisumu',
    'Nairobi - Eldoret',
  ];
  List<String> destinations = [
    'Mombasa',
    'Kisumu',
    'Eldoret',
    'Nakuru',
    'Thika',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _populateFields();
    } else {
      // Set defaults for new trip
      _tripTypeController.text = 'Terminal Booking';
      _departureTimeController.text = '07:00';
    }

    // If duplicate, change the date to today
    if (widget.isDuplicate) {
      _selectedDate = DateTime.now();
    }
  }

  void _populateFields() {
    final trip = widget.trip!;
    _routeController.text = trip['route'] ?? '';
    _originController.text = trip['origin'] ?? '';
    _destinationController.text = trip['destination'] ?? '';
    _vehicleController.text = trip['vehicle'] ?? '';
    _driverController.text = trip['driver'] ?? '';
    _vehicleTypeController.text = trip['vehicle_type'] ?? '';
    _departureTimeController.text = trip['departure_time'] ?? '';
    _tripTypeController.text = trip['trip_type'] ?? 'Terminal Booking';

    if (!widget.isDuplicate && trip['departure_date'] != null) {
      try {
        _selectedDate = DateTime.parse(trip['departure_date']);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: TranslinerTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isEdit ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isEdit
                          ? 'Edit Trip'
                          : widget.isDuplicate
                          ? 'Duplicate Trip'
                          : 'Create New Trip',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Route and Vehicle Type
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Route',
                              _routeController,
                              routes,
                              Icons.route,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              'Vehicle Type',
                              _vehicleTypeController,
                              vehicleTypes,
                              Icons.directions_bus,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Origin and Destination
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Origin',
                              _originController,
                              destinations,
                              Icons.location_on,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              'Destination',
                              _destinationController,
                              destinations,
                              Icons.flag,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Vehicle and Driver
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Vehicle',
                              _vehicleController,
                              Icons.directions_bus,
                              required: false,
                              placeholder: 'e.g., KDD 567A',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Driver',
                              _driverController,
                              Icons.person,
                              required: false,
                              placeholder: 'e.g., John Doe',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date, Time and Trip Type
                      Row(
                        children: [
                          Expanded(child: _buildDateField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTimeField()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Trip Type
                      _buildDropdownField(
                        'Trip Type',
                        _tripTypeController,
                        tripTypes,
                        Icons.category,
                        required: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: TranslinerTheme.gray100,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: TranslinerTheme.gray400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TranslinerTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isEdit ? 'Update Trip' : 'Create Trip',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = true,
    String? placeholder,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: Icon(icon, color: TranslinerTheme.primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TranslinerTheme.primaryRed),
        ),
      ),
      validator: required
          ? (value) {
              if (value?.isEmpty == true) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> options,
    IconData icon, {
    bool required = true,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: TranslinerTheme.primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TranslinerTheme.primaryRed),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      validator: required
          ? (value) {
              if (value?.isEmpty == true) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: TranslinerTheme.gray400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: TranslinerTheme.primaryRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Departure Date',
                    style: TextStyle(
                      color: TranslinerTheme.gray600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      color: TranslinerTheme.charcoal,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: TranslinerTheme.gray400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: TranslinerTheme.primaryRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Departure Time',
                    style: TextStyle(
                      color: TranslinerTheme.gray600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _departureTimeController.text.isEmpty
                        ? '07:00'
                        : _departureTimeController.text,
                    style: const TextStyle(
                      color: TranslinerTheme.charcoal,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TranslinerTheme.primaryRed,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TranslinerTheme.primaryRed,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _departureTimeController.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_departureTimeController.text.isEmpty) {
      _departureTimeController.text = '07:00';
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      final tripData = {
        'route': _routeController.text,
        'origin': _originController.text,
        'destination': _destinationController.text,
        'vehicle': _vehicleController.text,
        'driver': _driverController.text,
        'vehicle_type': _vehicleTypeController.text,
        'departure_date':
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'departure_time': _departureTimeController.text,
        'trip_type': _tripTypeController.text,
        if (widget.isEdit && widget.trip?['token'] != null)
          'token': widget.trip!['token'],
      };

      final response = widget.isEdit
          ? await apiService.updateTrip(widget.trip!['token'], tripData)
          : await apiService.createTrip(tripData);

      if (response['success']) {
        widget.onSaved();
      } else {
        _showError(response['message'] ?? 'Failed to save trip');
      }
    } catch (e) {
      _showError('Failed to save trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _routeController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _vehicleController.dispose();
    _driverController.dispose();
    _vehicleTypeController.dispose();
    _departureTimeController.dispose();
    _tripTypeController.dispose();
    super.dispose();
  }
}
