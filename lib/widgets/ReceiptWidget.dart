import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../theme/transliner_theme.dart';

class ReceiptWidget extends StatelessWidget {
  final String bookingReference;
  final Map<String, String> passengerDetails;
  final Map<String, dynamic> trip;
  final List<int> selectedSeats;
  final double totalAmount;
  final String paymentMethod;

  const ReceiptWidget({
    super.key,
    required this.bookingReference,
    required this.passengerDetails,
    required this.trip,
    required this.selectedSeats,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: GlobalKey(),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildBookingDetails(),
                const SizedBox(height: 30),
                _buildQRCode(),
                const SizedBox(height: 30),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Logo placeholder (you can replace with Image.asset)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: TranslinerTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRANSLINER CRUISER',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TranslinerTheme.primaryRed,
                    ),
                  ),
                  const Text(
                    'Bus Booking Receipt',
                    style: TextStyle(
                      fontSize: 16,
                      color: TranslinerTheme.gray600,
                    ),
                  ),
                  Text(
                    'Generated: ${DateTime.now().toString().substring(0, 19)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TranslinerTheme.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 2,
          color: TranslinerTheme.primaryRed,
        ),
      ],
    );
  }

  Widget _buildBookingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BOOKING DETAILS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TranslinerTheme.charcoal,
          ),
        ),
        const SizedBox(height: 16),

        _buildDetailRow(
          'Booking Reference:',
          bookingReference,
          isHighlight: true,
        ),
        _buildDetailRow(
          'Passenger:',
          '${passengerDetails['firstName']} ${passengerDetails['lastName']}',
        ),
        _buildDetailRow('Phone:', passengerDetails['phone'] ?? ''),
        const SizedBox(height: 12),

        _buildDetailRow('Trip Route:', trip['route']?.toString() ?? ''),
        _buildDetailRow(
          'Date & Time:',
          '${trip['departure_date']} at ${trip['departure_time']}',
        ),
        _buildDetailRow('Vehicle:', trip['vehicle']?.toString() ?? 'TBA'),
        _buildDetailRow('Driver:', trip['driver']?.toString() ?? 'TBA'),
        const SizedBox(height: 12),

        _buildDetailRow(
          'Seats:',
          selectedSeats.map((s) => 'Seat $s').join(', '),
        ),
        _buildDetailRow(
          'Amount:',
          'KES ${totalAmount.toStringAsFixed(0)}',
          isHighlight: true,
        ),
        _buildDetailRow('Payment Method:', paymentMethod),
        _buildDetailRow(
          'Status:',
          paymentMethod == 'M-Pesa'
              ? 'Pending Payment Confirmation'
              : 'Confirmed',
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isHighlight
                    ? TranslinerTheme.primaryRed
                    : TranslinerTheme.gray600,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight
                    ? TranslinerTheme.primaryRed
                    : TranslinerTheme.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    final qrData = {
      'type': 'booking',
      'reference': bookingReference,
      'amount': totalAmount,
      'passenger':
          '${passengerDetails['firstName']} ${passengerDetails['lastName']}',
      'phone': passengerDetails['phone'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERIFICATION QR CODE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TranslinerTheme.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: TranslinerTheme.gray600, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: qrData.toString(),
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: TranslinerTheme.charcoal,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Show this QR code to the conductor for verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TranslinerTheme.gray600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: TranslinerTheme.gray600,
        ),
        const SizedBox(height: 16),
        const Text(
          'IMPORTANT INFORMATION',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: TranslinerTheme.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Please arrive at the station 15 minutes before departure\n'
          '• Keep this receipt for verification during travel\n'
          '• For M-Pesa payments, confirmation will be sent via SMS\n'
          '• For support, contact: +254 700 000 000',
          style: TextStyle(
            fontSize: 12,
            color: TranslinerTheme.gray600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Thank you for choosing Transliner Cruiser!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.primaryRed,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  // Method to capture widget as image for sharing
  static Future<void> shareReceipt(GlobalKey repaintBoundaryKey) async {
    try {
      RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save and share the image
      await Share.shareXFiles([
        XFile.fromData(
          pngBytes,
          name: 'transliner_receipt.png',
          mimeType: 'image/png',
        ),
      ], text: 'Transliner Cruiser Booking Receipt');
    } catch (e) {
      print('Error sharing receipt: $e');
    }
  }
}

// Usage example widget
class ReceiptScreen extends StatefulWidget {
  final String bookingReference;
  final Map<String, String> passengerDetails;
  final Map<String, dynamic> trip;
  final List<int> selectedSeats;
  final double totalAmount;
  final String paymentMethod;

  const ReceiptScreen({
    super.key,
    required this.bookingReference,
    required this.passengerDetails,
    required this.trip,
    required this.selectedSeats,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: const Text('Booking Receipt'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ReceiptWidget.shareReceipt(_repaintBoundaryKey),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: ReceiptWidget(
          bookingReference: widget.bookingReference,
          passengerDetails: widget.passengerDetails,
          trip: widget.trip,
          selectedSeats: widget.selectedSeats,
          totalAmount: widget.totalAmount,
          paymentMethod: widget.paymentMethod,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ReceiptWidget.shareReceipt(_repaintBoundaryKey),
                icon: const Icon(Icons.share),
                label: const Text('Share Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TranslinerTheme.primaryRed,
                  side: const BorderSide(color: TranslinerTheme.primaryRed),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TranslinerTheme.primaryRed,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
