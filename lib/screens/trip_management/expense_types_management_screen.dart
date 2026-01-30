import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/expense_template_model.dart';
import '../../providers/trip_management_provider.dart';
import '../../theme/transliner_theme.dart';

class ExpenseTypesManagementScreen extends StatefulWidget {
  const ExpenseTypesManagementScreen({super.key});

  @override
  State<ExpenseTypesManagementScreen> createState() =>
      _ExpenseTypesManagementScreenState();
}

class _ExpenseTypesManagementScreenState
    extends State<ExpenseTypesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<TripManagementProvider>();
      await Future.wait([
        provider.fetchExpenseTemplates(),
        provider.fetchRoutes(), // For route dropdown
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ExpenseTemplateModel> _getFilteredExpenses(
      List<ExpenseTemplateModel> expenses) {
    if (_searchQuery.isEmpty) return expenses;

    return expenses.where((expense) {
      return expense.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (expense.vehicleType?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Home',
        ),
        title: Text(
          'Expense Types Management',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildExpensesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Expense Type',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TranslinerTheme.primaryRed,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search expense types...',
          hintStyle: GoogleFonts.montserrat(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: TranslinerTheme.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: TranslinerTheme.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: TranslinerTheme.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildExpensesList() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        if (_isLoading && provider.expenseTemplates.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: TranslinerTheme.primaryRed,
            ),
          );
        }

        final filteredExpenses =
            _getFilteredExpenses(provider.expenseTemplates);

        if (filteredExpenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.money_off : Icons.search_off,
                  size: 64,
                  color: TranslinerTheme.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No expense types found'
                      : 'No expense types match your search',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: TranslinerTheme.gray600,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first expense type',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: TranslinerTheme.gray500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          color: TranslinerTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              return _buildExpenseCard(expense);
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(ExpenseTemplateModel expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TranslinerTheme.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showExpenseDialog(expense: expense),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TranslinerTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.money_rounded,
                      color: TranslinerTheme.errorRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'KES ${expense.amount.toStringAsFixed(0)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TranslinerTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: expense.isActive
                          ? TranslinerTheme.successGreen.withOpacity(0.1)
                          : TranslinerTheme.gray300,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: expense.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray400,
                      ),
                    ),
                    child: Text(
                      expense.status,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: expense.isActive
                            ? TranslinerTheme.successGreen
                            : TranslinerTheme.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: TranslinerTheme.gray600),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showExpenseDialog(expense: expense);
                      } else if (value == 'delete') {
                        _confirmDelete(expense);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit,
                                size: 20, color: TranslinerTheme.infoBlue),
                            const SizedBox(width: 8),
                            Text('Edit', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 20, color: TranslinerTheme.errorRed),
                            const SizedBox(width: 8),
                            Text('Delete', style: GoogleFonts.montserrat()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (expense.description != null ||
                  expense.vehicleType != null ||
                  expense.route != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                if (expense.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          size: 14,
                          color: TranslinerTheme.gray600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expense.description!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: TranslinerTheme.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    if (expense.vehicleType != null)
                      Expanded(
                        child: _buildInfoChip(
                          Icons.directions_bus,
                          expense.vehicleType!,
                          TranslinerTheme.infoBlue,
                        ),
                      ),
                    if (expense.vehicleType != null && expense.route != null)
                      const SizedBox(width: 8),
                    if (expense.route != null)
                      Expanded(
                        child: _buildInfoChip(
                          Icons.route,
                          expense.route!,
                          TranslinerTheme.successGreen,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog({ExpenseTemplateModel? expense}) {
    final isEditing = expense != null;
    final nameController = TextEditingController(text: expense?.name ?? '');
    final amountController =
        TextEditingController(text: expense?.amount.toString() ?? '');
    final descriptionController =
        TextEditingController(text: expense?.description ?? '');
    final vehicleTypeController =
        TextEditingController(text: expense?.vehicleType ?? '');
    String selectedStatus = expense?.status ?? 'Active';
    String? selectedRoute = expense?.route;

    final provider = context.read<TripManagementProvider>();
    final routes = provider.routes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TranslinerTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: TranslinerTheme.errorRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEditing ? 'Edit Expense Type' : 'Add New Expense Type',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Expense Name *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Fuel, Toll Fee, Parking',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (KES) *',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., 5000',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'Brief description of the expense',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vehicleTypeController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Type (Optional)',
                      labelStyle: GoogleFonts.montserrat(),
                      hintText: 'e.g., Bus, Minibus, Van',
                      hintStyle:
                          GoogleFonts.montserrat(color: TranslinerTheme.gray400),
                      prefixIcon: const Icon(Icons.directions_bus),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Leave empty to apply to all vehicle types',
                      helperStyle: GoogleFonts.montserrat(fontSize: 11),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRoute,
                    decoration: InputDecoration(
                      labelText: 'Route (Optional)',
                      labelStyle: GoogleFonts.montserrat(),
                      prefixIcon: const Icon(Icons.route),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Leave empty to apply to all routes',
                      helperStyle: GoogleFonts.montserrat(fontSize: 11),
                    ),
                    hint: Text('Select route',
                        style: GoogleFonts.montserrat()),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('All routes',
                            style: GoogleFonts.montserrat(
                                fontStyle: FontStyle.italic)),
                      ),
                      ...routes.map((route) {
                        return DropdownMenuItem(
                          value: route.name,
                          child: Text(route.name,
                              style: GoogleFonts.montserrat()),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRoute = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.montserrat(),
                      prefixIcon: const Icon(Icons.toggle_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Active', 'Inactive'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status, style: GoogleFonts.montserrat()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: TranslinerTheme.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                // Validation
                if (nameController.text.trim().isEmpty) {
                  _showError(context, 'Please enter expense name');
                  return;
                }
                if (amountController.text.trim().isEmpty) {
                  _showError(context, 'Please enter amount');
                  return;
                }

                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  _showError(context, 'Please enter valid amount');
                  return;
                }

                final newExpense = ExpenseTemplateModel(
                  id: expense?.id,
                  token: expense?.token,
                  name: nameController.text.trim(),
                  amount: amount,
                  description: descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null,
                  vehicleType: vehicleTypeController.text.trim().isNotEmpty
                      ? vehicleTypeController.text.trim()
                      : null,
                  route: selectedRoute,
                  status: selectedStatus,
                );

                Navigator.of(context).pop();

                final provider = context.read<TripManagementProvider>();
                bool success;

                if (isEditing) {
                  success = await provider.updateExpenseTemplate(
                      expense.id!, newExpense);
                } else {
                  final created =
                      await provider.createExpenseTemplate(newExpense);
                  success = created != null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? isEditing
                                ? 'Expense type updated successfully'
                                : 'Expense type created successfully'
                            : 'Failed to ${isEditing ? 'update' : 'create'} expense type',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: success
                          ? TranslinerTheme.successGreen
                          : TranslinerTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: TranslinerTheme.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update' : 'Create',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: TranslinerTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(ExpenseTemplateModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TranslinerTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: TranslinerTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Expense Type',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: TranslinerTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete expense type "${expense.name}"? This action cannot be undone.',
          style: GoogleFonts.montserrat(
            color: TranslinerTheme.gray700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: TranslinerTheme.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<TripManagementProvider>()
          .deleteExpenseTemplate(expense.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Expense type deleted successfully'
                  : 'Failed to delete expense type',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor:
                success ? TranslinerTheme.successGreen : TranslinerTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
