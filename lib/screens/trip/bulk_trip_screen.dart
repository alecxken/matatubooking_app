import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/transliner_theme.dart';

class BulkTripScreen extends StatefulWidget {
  const BulkTripScreen({super.key});

  @override
  State<BulkTripScreen> createState() => _BulkTripScreenState();
}

class _BulkTripScreenState extends State<BulkTripScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedTemplate;
  DateTime? _startDate;
  DateTime? _endDate;

  // Mock templates - Replace with actual API data
  final List<Map<String, dynamic>> _templates = [
    {
      'id': '1',
      'name': 'Weekday Morning Nairobi-Kisii',
      'days': 'Monday to Friday',
      'description': '4 trips daily: 6:00 AM, 9:00 AM, 12:00 PM, 3:00 PM',
    },
    {
      'id': '2',
      'name': 'Weekend Nairobi-Migori',
      'days': 'Saturday, Sunday',
      'description': '3 trips daily: 7:00 AM, 1:00 PM, 6:00 PM',
    },
    {
      'id': '3',
      'name': 'Daily Nairobi-Kitengela Shuttle',
      'days': 'All days',
      'description': '8 trips daily from 6:00 AM to 9:00 PM',
    },
  ];

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _generateTrips() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTemplate == null) {
      _showError('Please select a template');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Please select start and end dates');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Call bulk trip generation API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        final days = _endDate!.difference(_startDate!).inDays + 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bulk trips will be generated for $days days!',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      _showError('Failed to generate trips: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: TranslinerTheme.errorRed,
      ),
    );
  }

  Map<String, dynamic>? get _selectedTemplateData {
    if (_selectedTemplate == null) return null;
    return _templates.firstWhere((t) => t['id'] == _selectedTemplate);
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
          'Bulk Generate Trips',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildFormCard(),
              if (_selectedTemplateData != null) ...[
                const SizedBox(height: 16),
                _buildTemplatePreview(),
              ],
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TranslinerTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TranslinerTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: TranslinerTheme.successGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Generation',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a template to automatically create multiple trips based on the template\'s schedule and date range.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TranslinerShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Selection
          Text(
            'Template',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TranslinerTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTemplate,
            decoration: InputDecoration(
              filled: true,
              fillColor: TranslinerTheme.gray100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: Text(
              'Choose Template',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.gray600,
              ),
            ),
            items: _templates.map((template) {
              return DropdownMenuItem<String>(
                value: template['id'],
                child: Text(
                  template['name'],
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTemplate = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a template';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Templates define recurring trip patterns and schedules',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: TranslinerTheme.gray600,
            ),
          ),
          const SizedBox(height: 20),

          // Date Range
          Row(
            children: [
              Expanded(child: _buildStartDateField()),
              const SizedBox(width: 12),
              Expanded(child: _buildEndDateField()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Start Date',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TranslinerTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: TranslinerTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _startDate != null
                        ? DateFormat('MMM d, y').format(_startDate!)
                        : 'Select',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: _startDate != null
                          ? TranslinerTheme.charcoal
                          : TranslinerTheme.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'First day to generate trips',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: TranslinerTheme.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'End Date',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.charcoal,
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: TranslinerTheme.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectEndDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TranslinerTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: TranslinerTheme.primaryRed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _endDate != null
                        ? DateFormat('MMM d, y').format(_endDate!)
                        : 'Select',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: _endDate != null
                          ? TranslinerTheme.charcoal
                          : TranslinerTheme.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last day to generate trips',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: TranslinerTheme.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatePreview() {
    final template = _selectedTemplateData!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TranslinerTheme.gray200),
        boxShadow: TranslinerShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: TranslinerTheme.infoBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Template Preview',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TranslinerTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewRow('Template', template['name']),
          _buildPreviewRow('Days', template['days']),
          _buildPreviewRow('Schedule', template['description']),
          if (_startDate != null && _endDate != null) ...[
            const Divider(height: 24),
            _buildPreviewRow(
              'Duration',
              '${_endDate!.difference(_startDate!).inDays + 1} days',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TranslinerTheme.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateTrips,
        style: ElevatedButton.styleFrom(
          backgroundColor: TranslinerTheme.successGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Generate Trips',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
