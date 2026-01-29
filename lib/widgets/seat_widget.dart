import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../utils/constants.dart';

class SeatWidget extends StatelessWidget {
  final SeatModel seat;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getSeatColor(),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getSeatIcon(), color: _getIconColor(), size: 24),
            const SizedBox(height: 2),
            Text(
              seat.seatNo.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            if (seat.isBooked && seat.passenger != null)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _getStatusIndicatorColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSeatColor() {
    if (isSelected) {
      return AppColors.seatSelected.withOpacity(0.8);
    }

    switch (seat.status) {
      case 'booked':
        return AppColors.seatBooked.withOpacity(0.8);
      case 'available':
        return AppColors.seatAvailable.withOpacity(0.8);
      default:
        return AppColors.seatDisabled.withOpacity(0.8);
    }
  }

  IconData _getSeatIcon() {
    if (seat.isBooked) {
      return Icons.event_seat;
    }
    return Icons.event_seat_outlined;
  }

  Color _getIconColor() {
    if (isSelected) {
      return Colors.white;
    }

    switch (seat.status) {
      case 'booked':
        return Colors.white;
      case 'available':
        return Colors.white;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getTextColor() {
    if (isSelected) {
      return Colors.white;
    }

    switch (seat.status) {
      case 'booked':
        return Colors.white;
      case 'available':
        return Colors.white;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusIndicatorColor() {
    if (seat.passenger?.bookingStatus.toLowerCase() == 'confirmed') {
      return AppColors.statusSuccess;
    } else if (seat.passenger?.bookingStatus.toLowerCase() == 'pending') {
      return AppColors.statusWarning;
    } else if (seat.passenger?.bookingStatus.toLowerCase() == 'cancelled') {
      return AppColors.statusError;
    }
    return AppColors.statusInfo;
  }
}

// Alternative seat widget for different layouts
class CompactSeatWidget extends StatelessWidget {
  final SeatModel seat;
  final bool isSelected;
  final VoidCallback onTap;

  const CompactSeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getSeatColor(),
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            seat.seatNo.toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeatColor() {
    if (isSelected) return AppColors.seatSelected;
    if (seat.isBooked) return AppColors.seatBooked;
    if (seat.isAvailable) return AppColors.seatAvailable;
    return AppColors.seatDisabled;
  }

  Color _getTextColor() {
    return Colors.white;
  }
}

// Seat status indicator widget
class SeatStatusIndicator extends StatelessWidget {
  final String status;
  final int count;

  const SeatStatusIndicator({
    super.key,
    required this.status,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_seat, size: 16, color: _getStatusColor()),
          const SizedBox(width: 4),
          Text(
            '$count ${status.toLowerCase()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.seatAvailable;
      case 'booked':
        return AppColors.seatBooked;
      case 'selected':
        return AppColors.seatSelected;
      default:
        return AppColors.seatDisabled;
    }
  }
}
