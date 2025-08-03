import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/database_helper.dart';

class SalesBillScreen extends StatefulWidget {
  const SalesBillScreen({super.key});

  @override
  State<SalesBillScreen> createState() => _SalesBillScreenState();
}

class _SalesBillScreenState extends State<SalesBillScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = true;
  bool _includeTax = true;
  bool _includeDiscount = true;
  bool _printCustomerCopy = true;
  bool _printKitchenCopy = false;
  String _selectedPaperSize = 'A4';
  String _selectedTemplate = 'Modern';

  final List<String> _paperSizes = ['A4', 'A5', 'Thermal 80mm', 'Thermal 58mm'];
  final List<String> _templates = ['Modern', 'Classic', 'Minimal', 'Detailed'];

  @override
  void initState() {
    super.initState();
    _loadBillSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Bill Configuration',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure bill printing settings and format options',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Bill Content Section
            _buildSection(
              title: 'Bill Content',
              icon: Icons.receipt_long,
              children: [
                _buildSwitchTile(
                  title: 'Include Tax Details',
                  subtitle: 'Show tax breakdown in bills',
                  value: _includeTax,
                  onChanged: (value) => setState(() => _includeTax = value),
                ),
                _buildSwitchTile(
                  title: 'Include Discount',
                  subtitle: 'Show discount information',
                  value: _includeDiscount,
                  onChanged: (value) => setState(() => _includeDiscount = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Printing Options Section
            _buildSection(
              title: 'Printing Options',
              icon: Icons.print,
              children: [
                _buildSwitchTile(
                  title: 'Print Customer Copy',
                  subtitle: 'Automatically print customer receipt',
                  value: _printCustomerCopy,
                  onChanged: (value) => setState(() => _printCustomerCopy = value),
                ),
                _buildSwitchTile(
                  title: 'Print Kitchen Copy',
                  subtitle: 'Send order to kitchen printer',
                  value: _printKitchenCopy,
                  onChanged: (value) => setState(() => _printKitchenCopy = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Format Settings Section
            _buildSection(
              title: 'Format Settings',
              icon: Icons.format_align_left,
              children: [
                _buildDropdownField(
                  label: 'Paper Size',
                  value: _selectedPaperSize,
                  items: _paperSizes,
                  onChanged: (value) => setState(() => _selectedPaperSize = value!),
                  icon: Icons.aspect_ratio,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Bill Template',
                  value: _selectedTemplate,
                  items: _templates,
                  onChanged: (value) => setState(() => _selectedTemplate = value!),
                  icon: Icons.style,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previewBill,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Preview Bill',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _previewBill() {
    // TODO: Implement bill preview functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill preview feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _saveSettings() async {
    try {
      final billSettings = BillSettings(
        includeTax: _includeTax,
        includeDiscount: _includeDiscount,
        printCustomerCopy: _printCustomerCopy,
        printKitchenCopy: _printKitchenCopy,
      );

      await _databaseHelper.upsertBillSettings(billSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBillSettings() async {
    try {
      final billSettings = await _databaseHelper.getBillSettings();
      if (billSettings != null && mounted) {
        setState(() {
          _includeTax = billSettings.includeTax;
          _includeDiscount = billSettings.includeDiscount;
          _printCustomerCopy = billSettings.printCustomerCopy;
          _printKitchenCopy = billSettings.printKitchenCopy;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bill settings: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
