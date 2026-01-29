import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/seat_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../utils/constants.dart';
import 'payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String tripToken;

  const SeatSelectionScreen({super.key, required this.tripToken});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = context.read<TripProvider>();
      tripProvider.setCurrentTrip(widget.tripToken);
      tripProvider.loadTripSeats(widget.tripToken);
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: TranslinerTheme.white,
        elevation: 0,
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(
              child: LoadingWidget(
                message: 'Loading seats...',
                color: TranslinerTheme.primaryRed,
              ),
            );
          }

          if (tripProvider.error != null) {
            return ErrorDisplayWidget(
              message: tripProvider.error!,
              onRetry: () => tripProvider.loadTripSeats(widget.tripToken),
            );
          }

          final trip = tripProvider.getCurrentTrip();
          final seats = tripProvider.getTripSeats(widget.tripToken);

          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          return Column(
            children: [
              _buildTripHeader(trip),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSeatMap(seats, tripProvider),
                      const SizedBox(height: 24),
                      _buildSeatLegend(),
                      const SizedBox(height: 24),
                      if (tripProvider.selectedSeats.isNotEmpty) ...[
                        _buildSelectedSeatsInfo(tripProvider),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              if (tripProvider.selectedSeats.isNotEmpty)
                _buildBottomActionBar(tripProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripHeader(Map<String, dynamic> trip) {
    final occupiedCount = 0; // You can calculate this from seats
    final totalSeats =
        int.tryParse(trip['total_seats']?.toString() ?? '0') ?? 0;
    final availableCount = totalSeats - occupiedCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: TranslinerDecorations.premiumCard.copyWith(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: TranslinerTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['route']?.toString() ?? 'Unknown Route',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TranslinerTheme.charcoal,
                        ),
                      ),
                      Text(
                        '${trip['departure_date']} at ${trip['departure_time']}',
                        style: const TextStyle(
                          color: TranslinerTheme.gray600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TranslinerTheme.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'KES ${trip['fare']?.toString() ?? '0'}',
                    style: const TextStyle(
                      color: TranslinerTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    availableCount.toString(),
                    TranslinerTheme.successGreen,
                    Icons.event_seat_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Occupied',
                    occupiedCount.toString(),
                    TranslinerTheme.primaryRed,
                    Icons.person_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    totalSeats.toString(),
                    TranslinerTheme.charcoal,
                    Icons.grid_view_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildSeatMap(List seats, TripProvider tripProvider) {
    if (seats.isEmpty) {
      return const Center(child: Text('No seats available'));
    }

    // Determine layout based on seat count
    final totalSeats = seats.length;
    final crossAxisCount = _getCrossAxisCount(totalSeats);

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Select Your Seats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),

          // Driver section
          Row(
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: TranslinerTheme.gray400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.airline_seat_recline_normal,
                  color: TranslinerTheme.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Driver',
                style: TextStyle(color: TranslinerTheme.gray600, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Seat grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: seats.length,
            itemBuilder: (context, index) {
              final seat = seats[index];
              final seatNo = seat.seatNo;
              final isAvailable = seat.isAvailable;
              final isSelected = tripProvider.isSeatSelected(seatNo);

              return GestureDetector(
                onTap: () => _onSeatTap(seat, tripProvider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _getSeatColor(seat, isSelected),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: TranslinerTheme.primaryRed,
                            width: 2,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: TranslinerTheme.primaryRed.withOpacity(
                                0.3,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal,
                        color: _getSeatIconColor(seat, isSelected),
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        seatNo.toString(),
                        style: TextStyle(
                          color: _getSeatIconColor(seat, isSelected),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onSeatTap(dynamic seat, TripProvider tripProvider) {
    HapticFeedback.selectionClick();

    if (seat.isAvailable) {
      // Available seat - toggle selection
      tripProvider.toggleSeatSelection(seat.seatNo);

      // If seat is now selected and we have multiple selected, show booking dialog
      if (tripProvider.isSeatSelected(seat.seatNo)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showBookingDialog(tripProvider);
        });
      }
    } else {
      // Occupied seat - show passenger details
      if (seat.passenger != null) {
        _showPassengerDetails(seat);
      }
    }
  }

  void _showPassengerDetails(dynamic seat) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: TranslinerTheme.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: TranslinerTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seat ${seat.seatNo}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Name',
                      seat.passenger?.name ?? 'N/A',
                      Icons.person_outline_rounded,
                    ),
                    _buildDetailRow(
                      'Phone',
                      seat.passenger?.maskedPhone ?? 'N/A',
                      Icons.phone_rounded,
                    ),
                    _buildDetailRow(
                      'Status',
                      seat.passenger?.bookingStatus ?? 'Confirmed',
                      Icons.info_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(TripProvider tripProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: TranslinerTheme.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: TranslinerTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Book Selected Seats',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected seats info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TranslinerTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Selected Seats',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: tripProvider.selectedSeats.map((
                                  seatNo,
                                ) {
                                  return Chip(
                                    label: Text('$seatNo'),
                                    backgroundColor: TranslinerTheme.primaryRed,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Passenger Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name *',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => AppValidation.validateRequired(
                            value,
                            'First name',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name *',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => AppValidation.validateRequired(
                            value,
                            'Last name',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            prefixIcon: Icon(Icons.phone_rounded),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: AppValidation.validatePhone,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _idNumberController,
                          decoration: const InputDecoration(
                            labelText: 'ID Number (Optional)',
                            prefixIcon: Icon(Icons.badge_rounded),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: AppValidation.validateIdNumber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _proceedToPaymentFromDialog(tripProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TranslinerTheme.primaryRed,
                      foregroundColor: TranslinerTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TranslinerTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TranslinerTheme.primaryRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: TranslinerTheme.gray600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  void _proceedToPaymentFromDialog(TripProvider tripProvider) {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context); // Close dialog
    _proceedToPayment(tripProvider);
  }

  int _getCrossAxisCount(int totalSeats) {
    if (totalSeats <= 14) return 4; // 2+2 layout
    if (totalSeats <= 25) return 5; // 2+3 layout
    return 4; // Default to 2+2 for larger buses
  }

  Color _getSeatColor(dynamic seat, bool isSelected) {
    if (isSelected) return TranslinerTheme.infoBlue;
    if (seat.isAvailable) return TranslinerTheme.successGreen;
    return TranslinerTheme.errorRed;
  }

  Color _getSeatIconColor(dynamic seat, bool isSelected) {
    return TranslinerTheme.white;
  }

  Widget _buildSeatLegend() {
    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seat Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: TranslinerTheme.successGreen,
                icon: Icons.airline_seat_recline_normal,
                label: 'Available',
              ),
              _buildLegendItem(
                color: TranslinerTheme.infoBlue,
                icon: Icons.airline_seat_recline_normal,
                label: 'Selected',
              ),
              _buildLegendItem(
                color: TranslinerTheme.errorRed,
                icon: Icons.airline_seat_recline_normal,
                label: 'Occupied',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: TranslinerTheme.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: TranslinerTheme.gray600),
        ),
      ],
    );
  }

  Widget _buildSelectedSeatsInfo(TripProvider tripProvider) {
    final trip = tripProvider.getCurrentTrip();
    final farePerSeat = double.tryParse(trip?['fare']?.toString() ?? '0') ?? 0;
    final totalFare = farePerSeat * tripProvider.selectedSeats.length;

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Seats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: tripProvider.selectedSeats.map((seatNo) {
              return Chip(
                label: Text('Seat $seatNo'),
                backgroundColor: TranslinerTheme.infoBlue,
                labelStyle: const TextStyle(color: TranslinerTheme.white),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: TranslinerTheme.white,
                ),
                onDeleted: () => tripProvider.deselectSeat(seatNo),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tripProvider.selectedSeats.length} seat(s) selected',
                style: const TextStyle(color: TranslinerTheme.gray600),
              ),
              Text(
                'Total: KES ${totalFare.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TranslinerTheme.charcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(TripProvider tripProvider) {
    final trip = tripProvider.getCurrentTrip();
    final farePerSeat = double.tryParse(trip?['fare']?.toString() ?? '0') ?? 0;
    final totalFare = farePerSeat * tripProvider.selectedSeats.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TranslinerTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tripProvider.selectedSeats.length} seat(s)',
                    style: const TextStyle(
                      color: TranslinerTheme.gray600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'KES ${totalFare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TranslinerTheme.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _showBookingDialog(tripProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: TranslinerTheme.primaryRed,
                foregroundColor: TranslinerTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Seats',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment(TripProvider tripProvider) {
    final trip = tripProvider.getCurrentTrip();
    final farePerSeat = double.tryParse(trip?['fare']?.toString() ?? '0') ?? 0;
    final totalAmount = farePerSeat * tripProvider.selectedSeats.length;

    // Use GoRouter navigation
    context.go(
      '/trip/${widget.tripToken}/payment',
      extra: {
        'selectedSeats': tripProvider.selectedSeats,
        'passengerDetails': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'idNumber': _idNumberController.text.trim(),
        },
        'totalAmount': totalAmount,
        'trip': trip,
      },
    );
  }
}
