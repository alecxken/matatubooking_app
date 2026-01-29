// lib/screens/reports/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../theme/transliner_theme.dart';

/// Reports Screen with Calendar and Trial Balance
/// Features:
/// - Calendar view with trip counts per day
/// - Trial balance on date selection (Revenue - Expenses)
/// - Revenue from bookings and parcels
/// - Clean, professional layout
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mock data - Replace with actual API calls
  final Map<DateTime, int> _tripCounts = {};
  final Map<DateTime, TrialBalanceData> _trialBalanceData = {};

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    // TODO: Replace with actual API calls
    // Mock data for demonstration
    setState(() {
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = DateTime(now.year, now.month, i + 1);
        _tripCounts[_normalizeDate(date)] = (i % 5) + 1;
        _trialBalanceData[_normalizeDate(date)] = TrialBalanceData(
          bookingRevenue: (i + 1) * 15000.0,
          parcelRevenue: (i + 1) * 3000.0,
          expenses: (i + 1) * 8000.0,
        );
      }
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _getTripsForDay(DateTime day) {
    return _tripCounts[_normalizeDate(day)] ?? 0;
  }

  TrialBalanceData? _getTrialBalanceForDay(DateTime day) {
    return _trialBalanceData[_normalizeDate(day)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Add filter options
            },
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // TODO: Export report
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export feature coming soon',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: TranslinerTheme.infoBlue,
                ),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: TranslinerShadows.level2,
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TranslinerTheme.primaryRed.withOpacity(0.1),
                          TranslinerTheme.infoBlue.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: TranslinerTheme.primaryRed,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Trip Calendar',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TranslinerTheme.charcoal,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TranslinerTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_tripCounts.length} days',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TranslinerTheme.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Calendar
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: TranslinerTheme.infoBlue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: TranslinerTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: TranslinerTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: GoogleFonts.montserrat(
                        color: TranslinerTheme.errorRed,
                      ),
                      defaultTextStyle: GoogleFonts.montserrat(),
                      selectedTextStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                      todayTextStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.charcoal,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: TranslinerTheme.primaryRed,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: TranslinerTheme.primaryRed,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        color: TranslinerTheme.gray600,
                      ),
                      weekendStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        color: TranslinerTheme.errorRed,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        final count = _getTripsForDay(day);
                        if (count > 0) {
                          return Positioned(
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TranslinerTheme.successGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Trial Balance Card (only show when date is selected)
            if (_selectedDay != null) _buildTrialBalanceCard(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialBalanceCard() {
    final data = _getTrialBalanceForDay(_selectedDay!);
    if (data == null) {
      return const SizedBox.shrink();
    }

    final totalRevenue = data.bookingRevenue + data.parcelRevenue;
    final netProfit = totalRevenue - data.expenses;
    final profitMargin =
        totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: TranslinerShadows.level2,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TranslinerTheme.infoBlue.withOpacity(0.1),
                  TranslinerTheme.successGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: TranslinerTheme.infoBlue,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trial Balance',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.charcoal,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: TranslinerTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Revenue',
                    totalRevenue,
                    Icons.trending_up_rounded,
                    TranslinerTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    data.expenses,
                    Icons.trending_down_rounded,
                    TranslinerTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),

          // Net Profit Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: netProfit >= 0
                    ? [
                        TranslinerTheme.successGreen.withOpacity(0.1),
                        TranslinerTheme.successGreen.withOpacity(0.05),
                      ]
                    : [
                        TranslinerTheme.errorRed.withOpacity(0.1),
                        TranslinerTheme.errorRed.withOpacity(0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: netProfit >= 0
                    ? TranslinerTheme.successGreen.withOpacity(0.3)
                    : TranslinerTheme.errorRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: netProfit >= 0
                        ? TranslinerTheme.successGreen.withOpacity(0.2)
                        : TranslinerTheme.errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    netProfit >= 0
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    color: netProfit >= 0
                        ? TranslinerTheme.successGreen
                        : TranslinerTheme.errorRed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Profit/Loss',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TranslinerTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(netProfit),
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: netProfit >= 0
                              ? TranslinerTheme.successGreen
                              : TranslinerTheme.errorRed,
                        ),
                      ),
                      Text(
                        '${profitMargin.toStringAsFixed(1)}% margin',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: TranslinerTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Revenue Breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Breakdown',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRevenueItem(
                  'Booking Revenue',
                  data.bookingRevenue,
                  Icons.confirmation_number_rounded,
                  TranslinerTheme.infoBlue,
                ),
                const SizedBox(height: 8),
                _buildRevenueItem(
                  'Parcel Revenue',
                  data.parcelRevenue,
                  Icons.inventory_2_rounded,
                  TranslinerTheme.warningYellow,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TranslinerTheme.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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

/// Trial Balance Data Model
class TrialBalanceData {
  final double bookingRevenue;
  final double parcelRevenue;
  final double expenses;

  TrialBalanceData({
    required this.bookingRevenue,
    required this.parcelRevenue,
    required this.expenses,
  });

  double get totalRevenue => bookingRevenue + parcelRevenue;
  double get netProfit => totalRevenue - expenses;
}
