import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../trip/trip_detail_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrips());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final settingsProvider = context.read<AppSettingsProvider>();
    final tripProvider = context.read<TripProvider>();

    await tripProvider.loadTripsForDate(settingsProvider.appDateForApi);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      body: Column(
        children: [
          _buildPremiumHeader(),
          _buildDateSelector(),
          _buildTabBar(),
          Expanded(child: _buildTabViews()),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: TranslinerTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // App Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TransLine Cruiser',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Your Journey, Our Priority',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          margin: TranslinerSpacing.pagePadding,
          decoration: TranslinerDecorations.premiumCard,
          child: Padding(
            padding: TranslinerSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TranslinerTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: TranslinerTheme.primaryRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Travel Date',
                        style: TextStyle(
                          color: TranslinerTheme.gray600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        settings.appDateForDisplay,
                        style: const TextStyle(
                          color: TranslinerTheme.charcoal,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDatePicker(settings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: TranslinerDecorations.primaryButton,
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: TranslinerTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final trips = tripProvider.trips;
        final toNairobiCount = trips['to_nairobi']?.length ?? 0;
        final fromNairobiCount = trips['from_nairobi']?.length ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: TranslinerTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: TranslinerShadows.cardShadow,
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: TranslinerTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            labelColor: TranslinerTheme.white,
            unselectedLabelColor: TranslinerTheme.gray600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward, size: 16),
                    const SizedBox(width: 8),
                    const Text('To Nairobi'),
                    if (toNairobiCount > 0) ...[
                      const SizedBox(width: 8),
                      _buildTripBadge(toNairobiCount),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 16),
                    const SizedBox(width: 8),
                    const Text('From Nairobi'),
                    if (fromNairobiCount > 0) ...[
                      const SizedBox(width: 8),
                      _buildTripBadge(fromNairobiCount),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: TranslinerTheme.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: TranslinerTheme.primaryRed,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabViews() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        if (_isLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading trips...',
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        if (tripProvider.error != null) {
          return ErrorDisplayWidget(
            message: tripProvider.error!,
            onRetry: _loadTrips,
          );
        }

        final trips = tripProvider.trips;

        return TabBarView(
          controller: _tabController,
          children: [
            _buildTripsList(
              trips['to_nairobi'] ?? [],
              'No trips to Nairobi today',
            ),
            _buildTripsList(
              trips['from_nairobi'] ?? [],
              'No trips from Nairobi today',
            ),
          ],
        );
      },
    );
  }

  Widget _buildTripsList(List<dynamic> trips, String emptyMessage) {
    if (trips.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      color: TranslinerTheme.primaryRed,
      child: ListView.builder(
        padding: TranslinerSpacing.pagePadding,
        itemCount: trips.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildTripCard(trips[index]),
          );
        },
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    final availableSeats = trip['available_seats'] ?? 0;
    final totalSeats = (trip['booked_seats_count'] ?? 0) + availableSeats;
    final occupancyRate = totalSeats > 0
        ? (trip['booked_seats_count'] ?? 0) / totalSeats
        : 0.0;

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToTripDetail(trip['token'] as String?),
          child: Padding(
            padding: TranslinerSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['route'] ?? 'Unknown Route',
                            style: const TextStyle(
                              color: TranslinerTheme.charcoal,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: TranslinerTheme.gray600,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip['departure_time'] ?? 'TBD',
                                style: const TextStyle(
                                  color: TranslinerTheme.gray600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: TranslinerDecorations.primaryButton,
                      child: Text(
                        'KES ${trip['fare'] ?? '0'}',
                        style: const TextStyle(
                          color: TranslinerTheme.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.canManageTrips) {
                          return Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: TranslinerTheme.gray600,
                                size: 20,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showEditTripModal(trip);
                                    break;
                                  case 'details':
                                    _navigateToTripDetail(
                                      trip['token'] as String?,
                                    );
                                    break;
                                  case 'duplicate':
                                    _showDuplicateTripModal(trip);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: TranslinerTheme.primaryRed,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Edit Trip'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        size: 16,
                                        color: TranslinerTheme.infoBlue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('View Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: TranslinerTheme.successGreen,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildInfoChip(
                      Icons.directions_bus,
                      trip['vehicle'] ?? 'TBA',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.person, trip['driver'] ?? 'TBA'),
                  ],
                ),

                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seat Availability',
                          style: TextStyle(
                            color: TranslinerTheme.gray600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$availableSeats/$totalSeats available',
                          style: const TextStyle(
                            color: TranslinerTheme.charcoal,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (1 - occupancyRate).toDouble(),
                        backgroundColor: TranslinerTheme.gray100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSeatAvailabilityColor(occupancyRate),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TranslinerTheme.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: TranslinerTheme.primaryRed, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: TranslinerTheme.charcoal,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeatAvailabilityColor(double occupancyRate) {
    if (occupancyRate < 0.5) return TranslinerTheme.successGreen;
    if (occupancyRate < 0.8) return TranslinerTheme.warningYellow;
    return TranslinerTheme.errorRed;
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TranslinerTheme.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.explore_off,
              size: 40,
              color: TranslinerTheme.gray400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: TranslinerTheme.gray600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTrips,
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.primaryRed,
              foregroundColor: TranslinerTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Refresh Trips'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(AppSettingsProvider settings) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: settings.appDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: TranslinerTheme.primaryRed),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      await settings.setAppDate(selectedDate);
      _loadTrips();
    }
  }

  void _navigateToTripDetail(String? tripToken) {
    if (tripToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailScreen(tripToken: tripToken),
        ),
      );
    }
  }

  // Trip Management Methods
  void _showEditTripModal(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => _TripManagementModal(
        trip: trip,
        isEdit: true,
        onSaved: () {
          _loadTrips();
          Navigator.of(context).pop();
          _showSuccess('Trip updated successfully');
        },
      ),
    );
  }

  void _showCreateTripModal() {
    showDialog(
      context: context,
      builder: (context) => _TripManagementModal(
        onSaved: () {
          _loadTrips();
          Navigator.of(context).pop();
          _showSuccess('Trip created successfully');
        },
      ),
    );
  }

  void _showDuplicateTripModal(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => _TripManagementModal(
        trip: trip,
        isDuplicate: true,
        onSaved: () {
          _loadTrips();
          Navigator.of(context).pop();
          _showSuccess('Trip duplicated successfully');
        },
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

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

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _populateFields();
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

    if (!widget.isDuplicate && trip['departure_date'] != null) {
      _selectedDate = DateTime.parse(trip['departure_date']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Route',
                              _routeController,
                              Icons.route,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Vehicle Type',
                              _vehicleTypeController,
                              Icons.directions_bus,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Origin',
                              _originController,
                              Icons.location_on,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Destination',
                              _destinationController,
                              Icons.flag,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Vehicle',
                              _vehicleController,
                              Icons.directions_bus,
                              required: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Driver',
                              _driverController,
                              Icons.person,
                              required: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDateField()),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Departure Time',
                              _departureTimeController,
                              Icons.schedule,
                            ),
                          ),
                        ],
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Here you would call your API to save the trip
      // For now, we'll simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save trip: $e'),
          backgroundColor: TranslinerTheme.errorRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
    super.dispose();
  }
}
