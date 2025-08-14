import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';

class PartyFormDialog extends StatefulWidget {
  final Party? party;
  final Function(Party) onSave;

  const PartyFormDialog({
    super.key,
    this.party,
    required this.onSave,
  });

  @override
  State<PartyFormDialog> createState() => _PartyFormDialogState();
}

class _PartyFormDialogState extends State<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'customer';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.party != null) {
      _nameController.text = widget.party!.name;
      _phoneController.text = widget.party!.phone;
      _emailController.text = widget.party!.email ?? '';
      _addressController.text = widget.party!.address;
      _balanceController.text = widget.party!.balance.toString();
      _selectedType = widget.party!.type;
      _isActive = widget.party!.isActive;
    } else {
      _balanceController.text = '0.0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveParty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final party = Party(
      id: widget.party?.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim(),
      balance: double.tryParse(_balanceController.text) ?? 0.0,
      isActive: _isActive,
      createdAt: widget.party?.createdAt,
      updatedAt: widget.party?.updatedAt,
    );

    try {
      await widget.onSave(party);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: ResponsiveUtils.getScreenWidth(context) > 1366 ? 600 : 
               ResponsiveUtils.getScreenWidth(context) > 800 ? 500 : 
               MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    widget.party != null ? Icons.edit : Icons.add,
                    size: 28,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.party != null ? 'Edit Party' : 'Add New Party',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          hintText: 'Enter party name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Type and Status row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'customer',
                                  child: Text('Customer'),
                                ),
                                DropdownMenuItem(
                                  value: 'supplier',
                                  child: Text('Supplier'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Type is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Active'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter email address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          hintText: 'Enter address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Balance field
                      TextFormField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                          labelText: 'Opening Balance',
                          hintText: 'Enter opening balance',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveParty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(widget.party != null ? 'Update' : 'Add'),
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
