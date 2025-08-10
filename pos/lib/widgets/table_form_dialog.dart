import 'package:flutter/material.dart';
import '../models/models.dart' as models;

class TableFormDialog extends StatefulWidget {
  final models.Table? table;
  final Function(String name, String status) onSave;

  const TableFormDialog({Key? key, this.table, required this.onSave})
    : super(key: key);

  @override
  State<TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<TableFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedStatus = 'available';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'available',
      'label': 'Available',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'occupied',
      'label': 'Occupied',
      'icon': Icons.person,
      'color': Colors.orange,
    },
    {
      'value': 'reserved',
      'label': 'Reserved',
      'icon': Icons.bookmark,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.table != null) {
      _nameController.text = widget.table!.name;
      _selectedStatus = widget.table!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(_nameController.text.trim(), _selectedStatus);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('TableFormDialog error: $e');
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up error message
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        if (errorMessage.startsWith('Failed to create table: ')) {
          errorMessage = errorMessage.substring(24);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.table == null ? 'Add New Table' : 'Edit Table',
                    style: const TextStyle(
                      fontSize: 24,
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

              Text(
                'Table Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter table name (e.g., Table 1, VIP Room)',
                  prefixIcon: const Icon(Icons.table_restaurant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a table name';
                  }
                  if (value.trim().length < 2) {
                    return 'Table name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Table Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              for (final option in _statusOptions)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStatus = option['value'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedStatus == option['value']
                              ? option['color']
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        color: _selectedStatus == option['value']
                            ? option['color'].withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'],
                            color: _selectedStatus == option['value']
                                ? option['color']
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedStatus == option['value']
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: _selectedStatus == option['value']
                                  ? option['color']
                                  : Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Radio<String>(
                            value: option['value'],
                            groupValue: _selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                            activeColor: option['color'],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.table == null
                                  ? 'Add Table'
                                  : 'Update Table',
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
