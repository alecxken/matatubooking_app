import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'TripExpensesScreen.dart';
import 'parcels_management_screen.dart';
import 'seat_selection_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripToken;

  const TripDetailScreen({super.key, required this.tripToken});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTripData();
    });
  }

  Future<void> _loadTripData() async {
    final tripProvider = context.read<TripProvider>();
    tripProvider.setCurrentTrip(widget.tripToken);
    await tripProvider.loadTripSeats(widget.tripToken);
    await tripProvider.loadTripExpenses(widget.tripToken);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final trip = tripProvider.getCurrentTrip();

        return Scaffold(
          backgroundColor: TranslinerTheme.lightGray,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip?['route']?.toString() ?? 'Trip Details'),
                if (trip != null)
                  Text(
                    '${trip['origin']?.toString() ?? ''} → ${trip['destination']?.toString() ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
            backgroundColor: TranslinerTheme.primaryRed,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTripData,
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              AvailableSeatsView(tripToken: widget.tripToken),
              OccupiedSeatsView(tripToken: widget.tripToken),
              ExpensesView(tripToken: widget.tripToken),
              ManifestView(tripToken: widget.tripToken),
              ParcelsView(tripToken: widget.tripToken),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: TranslinerTheme.primaryRed,
      unselectedItemColor: TranslinerTheme.gray600,
      backgroundColor: TranslinerTheme.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event_seat),
          label: 'Available',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Occupied'),
        BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Expenses'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Manifest'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Parcels'),
      ],
    );
  }
}

// Available Seats View Widget
class AvailableSeatsView extends StatelessWidget {
  final String tripToken;

  const AvailableSeatsView({super.key, required this.tripToken});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final seats = tripProvider.getTripSeats(tripToken);
        final availableSeats = seats.where((seat) => seat.isAvailable).toList();

        if (tripProvider.isLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading seats...',
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        if (availableSeats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat_outlined,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                SizedBox(height: 16),
                Text(
                  'All seats are occupied',
                  style: TextStyle(color: TranslinerTheme.gray600),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header with book seats button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: TranslinerDecorations.premiumCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${availableSeats.length} Available Seats',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TranslinerTheme.charcoal,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeatSelectionScreen(tripToken: tripToken),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TranslinerTheme.primaryRed,
                      foregroundColor: TranslinerTheme.white,
                    ),
                    child: const Text('Book Seats'),
                  ),
                ],
              ),
            ),

            // Seats grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableSeats.length,
                itemBuilder: (context, index) {
                  final seat = availableSeats[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: TranslinerTheme.successGreen,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: TranslinerShadows.subtleShadow,
                    ),
                    child: Center(
                      child: Text(
                        seat.seatNo.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Occupied Seats View Widget
class OccupiedSeatsView extends StatelessWidget {
  final String tripToken;

  const OccupiedSeatsView({super.key, required this.tripToken});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final seats = tripProvider.getTripSeats(tripToken);
        final occupiedSeats = seats.where((seat) => seat.isBooked).toList();

        if (tripProvider.isLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading seats...',
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        if (occupiedSeats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat_outlined,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                SizedBox(height: 16),
                Text(
                  'No seats occupied yet',
                  style: TextStyle(color: TranslinerTheme.gray600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: occupiedSeats.length,
          itemBuilder: (context, index) {
            final seat = occupiedSeats[index];
            final passenger = seat.passenger!;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: TranslinerTheme.errorRed,
                  child: Text(
                    seat.seatNo.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(passenger.name),
                subtitle: Text('Phone: ${passenger.maskedPhone}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(passenger.bookingStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    passenger.bookingStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return TranslinerTheme.successGreen;
      case 'pending':
        return TranslinerTheme.warningYellow;
      case 'cancelled':
        return TranslinerTheme.errorRed;
      default:
        return TranslinerTheme.gray600;
    }
  }
}

// Parcels View Widget
// Enhanced Parcels View Widget - Links to Parcel Management
class ParcelsView extends StatelessWidget {
  final String tripToken;

  const ParcelsView({super.key, required this.tripToken});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Container(
            decoration: TranslinerDecorations.premiumCard,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parcel Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.charcoal,
                      ),
                    ),
                    Text(
                      'Manage trip parcels',
                      style: TextStyle(
                        color: TranslinerTheme.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openParcelManagement(context),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Manage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TranslinerTheme.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Action Cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  'All Parcels',
                  'View & manage all parcels',
                  Icons.inventory_2,
                  TranslinerTheme.primaryRed,
                  () => _openParcelManagement(context),
                ),
                _buildQuickActionCard(
                  context,
                  'Add Parcel',
                  'Register new parcel',
                  Icons.add_box,
                  TranslinerTheme.successGreen,
                  () => _openAddParcel(context),
                ),
                _buildQuickActionCard(
                  context,
                  'Track Status',
                  'Update parcel status',
                  Icons.track_changes,
                  TranslinerTheme.infoBlue,
                  () => _openParcelManagement(context),
                ),
                _buildQuickActionCard(
                  context,
                  'Statistics',
                  'View parcel analytics',
                  Icons.analytics,
                  TranslinerTheme.warningYellow,
                  () => _openParcelStats(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Info
          Container(
            decoration: TranslinerDecorations.premiumCard.copyWith(
              gradient: LinearGradient(
                colors: [
                  TranslinerTheme.primaryRed.withOpacity(0.1),
                  TranslinerTheme.primaryRed.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: TranslinerTheme.primaryRed),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manage parcels for this trip and track their delivery status.',
                    style: TextStyle(color: TranslinerTheme.charcoal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: TranslinerDecorations.premiumCard,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: TranslinerTheme.gray600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openParcelManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelsManagementScreen(tripToken: tripToken),
      ),
    );
  }

  void _openAddParcel(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelsManagementScreen(tripToken: tripToken),
      ),
    );
  }

  void _openParcelStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelsManagementScreen(tripToken: tripToken),
      ),
    );
  }
}

// Expenses View Widget
// Enhanced Expenses View Widget - Navigates to full expense screen
class ExpensesView extends StatefulWidget {
  final String tripToken;

  const ExpensesView({super.key, required this.tripToken});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final trip = tripProvider.getCurrentTrip();
        final expenses = tripProvider.getTripExpenses(widget.tripToken);
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

        return Column(
          children: [
            // Header with manage button
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: TranslinerDecorations.premiumCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TranslinerTheme.charcoal,
                        ),
                      ),
                      Text(
                        'Total: KES ${totalExpenses.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: TranslinerTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openExpenseScreen(context, trip),
                    icon: const Icon(Icons.edit),
                    label: const Text('Manage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TranslinerTheme.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Quick stats
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: TranslinerDecorations.premiumCard.copyWith(
                gradient: LinearGradient(
                  colors: [
                    TranslinerTheme.primaryRed.withOpacity(0.1),
                    TranslinerTheme.primaryRed.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Items', '${expenses.length}', Icons.receipt),
                  _buildStatCard(
                    'Total',
                    'KES ${totalExpenses.toStringAsFixed(0)}',
                    Icons.monetization_on,
                  ),
                  _buildStatCard(
                    'Vehicle',
                    trip?['vehicle_type']?.toString() ?? 'N/A',
                    Icons.directions_bus,
                  ),
                ],
              ),
            ),

            // Recent expenses list
            Expanded(
              child: expenses.isEmpty
                  ? _buildEmptyState(context, trip)
                  : _buildExpensesList(expenses),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: TranslinerTheme.primaryRed, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: TranslinerTheme.charcoal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: TranslinerTheme.gray600),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, Map<String, dynamic>? trip) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TranslinerTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 40,
              color: TranslinerTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses recorded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Manage" to add trip expenses\nwith pre-loaded defaults',
            textAlign: TextAlign.center,
            style: TextStyle(color: TranslinerTheme.gray600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openExpenseScreen(context, trip),
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List expenses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: TranslinerDecorations.premiumCard,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TranslinerTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt, color: Colors.white, size: 20),
            ),
            title: Text(
              expense.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: expense.date != null ? Text('${expense.date}') : null,
            trailing: Text(
              'KES ${expense.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: TranslinerTheme.primaryRed,
              ),
            ),
          ),
        );
      },
    );
  }

  void _openExpenseScreen(BuildContext context, Map<String, dynamic>? trip) {
    if (trip == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip data not available')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TripExpensesScreen(tripToken: widget.tripToken, tripData: trip),
      ),
    ).then((result) {
      // Refresh expenses when returning from expense screen
      if (result == true) {
        context.read<TripProvider>().loadTripExpenses(widget.tripToken);
      }
    });
  }
}

// Manifest View Widget
// Enhanced Manifest View Widget with Expenses
class ManifestView extends StatelessWidget {
  final String tripToken;

  const ManifestView({super.key, required this.tripToken});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        if (tripProvider.isLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading manifest...',
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final trip = tripProvider.getCurrentTrip();
        final seats = tripProvider.getTripSeats(tripToken);
        final expenses = tripProvider.getTripExpenses(tripToken);

        final bookedSeats = seats.where((seat) => seat.isBooked).toList();
        final totalRevenue =
            (bookedSeats.length *
                    (double.tryParse(trip?['fare']?.toString() ?? '0') ?? 0))
                .toDouble();
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );
        final netProfit = (totalRevenue - totalExpenses).toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Trip Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Manifest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TranslinerTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Route: ${trip?['route']?.toString() ?? 'N/A'}'),
                      Text(
                        'Vehicle: ${trip?['vehicle']?.toString() ?? 'Not assigned'}',
                      ),
                      Text(
                        'Driver: ${trip?['driver']?.toString() ?? 'Not assigned'}',
                      ),
                      Text(
                        'Date: ${trip?['departure_date']?.toString() ?? 'N/A'}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Financial Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFinancialRow('Revenue', totalRevenue),
                      _buildFinancialRow('Expenses', totalExpenses),
                      const Divider(),
                      _buildFinancialRow(
                        'Net Profit',
                        netProfit,
                        isProfit: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Expenses Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Expenses (${expenses.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (expenses.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TranslinerTheme.errorRed.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'KES ${totalExpenses.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: TranslinerTheme.errorRed,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (expenses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TranslinerTheme.gray600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: TranslinerTheme.gray600,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'No expenses recorded for this trip',
                                style: TextStyle(
                                  color: TranslinerTheme.gray600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: TranslinerTheme.primaryRed,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                expense.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: expense.date != null
                                  ? Text('${expense.date}')
                                  : null,
                              trailing: Text(
                                'KES ${expense.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: TranslinerTheme.errorRed,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Passenger List
              if (bookedSeats.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Passengers (${bookedSeats.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TranslinerTheme.successGreen.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'KES ${totalRevenue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: TranslinerTheme.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookedSeats.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final seat = bookedSeats[index];
                            final passenger = seat.passenger;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: TranslinerTheme.primaryRed,
                                radius: 16,
                                child: Text(
                                  seat.seatNo.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(passenger?.name ?? 'Unknown'),
                              subtitle: Text(
                                passenger?.maskedPhone ?? 'No phone',
                              ),
                              trailing: Text(
                                'KES ${trip?['fare']?.toString() ?? '0'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialRow(
    String label,
    double amount, {
    bool isProfit = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'KES ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isProfit
                  ? (amount >= 0
                        ? TranslinerTheme.successGreen
                        : TranslinerTheme.errorRed)
                  : TranslinerTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
