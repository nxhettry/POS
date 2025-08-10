import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/data_repository.dart';
import 'add_category_dialog.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expense? expense;
  final VoidCallback onExpenseAdded;

  const AddExpenseDialog({
    super.key,
    this.expense,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _receiptController = TextEditingController();

  final DataRepository _dataRepository = DataRepository();
  List<ExpensesCategory> _categories = [];
  List<PaymentMethod> _paymentMethods = [];
  List<Party> _parties = [];
  
  int? _selectedCategoryId;
  int? _selectedPaymentMethodId;
  int? _selectedPartyId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;

  // Check if the selected payment method is credit
  bool get _isCreditPayment {
    if (_selectedPaymentMethodId == null) return false;
    final paymentMethod = _paymentMethods.firstWhere(
      (method) => method.id == _selectedPaymentMethodId,
      orElse: () => PaymentMethod(name: '', type: 'cash'),
    );
    return paymentMethod.type.toLowerCase() == 'credit';
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description ?? '';
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _receiptController.text = widget.expense!.receipt ?? '';
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedPaymentMethodId = widget.expense!.paymentMethodId;
      _selectedPartyId = widget.expense!.partyId;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _dataRepository.fetchExpenseCategories();
      final paymentMethods = await _dataRepository.fetchActivePaymentMethods();
      final parties = await _dataRepository.fetchActiveParties();
      
      setState(() {
        _categories = categories;
        _paymentMethods = paymentMethods;
        _parties = parties;
        
        if (widget.expense == null) {
          // Set defaults for new expense
          if (categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
          if (paymentMethods.isNotEmpty) {
            _selectedPaymentMethodId = paymentMethods.first.id;
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onCategoryAdded: () async {
          // Reload categories after adding new one
          try {
            final categories = await _dataRepository.fetchExpenseCategories();
            setState(() {
              _categories = categories;
              // Select the newly added category (last one)
              if (categories.isNotEmpty) {
                _selectedCategoryId = categories.last.id;
              }
            });
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error reloading categories: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || 
        _selectedCategoryId == null || 
        _selectedPaymentMethodId == null) {
      return;
    }

    // Additional validation for credit payments
    if (_isCreditPayment && _selectedPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier/party for credit transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.expense != null) {
        // Update existing expense
        final updateData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          'amount': double.parse(_amountController.text),
          'paymentMethodId': _selectedPaymentMethodId!,
          'date': _selectedDate.toIso8601String(),
          'categoryId': _selectedCategoryId!,
          'partyId': _selectedPartyId,
          'receipt': _receiptController.text.trim().isEmpty ? null : _receiptController.text.trim(),
        };
        await _dataRepository.updateExpense(widget.expense!.id!, updateData);
      } else {
        // Create new expense - for now, using createdBy = 1 (should be current user ID)
        await _dataRepository.createExpense(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          paymentMethodId: _selectedPaymentMethodId!,
          date: _selectedDate,
          categoryId: _selectedCategoryId!,
          partyId: _selectedPartyId,
          receipt: _receiptController.text.trim().isEmpty ? null : _receiptController.text.trim(),
          createdBy: 1, // TODO: Replace with actual current user ID
        );
      }

      widget.onExpenseAdded();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense != null
                  ? 'Expense updated successfully!'
                  : 'Expense added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.expense != null
                            ? 'Edit Expense'
                            : 'Add New Expense',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Amount (NPR) *',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter an amount';
                                      }
                                      final amount = double.tryParse(value);
                                      if (amount == null || amount <= 0) {
                                        return 'Please enter a valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedPaymentMethodId,
                                    decoration: const InputDecoration(
                                      labelText: 'Payment Method *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _paymentMethods.map((method) {
                                      return DropdownMenuItem(
                                        value: method.id,
                                        child: Text(method.name),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        _selectedPaymentMethodId = newValue;
                                        // Reset party selection when payment method changes
                                        if (!_isCreditPayment) {
                                          _selectedPartyId = null;
                                        }
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select a payment method';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: _selectedCategoryId,
                                          decoration: const InputDecoration(
                                            labelText: 'Category *',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: _categories.map((category) {
                                            return DropdownMenuItem(
                                              value: category.id,
                                              child: Text(category.name),
                                            );
                                          }).toList(),
                                          onChanged: (int? newValue) {
                                            setState(() {
                                              _selectedCategoryId = newValue;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a category';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: _showAddCategoryDialog,
                                        icon: const Icon(Icons.add_circle_outline),
                                        tooltip: 'Add New Category',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.withOpacity(0.1),
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    value: _selectedPartyId,
                                    decoration: InputDecoration(
                                      labelText: _isCreditPayment 
                                          ? 'Supplier/Party *' 
                                          : 'Party (Optional)',
                                      border: const OutlineInputBorder(),
                                      filled: _isCreditPayment,
                                      fillColor: _isCreditPayment 
                                          ? Colors.red.withOpacity(0.05)
                                          : null,
                                    ),
                                    items: [
                                      if (!_isCreditPayment)
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('Select Party (Optional)'),
                                        ),
                                      if (_isCreditPayment)
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('Select Supplier *'),
                                        ),
                                      ..._parties.map((party) {
                                        return DropdownMenuItem(
                                          value: party.id,
                                          child: Text('${party.name} (${party.type})'),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        _selectedPartyId = newValue;
                                      });
                                    },
                                    validator: _isCreditPayment 
                                        ? (value) {
                                            if (value == null) {
                                              return 'Supplier is required for credit payments';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isCreditPayment)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Credit payment selected. Please select the supplier/party for this transaction.',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_isCreditPayment) const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: _selectDate,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _receiptController,
                              decoration: const InputDecoration(
                                labelText: 'Receipt/Reference (Optional)',
                                border: OutlineInputBorder(),
                                helperText: 'Receipt number or file reference',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(widget.expense != null ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
