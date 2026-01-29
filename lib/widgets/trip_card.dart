import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../utils/constants.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.marginSmall),
              _buildRouteInfo(),
              const SizedBox(height: AppSizes.marginSmall),
              _buildDetailsRow(),
              const SizedBox(height: AppSizes.marginSmall),
              _buildStatusRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            trip.routeDisplayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'KES ${trip.fare.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${trip.origin} → ${trip.destination}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          trip.formattedDepartureTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        if (trip.vehicle != null) ...[
          _buildDetailItem(Icons.directions_bus, trip.vehicle!),
          const SizedBox(width: AppSizes.marginMedium),
        ],
        if (trip.driver != null) ...[
          _buildDetailItem(Icons.person, trip.driver!),
          const Spacer(),
        ] else
          const Spacer(),
        _buildSeatInfo(),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSeatInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSeatStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_seat, size: 14, color: _getSeatStatusColor()),
          const SizedBox(width: 4),
          Text(
            '${trip.availableSeats}/${trip.totalSeats} available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getSeatStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        _buildStatusIndicator(),
        const Spacer(),
        if (trip.isNearlyFull)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.statusWarning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Nearly Full',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.statusWarning,
              ),
            ),
          ),
        if (trip.isFull)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.statusError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Full',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.statusError,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          trip.status,
          style: TextStyle(
            fontSize: 12,
            color: _getStatusColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getSeatStatusColor() {
    if (trip.isFull) return AppColors.statusError;
    if (trip.isNearlyFull) return AppColors.statusWarning;
    return AppColors.statusSuccess;
  }

  Color _getStatusColor() {
    switch (trip.status.toLowerCase()) {
      case 'active':
        return AppColors.statusSuccess;
      case 'cancelled':
        return AppColors.statusError;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.statusInfo;
    }
  }
}
