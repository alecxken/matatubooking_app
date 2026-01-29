import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/transliner_theme.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String tripToken;
  final List<int> selectedSeats;
  final Map<String, String> passengerDetails;
  final double totalAmount;
  final Map<String, dynamic> trip;

  const PaymentScreen({
    super.key,
    required this.tripToken,
    required this.selectedSeats,
    required this.passengerDetails,
    required this.totalAmount,
    required this.trip,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isProcessing = false;
  bool _autoPayMpesa = true;
  final _formKey = GlobalKey<FormState>();

  // Payment method controllers
  final _mpesaPhoneController = TextEditingController();
  final _referenceController = TextEditingController();

  // M-Pesa payment tracking
  Timer? _paymentStatusTimer;
  Timer? _autoCompleteTimer;
  String? _mpesaCheckoutRequestId;
  bool _awaitingMpesaConfirmation = false;
  int _remainingSeconds = 120; // 2 minutes

  // Booking confirmation
  bool _bookingConfirmed = false;
  String? _bookingReference;
  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    _mpesaPhoneController.text = widget.passengerDetails['phone'] ?? '';
  }

  @override
  void dispose() {
    _mpesaPhoneController.dispose();
    _referenceController.dispose();
    _paymentStatusTimer?.cancel();
    _autoCompleteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text(_bookingConfirmed ? 'Booking Confirmed' : 'Payment'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: TranslinerTheme.white,
        elevation: 0,
      ),
      body: _bookingConfirmed
          ? _buildBookingConfirmation()
          : _buildPaymentForm(),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripSummary(),
                  const SizedBox(height: 20),
                  _buildPassengerInfo(),
                  const SizedBox(height: 20),
                  _buildSeatsSummary(),
                  const SizedBox(height: 20),
                  _buildPaymentMethods(),
                  const SizedBox(height: 20),
                  _buildPaymentDetails(),
                  const SizedBox(height: 20),
                  _buildTotalSummary(),
                  if (_awaitingMpesaConfirmation) ...[
                    const SizedBox(height: 20),
                    _buildMpesaStatusCard(),
                  ],
                ],
              ),
            ),
          ),
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildBookingConfirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSuccessHeader(),
          const SizedBox(height: 20),
          _buildBookingDetails(),
          const SizedBox(height: 20),
          _buildQRCode(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      decoration: TranslinerDecorations.premiumCard.copyWith(
        color: TranslinerTheme.successGreen.withOpacity(0.1),
        border: Border.all(
          color: TranslinerTheme.successGreen.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TranslinerTheme.successGreen,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reference: ${_bookingReference ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Payment verification will continue in background.\nYou will receive SMS confirmation once payment is processed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TranslinerTheme.gray600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Passenger',
            '${widget.passengerDetails['firstName']} ${widget.passengerDetails['lastName']}',
          ),
          _buildDetailRow('Phone', widget.passengerDetails['phone'] ?? ''),
          _buildDetailRow('Trip', widget.trip['route']?.toString() ?? ''),
          _buildDetailRow(
            'Date & Time',
            '${widget.trip['departure_date']} at ${widget.trip['departure_time']}',
          ),
          _buildDetailRow(
            'Vehicle',
            widget.trip['vehicle']?.toString() ?? 'TBA',
          ),
          _buildDetailRow(
            'Seats',
            widget.selectedSeats.map((s) => 'Seat $s').join(', '),
          ),
          _buildDetailRow(
            'Amount',
            'KES ${widget.totalAmount.toStringAsFixed(0)}',
          ),
          _buildDetailRow('Payment Method', _selectedPaymentMethod),
          if (_selectedPaymentMethod == 'M-Pesa')
            _buildDetailRow('Status', 'Pending Payment Confirmation'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: TranslinerTheme.gray600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TranslinerTheme.charcoal,
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
      'reference': _bookingReference,
      'trip_token': widget.tripToken,
      'seats': widget.selectedSeats.join(','),
      'amount': widget.totalAmount,
      'passenger':
          '${widget.passengerDetails['firstName']} ${widget.passengerDetails['lastName']}',
      'phone': widget.passengerDetails['phone'],
    };

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Booking QR Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TranslinerTheme.gray600),
            ),
            child: QrImageView(
              data: qrData.toString(),
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Show this QR code to the conductor for verification',
            textAlign: TextAlign.center,
            style: TextStyle(color: TranslinerTheme.gray600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Generate Receipt/PDF Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _generateReceipt,
            icon: const Icon(Icons.receipt_long),
            label: const Text('Generate Receipt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Share Booking Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _shareBooking,
            icon: const Icon(Icons.share),
            label: const Text('Share Booking'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TranslinerTheme.primaryRed,
              side: const BorderSide(color: TranslinerTheme.primaryRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Done Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: _goBack,
            style: TextButton.styleFrom(
              foregroundColor: TranslinerTheme.gray600,
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildMpesaStatusCard() {
    return Container(
      decoration: TranslinerDecorations.premiumCard.copyWith(
        color: TranslinerTheme.infoBlue.withOpacity(0.05),
        border: Border.all(color: TranslinerTheme.infoBlue.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: TranslinerTheme.infoBlue,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waiting for M-Pesa confirmation...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.charcoal,
                      ),
                    ),
                    Text(
                      'Auto-completing in ${_remainingSeconds}s',
                      style: const TextStyle(
                        color: TranslinerTheme.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_remainingSeconds) / 120,
            backgroundColor: TranslinerTheme.gray600,
            valueColor: AlwaysStoppedAnimation<Color>(TranslinerTheme.infoBlue),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your phone for the M-Pesa payment prompt. Booking will be confirmed automatically if payment takes longer than expected.',
            style: TextStyle(color: TranslinerTheme.gray600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ... [Previous widget methods remain the same: _buildTripSummary, _buildPassengerInfo, etc.] ...

  Widget _buildTripSummary() {
    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
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
                      widget.trip['route']?.toString() ?? 'Unknown Route',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TranslinerTheme.charcoal,
                      ),
                    ),
                    Text(
                      '${widget.trip['departure_date']} at ${widget.trip['departure_time']}',
                      style: const TextStyle(
                        color: TranslinerTheme.gray600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Passenger Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.passengerDetails['firstName']} ${widget.passengerDetails['lastName']}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            widget.passengerDetails['phone'] ?? '',
            style: const TextStyle(color: TranslinerTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsSummary() {
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: widget.selectedSeats.map((seatNo) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: TranslinerTheme.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seat $seatNo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = ['M-Pesa', 'Cash', 'Bank Transfer'];

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map(
            (method) => RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) =>
                  setState(() => _selectedPaymentMethod = value!),
              activeColor: TranslinerTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedPaymentMethod != 'M-Pesa') return Container();

    return Container(
      decoration: TranslinerDecorations.premiumCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'M-Pesa Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mpesaPhoneController,
            decoration: const InputDecoration(
              labelText: 'M-Pesa Phone Number',
              prefixIcon: Icon(Icons.phone_android),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Auto-pay with STK Push'),
            subtitle: const Text('Receive payment prompt instantly'),
            value: _autoPayMpesa,
            onChanged: (value) =>
                setState(() => _autoPayMpesa = value ?? false),
            activeColor: TranslinerTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      decoration: TranslinerDecorations.premiumCard.copyWith(
        color: TranslinerTheme.primaryRed.withOpacity(0.05),
        border: Border.all(color: TranslinerTheme.primaryRed.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.charcoal,
            ),
          ),
          Text(
            'KES ${widget.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TranslinerTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: (_isProcessing || _awaitingMpesaConfirmation)
              ? null
              : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: TranslinerTheme.primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Processing...'),
                  ],
                )
              : Text(
                  _getPaymentButtonText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  String _getPaymentButtonText() {
    if (_awaitingMpesaConfirmation) return 'Awaiting Payment...';
    switch (_selectedPaymentMethod) {
      case 'M-Pesa':
        return _autoPayMpesa ? 'Pay with M-Pesa STK' : 'Confirm Booking';
      case 'Cash':
        return 'Confirm Booking (Pay at Office)';
      default:
        return 'Confirm Booking';
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final bookingData = {
        'token': widget.tripToken,
        'first_name': widget.passengerDetails['firstName'],
        'other_name': widget.passengerDetails['lastName'],
        'phone': widget.passengerDetails['phone'],
        'selectedSeats': widget.selectedSeats.join(','),
        'route': widget.trip['route']?.toString(),
        'payment_method': _selectedPaymentMethod,
        'auto_pay': _selectedPaymentMethod == 'M-Pesa' && _autoPayMpesa,
      };

      final response = await _submitBooking(bookingData);

      if (response['success'] == true) {
        final responseData = response['data'];
        _bookingReference = responseData['booking_reference'];
        _bookingData = responseData;

        if (_selectedPaymentMethod == 'M-Pesa' &&
            _autoPayMpesa &&
            responseData['payment_initiated'] == true) {
          _mpesaCheckoutRequestId =
              responseData['mpesa']['checkout_request_id'];
          setState(() {
            _isProcessing = false;
            _awaitingMpesaConfirmation = true;
          });
          _startPaymentMonitoring();
        } else {
          _handleBookingSuccess();
        }
      }
    } catch (e) {
      _showErrorDialog('Booking failed: $e');
    } finally {
      if (!_awaitingMpesaConfirmation) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _startPaymentMonitoring() {
    // Start countdown timer
    _autoCompleteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleAutoComplete();
      }
    });

    // Start payment status checking
    _paymentStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  void _handleAutoComplete() {
    _paymentStatusTimer?.cancel();
    _autoCompleteTimer?.cancel();

    setState(() {
      _awaitingMpesaConfirmation = false;
      _bookingConfirmed = true;
    });

    // Update trip provider
    final tripProvider = context.read<TripProvider>();
    tripProvider.clearSelectedSeats();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getBookingStatus(
        widget.tripToken,
        widget.passengerDetails['phone']!,
      );

      if (response['success'] == true) {
        final bookings = response['data']['bookings'] as List;
        if (bookings.isNotEmpty && bookings.first['status'] == 'Paid') {
          _paymentStatusTimer?.cancel();
          _autoCompleteTimer?.cancel();
          _handlePaymentSuccess();
        }
      }
    } catch (e) {
      // Continue monitoring
    }
  }

  void _handlePaymentSuccess() {
    setState(() {
      _awaitingMpesaConfirmation = false;
      _bookingConfirmed = true;
    });

    final tripProvider = context.read<TripProvider>();
    tripProvider.clearSelectedSeats();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Payment confirmed! Booking is fully paid.'),
        backgroundColor: TranslinerTheme.successGreen,
      ),
    );
  }

  void _handleBookingSuccess() {
    setState(() {
      _bookingConfirmed = true;
    });

    final tripProvider = context.read<TripProvider>();
    tripProvider.clearSelectedSeats();
  }

  Future<Map<String, dynamic>> _submitBooking(Map<String, dynamic> data) async {
    final apiService = ApiService();
    return await apiService.submitMobileBooking(data);
  }

  Future<void> _generateReceipt() async {
    try {
      final pdf = await _createPDF();
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating receipt: $e')));
    }
  }

  Future<Uint8List> _createPDF() async {
    final pdf = pw.Document();

    // Load logo (you'll need to add this to pubspec.yaml assets)
    // final logoData = await rootBundle.load('assets/images/logo.svg');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TRANSLINER CRUISER',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Bus Booking Receipt',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  // pw.SvgImage(svg: logoSvg, width: 80, height: 80), // Add logo here
                ],
              ),
              pw.SizedBox(height: 30),

              // Booking details
              pw.Text(
                'BOOKING DETAILS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _pdfRow('Booking Reference:', _bookingReference ?? 'N/A'),
              _pdfRow(
                'Passenger:',
                '${widget.passengerDetails['firstName']} ${widget.passengerDetails['lastName']}',
              ),
              _pdfRow('Phone:', widget.passengerDetails['phone'] ?? ''),
              _pdfRow('Trip Route:', widget.trip['route']?.toString() ?? ''),
              _pdfRow(
                'Date & Time:',
                '${widget.trip['departure_date']} at ${widget.trip['departure_time']}',
              ),
              _pdfRow('Vehicle:', widget.trip['vehicle']?.toString() ?? 'TBA'),
              _pdfRow(
                'Seats:',
                widget.selectedSeats.map((s) => 'Seat $s').join(', '),
              ),
              _pdfRow(
                'Amount:',
                'KES ${widget.totalAmount.toStringAsFixed(0)}',
              ),
              _pdfRow('Payment Method:', _selectedPaymentMethod),
              _pdfRow(
                'Status:',
                _selectedPaymentMethod == 'M-Pesa'
                    ? 'Pending Payment Confirmation'
                    : 'Confirmed',
              ),

              pw.SizedBox(height: 30),

              // QR Code
              pw.Text(
                'QR CODE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.Container(
                width: 150,
                height: 150,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: _bookingReference ?? 'N/A',
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Show this QR code to the conductor for verification',
                style: pw.TextStyle(fontSize: 12),
              ),

              pw.Spacer(),

              // Footer
              pw.Text(
                'Generated on: ${DateTime.now().toString()}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Thank you for choosing Transliner Cruiser!',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label)),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  void _shareBooking() {
    final shareText =
        '''
🚌 TRANSLINER CRUISER BOOKING

Booking Reference: ${_bookingReference ?? 'N/A'}
Passenger: ${widget.passengerDetails['firstName']} ${widget.passengerDetails['lastName']}
Trip: ${widget.trip['route']}
Date: ${widget.trip['departure_date']} at ${widget.trip['departure_time']}
Seats: ${widget.selectedSeats.map((s) => 'Seat $s').join(', ')}
Amount: KES ${widget.totalAmount.toStringAsFixed(0)}

Thank you for choosing Transliner Cruiser!
''';

    Share.share(shareText);
  }

  void _goBack() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
