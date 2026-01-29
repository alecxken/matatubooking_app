import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/transliner_theme.dart';
import '../../services/api_service.dart';

class TripExpensesScreen extends StatefulWidget {
  final String tripToken;
  final Map<String, dynamic> tripData;

  const TripExpensesScreen({
    super.key,
    required this.tripToken,
    required this.tripData,
  });

  @override
  State<TripExpensesScreen> createState() => _TripExpensesScreenState();
}

class _TripExpensesScreenState extends State<TripExpensesScreen> {
  List<Map<String, dynamic>> expenses = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      await _loadDefaultExpenses();
      await _loadTripExpenses();
    } catch (e) {
      _showError('Failed to load expenses: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadDefaultExpenses() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getDefaultExpenses(
        widget.tripData['vehicle_type'] ?? '',
      );

      if (response['success']) {
        final defaultExpenses = response['data'] as List;

        for (var expense in defaultExpenses) {
          expenses.add({
            'id': null,
            'expense_name': expense['name'],
            'amount': TextEditingController(text: '${expense['amount']}'),
            'description': TextEditingController(),
            'date': DateTime.now(),
            'isDefault': true,
            'isModified': false,
          });
        }
      }
    } catch (e) {
      print('Error loading default expenses: $e');
    }
  }

  Future<void> _loadTripExpenses() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getTripExpenses(widget.tripToken);

      if (response['success']) {
        final tripExpenses = response['expenses'] as List? ?? [];

        for (var expense in tripExpenses) {
          // Check if this expense already exists in defaults
          final existingIndex = expenses.indexWhere(
            (e) =>
                e['expense_name'] ==
                (expense['expense'] ?? expense['expense_name']),
          );

          final expenseName =
              expense['expense'] ?? expense['expense_name'] ?? 'Unknown';
          final expenseAmount = expense['amount'] is String
              ? double.tryParse(expense['amount']) ?? 0.0
              : (expense['amount']?.toDouble() ?? 0.0);

          if (existingIndex != -1) {
            // Update existing default expense with saved values
            expenses[existingIndex]['id'] = expense['id'];
            expenses[existingIndex]['amount'].text = expenseAmount.toString();
            expenses[existingIndex]['description'].text =
                expense['description'] ?? '';
            expenses[existingIndex]['isModified'] = true;
          } else {
            // Add custom expense
            expenses.add({
              'id': expense['id'],
              'expense_name': expenseName,
              'amount': TextEditingController(text: expenseAmount.toString()),
              'description': TextEditingController(
                text: expense['description'] ?? '',
              ),
              'date':
                  DateTime.tryParse(expense['date'] ?? '') ?? DateTime.now(),
              'isDefault': false,
              'isModified': true,
            });
          }
        }
      }
    } catch (e) {
      print('Error loading trip expenses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TranslinerTheme.lightGray,
      appBar: AppBar(
        title: Text('Trip Expenses'),
        backgroundColor: TranslinerTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addCustomExpense,
              tooltip: 'Add Custom Expense',
            ),
        ],
      ),
      body: isLoading ? _buildLoading() : _buildContent(),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: isSaving ? null : _saveExpenses,
              backgroundColor: TranslinerTheme.primaryRed,
              icon: isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.save, color: Colors.white),
              label: Text(
                isSaving ? 'Saving...' : 'Save Expenses',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TranslinerTheme.primaryRed),
          SizedBox(height: 16),
          Text('Loading expenses...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTripInfo(),
        _buildExpensesSummary(),
        Expanded(child: _buildExpensesList()),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: TranslinerDecorations.premiumCard,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: TranslinerTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_bus, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tripData['route'] ?? 'Unknown Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TranslinerTheme.charcoal,
                  ),
                ),
                Text(
                  'Vehicle: ${widget.tripData['vehicle_type'] ?? 'N/A'}',
                  style: TextStyle(
                    color: TranslinerTheme.gray600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.tripToken,
                  style: TextStyle(
                    color: TranslinerTheme.gray600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesSummary() {
    final totalAmount = _calculateTotalExpenses();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: TranslinerDecorations.premiumCard,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: TextStyle(color: TranslinerTheme.gray600, fontSize: 14),
              ),
              Text(
                'KES ${_formatAmount(totalAmount)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TranslinerTheme.primaryRed,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Expense Items',
                style: TextStyle(color: TranslinerTheme.gray600, fontSize: 14),
              ),
              Text(
                '${expenses.length}',
                style: TextStyle(
                  fontSize: 20,
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

  Widget _buildExpensesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: TranslinerDecorations.premiumCard,
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: expense['isDefault']
                    ? TranslinerTheme.infoBlue
                    : TranslinerTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                expense['isDefault'] ? Icons.category : Icons.add_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              expense['expense_name'],
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'KES ${_formatAmount(double.tryParse(expense['amount'].text) ?? 0)}',
              style: TextStyle(
                color: TranslinerTheme.primaryRed,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: expense['isDefault']
                ? Icon(Icons.settings, size: 20)
                : IconButton(
                    icon: Icon(Icons.delete, color: TranslinerTheme.errorRed),
                    onPressed: () => _removeExpense(index),
                  ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: expense['amount'],
                      decoration: InputDecoration(
                        labelText: 'Amount (KES)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (_) => _markAsModified(index),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: expense['description'],
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                      onChanged: (_) => _markAsModified(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCustomExpense() {
    showDialog(
      context: context,
      builder: (context) => _AddExpenseDialog(
        onAdd: (name) {
          setState(() {
            expenses.add({
              'id': null,
              'expense_name': name,
              'amount': TextEditingController(text: '0'),
              'description': TextEditingController(),
              'date': DateTime.now(),
              'isDefault': false,
              'isModified': true,
            });
          });
        },
      ),
    );
  }

  void _removeExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Expense'),
        content: Text('Are you sure you want to remove this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => expenses.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TranslinerTheme.errorRed,
            ),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markAsModified(int index) {
    setState(() {
      expenses[index]['isModified'] = true;
    });
  }

  double _calculateTotalExpenses() {
    return expenses.fold(0.0, (sum, expense) {
      return sum + (double.tryParse(expense['amount'].text) ?? 0);
    });
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Future<void> _saveExpenses() async {
    setState(() => isSaving = true);

    try {
      final expensesToSave = expenses
          .where((e) => e['isModified'])
          .map((expense) {
            final amount = double.tryParse(expense['amount'].text) ?? 0;
            if (amount <= 0) return null;

            return {
              'id': expense['id'],
              'expense_name': expense['expense_name'], // Changed from 'name'
              'amount': amount,
              'description': expense['description'].text,
              'date': expense['date'].toIso8601String(),
            };
          })
          .where((e) => e != null)
          .toList();

      if (expensesToSave.isEmpty) {
        _showError('Please enter valid amounts for expenses');
        return;
      }

      final apiService = ApiService();
      final response = await apiService.addTripExpense(
        widget.tripToken,
        List<Map<String, dynamic>>.from(expensesToSave),
      );

      if (response['success']) {
        HapticFeedback.mediumImpact();
        _showSuccess('Expenses saved successfully');
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate changes were made
      } else {
        _showError(response['message'] ?? 'Failed to save expenses');
      }
    } catch (e) {
      _showError('Failed to save expenses: $e');
    } finally {
      setState(() => isSaving = false);
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

  @override
  void dispose() {
    for (var expense in expenses) {
      expense['amount']?.dispose();
      expense['description']?.dispose();
    }
    super.dispose();
  }
}

class _AddExpenseDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddExpenseDialog({required this.onAdd});

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Custom Expense'),
      content: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Expense Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onAdd(_nameController.text.trim());
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TranslinerTheme.primaryRed,
          ),
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
