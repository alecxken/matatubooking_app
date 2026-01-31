import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/transliner_theme.dart';
import '../../providers/trip_management_provider.dart';
import '../../services/api_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  // Form controllers
  String? _selectedVehicleType;
  String? _selectedRoute;
  String? _selectedOrigin;
  String? _selectedDestination;
  String? _selectedVehicle;
  String? _selectedDriver;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  String _tripType = 'Terminal Booking';

  // Dropdown options
  final List<String> _vehicleTypes = [
    '14 Seater',
    '33 Seater',
    '51 Seater',
    'Hiace',
    'Probox',
  ];

  final List<String> _tripTypes = [
    'Terminal Booking',
    'Advance Booking',
    'Charter',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<TripManagementProvider>();
      await Future.wait([
        provider.fetchRoutes(),
        provider.fetchDestinations(),
        provider.fetchVehicles(),
        provider.fetchDrivers(),
      ]);
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _departureDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _departureTime = time);
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_departureDate == null) {
      _showError('Please select departure date');
      return;
    }

    if (_departureTime == null) {
      _showError('Please select departure time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tripData = {
        'vehicle_type': _selectedVehicleType,
        'routes': _selectedRoute,
        'origin': _selectedOrigin,
        'destination': _selectedDestination,
        'vehicle': _selectedVehicle,
        'drivers': _selectedDriver,
        'departure_date': DateFormat('yyyy-MM-dd').format(_departureDate!),
        'departure_time': '${_departureTime!.hour.toString().padLeft(2, '0')}:${_departureTime!.minute.toString().padLeft(2, '0')}',
        'trip_type': _tripType,
      };

      final response = await _apiService.createTrip(tripData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip created successfully!',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      _showError('Failed to create trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: TranslinerTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: TranslinerTheme.primaryGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Home',
        ),
        title: Text(
          'Create New Trip',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: TranslinerTheme.primaryRed,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TranslinerTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TranslinerTheme.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: TranslinerTheme.infoBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Create a single trip by filling in the details below. Fields marked with * are required.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final provider = context.watch<TripManagementProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TranslinerShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Type & Route
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Vehicle Type',
                  value: _selectedVehicleType,
                  items: _vehicleTypes,
                  onChanged: (value) =>
                      setState(() => _selectedVehicleType = value),
                  required: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Route',
                  value: _selectedRoute,
                  items: provider.routes.map((r) => r.name).toList(),
                  onChanged: (value) => setState(() => _selectedRoute = value),
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Origin & Destination
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Origin',
                  value: _selectedOrigin,
                  items:
                      provider.destinations.map((d) => d.name).toList(),
                  onChanged: (value) => setState(() => _selectedOrigin = value),
                  required: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Destination',
                  value: _selectedDestination,
                  items:
                      provider.destinations.map((d) => d.name).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDestination = value),
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vehicle & Driver
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Vehicle',
                  value: _selectedVehicle,
                  items: provider.vehicles.map((v) => v.regNo).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedVehicle = value),
                  required: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Driver',
                  value: _selectedDriver,
                  items: provider.drivers.map((d) => d.name).toList(),
                  onChanged: (value) => setState(() => _selectedDriver = value),
                  required: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Departure Date & Time
          Row(
            children: [
              Expanded(
                child: _buildDateField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trip Type
          _buildDropdown(
            label: 'Trip Type',
            value: _tripType,
            items: _tripTypes,
            onChanged: (value) => setState(() => _tripType = value!),
            required: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required bool required,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: TranslinerTheme.errorRed,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: TranslinerTheme.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: Text(
            'Select $label',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: TranslinerTheme.gray600,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Departure Date',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TranslinerTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: TranslinerTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _departureDate != null
                        ? DateFormat('EEE, MMM d, y').format(_departureDate!)
                        : 'Select Date',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: _departureDate != null
                          ? TranslinerTheme.charcoal
                          : TranslinerTheme.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Departure Time',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TranslinerTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: TranslinerTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _departureTime != null
                        ? _departureTime!.format(context)
                        : 'Select Time',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: _departureTime != null
                          ? TranslinerTheme.charcoal
                          : TranslinerTheme.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: TranslinerTheme.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Trip',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
