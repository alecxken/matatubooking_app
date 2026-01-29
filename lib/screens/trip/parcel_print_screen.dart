import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

import '../../theme/transliner_theme.dart';

class ParcelPrintScreen extends StatefulWidget {
  final Map<String, dynamic> parcel;

  const ParcelPrintScreen({super.key, required this.parcel});

  @override
  State<ParcelPrintScreen> createState() => _ParcelPrintScreenState();
}

class _ParcelPrintScreenState extends State<ParcelPrintScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool isGeneratingSticker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Parcel Label'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareSticker,
            tooltip: 'Share Label',
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _printSticker,
            tooltip: 'Print Label',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Preview Card
            Container(
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Parcel Label Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TranslinerTheme.charcoal,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildParcelSticker(),
                ],
              ),
            ),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelSticker() {
    final parcelId = widget.parcel['parcel_id'] ?? 'Unknown ID';
    final trackingData =
        'TRANSLINER-$parcelId-${DateTime.now().millisecondsSinceEpoch}';

    return Screenshot(
      controller: _screenshotController,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TranslinerTheme.primaryRed, width: 2),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: TranslinerTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_bus, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'TRANSLINER CRUISER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Parcel Tracking Label',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Parcel ID Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TranslinerTheme.primaryRed.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TranslinerTheme.primaryRed.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PARCEL ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TranslinerTheme.primaryRed,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          parcelId,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TranslinerTheme.charcoal,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Sender & Recipient Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoSection(
                          'FROM',
                          widget.parcel['sender_name'] ?? 'Unknown',
                          widget.parcel['sender_mobile'] ?? '',
                          Icons.person_outline,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.arrow_forward,
                          color: TranslinerTheme.primaryRed,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoSection(
                          'TO',
                          widget.parcel['recipient_name'] ?? 'Unknown',
                          widget.parcel['recipient_mobile'] ?? '',
                          Icons.person,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Destination & Type
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'DESTINATION',
                          widget.parcel['destination'] ?? 'Unknown',
                          Icons.location_on,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          'TYPE',
                          widget.parcel['parcel_type'] ?? 'General',
                          Icons.category,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // QR Code Section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: trackingData,
                          version: QrVersions.auto,
                          size: 120,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Scan to Track',
                          style: TextStyle(
                            fontSize: 11,
                            color: TranslinerTheme.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Footer Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Value: KES ${widget.parcel['value'] ?? 0}',
                              style: TextStyle(
                                fontSize: 11,
                                color: TranslinerTheme.charcoal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Fee: KES ${widget.parcel['fee'] ?? 0}',
                              style: TextStyle(
                                fontSize: 11,
                                color: TranslinerTheme.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
                          style: TextStyle(
                            fontSize: 9,
                            color: TranslinerTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Strip
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: TranslinerTheme.charcoal,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                'Handle with Care • Keep Dry • This Side Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    String name,
    String phone,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: TranslinerTheme.primaryRed),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: TranslinerTheme.primaryRed,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.charcoal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (phone.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(
              phone,
              style: TextStyle(fontSize: 10, color: TranslinerTheme.gray600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: TranslinerTheme.primaryRed),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: TranslinerTheme.primaryRed,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.charcoal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Print Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: isGeneratingSticker ? null : _printSticker,
            icon: isGeneratingSticker
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.print, color: Colors.white),
            label: Text(
              isGeneratingSticker ? 'Generating...' : 'Print Label',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),

        SizedBox(height: 12),

        // Share Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _shareSticker,
            icon: Icon(Icons.share, color: TranslinerTheme.primaryRed),
            label: Text(
              'Share Label',
              style: TextStyle(
                color: TranslinerTheme.primaryRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: TranslinerTheme.primaryRed, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Track Parcel Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _trackParcel,
            icon: Icon(Icons.track_changes, color: Colors.white),
            label: Text(
              'Track This Parcel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.successGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printSticker() async {
    setState(() => isGeneratingSticker = true);

    try {
      HapticFeedback.mediumImpact();

      // Capture screenshot
      final imageBytes = await _screenshotController.capture();

      if (imageBytes != null) {
        // Here you would typically send to a printer
        // For now, we'll show a success message and share the image

        await Share.shareXFiles([
          XFile.fromData(
            imageBytes,
            name: 'parcel_label_${widget.parcel['parcel_id']}.png',
            mimeType: 'image/png',
          ),
        ], text: 'Parcel Label: ${widget.parcel['parcel_id']}');

        _showSuccess('Label ready for printing!');
      }
    } catch (e) {
      _showError('Failed to generate label: $e');
    } finally {
      setState(() => isGeneratingSticker = false);
    }
  }

  Future<void> _shareSticker() async {
    try {
      HapticFeedback.lightImpact();

      final imageBytes = await _screenshotController.capture();

      if (imageBytes != null) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              imageBytes,
              name: 'parcel_label_${widget.parcel['parcel_id']}.png',
              mimeType: 'image/png',
            ),
          ],
          text:
              'Parcel Label: ${widget.parcel['parcel_id']} - Transliner Cruiser',
        );
      }
    } catch (e) {
      _showError('Failed to share label: $e');
    }
  }

  void _trackParcel() {
    HapticFeedback.lightImpact();

    // Navigate to tracking screen or show tracking info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Parcel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parcel ID: ${widget.parcel['parcel_id']}'),
            SizedBox(height: 8),
            Text('Status: ${_formatStatus(widget.parcel['status'])}'),
            SizedBox(height: 8),
            Text('Destination: ${widget.parcel['destination']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to full tracking screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.primaryRed,
            ),
            child: Text('Full Details', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'in_transit':
        return 'In Transit';
      case 'pending':
        return 'Pending';
      case 'received':
        return 'Received';
      case 'collected':
        return 'Collected';
      case 'returned':
        return 'Returned';
      default:
        return 'Unknown';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.errorRed,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TranslinerTheme.successGreen,
      ),
    );
  }
}
