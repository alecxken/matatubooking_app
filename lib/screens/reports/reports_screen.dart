// lib/screens/reports/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/transliner_theme.dart';
import '../../providers/trip_provider.dart';
import '../../providers/app_settings_provider.dart';

/// Enhanced Reports Screen with Detailed Manifest
/// Features:
/// - Daily summary with accurate API data
/// - Spreadsheet-like detailed manifest
/// - Trip-by-trip breakdown
/// - Vehicle, driver, revenue details
/// - Export functionality
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _dailyTrips = [];
  DailySummary? _summary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDailyReport());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyReport() async {
    setState(() => _isLoading = true);

    try {
      final tripProvider = context.read<TripProvider>();

      // Load trips for the selected date
      await tripProvider.loadTripsForDate(
        DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      final allTrips = <Map<String, dynamic>>[
        ...(tripProvider.trips['to_nairobi'] ?? []).cast<Map<String, dynamic>>(),
        ...(tripProvider.trips['from_nairobi'] ?? []).cast<Map<String, dynamic>>(),
      ];

      // Calculate summary
      _summary = _calculateSummary(allTrips);
      _dailyTrips = allTrips;
    } catch (e) {
      _showError('Failed to load report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DailySummary _calculateSummary(List<Map<String, dynamic>> trips) {
    int totalTrips = trips.length;
    int totalSeatsBooked = 0;
    int totalSeatsAvailable = 0;
    double totalRevenue = 0;
    Set<String> uniqueVehicles = {};
    Set<String> uniqueDrivers = {};

    for (var trip in trips) {
      final booked = trip['booked_seats_count'] ?? 0;
      final available = trip['available_seats'] ?? 0;
      final fare = double.tryParse(trip['fare']?.toString() ?? '0') ?? 0;

      totalSeatsBooked += booked as int;
      totalSeatsAvailable += available as int;
      totalRevenue += fare * booked;

      if (trip['vehicle'] != null) uniqueVehicles.add(trip['vehicle']);
      if (trip['driver'] != null) uniqueDrivers.add(trip['driver']);
    }

    return DailySummary(
      totalTrips: totalTrips,
      totalSeatsBooked: totalSeatsBooked,
      totalSeatsAvailable: totalSeatsAvailable,
      totalRevenue: totalRevenue,
      uniqueVehicles: uniqueVehicles.length,
      uniqueDrivers: uniqueDrivers.length,
      occupancyRate: (totalSeatsBooked + totalSeatsAvailable) > 0
          ? (totalSeatsBooked / (totalSeatsBooked + totalSeatsAvailable)) * 100
          : 0,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: TranslinerTheme.errorRed,
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && date != _selectedDate) {
      setState(() => _selectedDate = date);
      _loadDailyReport();
    }
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
          'Daily Reports',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDailyReport,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.date_range, color: TranslinerTheme.primaryRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Date',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: TranslinerTheme.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: TranslinerTheme.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: Text(
                    'Change',
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: TranslinerTheme.primaryRed,
              unselectedLabelColor: TranslinerTheme.gray600,
              indicatorColor: TranslinerTheme.primaryRed,
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Detailed Manifest'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: TranslinerTheme.primaryRed,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(),
                      _buildManifestTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_summary == null) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.montserrat(color: TranslinerTheme.gray600),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Trips',
                  _summary!.totalTrips.toString(),
                  Icons.directions_bus,
                  TranslinerTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Vehicles Used',
                  _summary!.uniqueVehicles.toString(),
                  Icons.local_shipping,
                  TranslinerTheme.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Seats Booked',
                  _summary!.totalSeatsBooked.toString(),
                  Icons.event_seat,
                  TranslinerTheme.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Drivers',
                  _summary!.uniqueDrivers.toString(),
                  Icons.person,
                  TranslinerTheme.warningYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TranslinerTheme.successGreen.withOpacity(0.1),
                  TranslinerTheme.successGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TranslinerTheme.successGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TranslinerTheme.successGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: TranslinerTheme.successGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Revenue',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: TranslinerTheme.gray600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatCurrency(_summary!.totalRevenue),
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: TranslinerTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Occupancy',
                      '${_summary!.occupancyRate.toStringAsFixed(1)}%',
                    ),
                    _buildStatItem(
                      'Avg/Trip',
                      _formatCurrency(_summary!.totalTrips > 0
                          ? _summary!.totalRevenue / _summary!.totalTrips
                          : 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManifestTab() {
    if (_dailyTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: TranslinerTheme.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'No trips found for this date',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: TranslinerTheme.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Manifest Header
          Container(
            padding: const EdgeInsets.all(16),
            color: TranslinerTheme.gray100,
            child: Row(
              children: [
                Icon(Icons.table_chart, color: TranslinerTheme.primaryRed),
                const SizedBox(width: 12),
                Text(
                  'Trip Manifest - ${_dailyTrips.length} Trips',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
              ],
            ),
          ),

          // Spreadsheet Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                TranslinerTheme.primaryRed.withOpacity(0.1),
              ),
              columnSpacing: 16,
              headingTextStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: TranslinerTheme.primaryRed,
              ),
              dataTextStyle: GoogleFonts.montserrat(
                fontSize: 12,
                color: TranslinerTheme.charcoal,
              ),
              columns: const [
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Route')),
                DataColumn(label: Text('Vehicle')),
                DataColumn(label: Text('Driver')),
                DataColumn(label: Text('Seats\nBooked')),
                DataColumn(label: Text('Seats\nAvail')),
                DataColumn(label: Text('Fare')),
                DataColumn(label: Text('Revenue')),
              ],
              rows: _dailyTrips.map((trip) {
                final booked = trip['booked_seats_count'] ?? 0;
                final fare = double.tryParse(trip['fare']?.toString() ?? '0') ?? 0;
                final revenue = fare * (booked as int);

                return DataRow(
                  cells: [
                    DataCell(Text(trip['departure_time'] ?? 'N/A')),
                    DataCell(
                      Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          trip['route'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(trip['vehicle'] ?? 'TBA')),
                    DataCell(Text(trip['driver'] ?? 'TBA')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TranslinerTheme.infoBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booked.toString(),
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: TranslinerTheme.infoBlue,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text((trip['available_seats'] ?? 0).toString())),
                    DataCell(Text(_formatCurrency(fare))),
                    DataCell(
                      Text(
                        _formatCurrency(revenue),
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: TranslinerTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Total Row
          Container(
            padding: const EdgeInsets.all(16),
            color: TranslinerTheme.successGreen.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL:',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_summary?.totalSeatsBooked ?? 0} Seats Booked',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TranslinerTheme.infoBlue,
                      ),
                    ),
                    Text(
                      _formatCurrency(_summary?.totalRevenue ?? 0),
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.successGreen,
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
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TranslinerShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: TranslinerTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: TranslinerTheme.gray600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TranslinerTheme.successGreen,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'KES ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

// Daily Summary Model
class DailySummary {
  final int totalTrips;
  final int totalSeatsBooked;
  final int totalSeatsAvailable;
  final double totalRevenue;
  final int uniqueVehicles;
  final int uniqueDrivers;
  final double occupancyRate;

  DailySummary({
    required this.totalTrips,
    required this.totalSeatsBooked,
    required this.totalSeatsAvailable,
    required this.totalRevenue,
    required this.uniqueVehicles,
    required this.uniqueDrivers,
    required this.occupancyRate,
  });
}
