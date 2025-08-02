import 'package:flutter/material.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  bool _enableTax = true;
  bool _inclusiveTax = false;
  final _vatRateController = TextEditingController(text: '13.0');
  final _serviceChargeController = TextEditingController(text: '10.0');
  
  final List<TaxRule> _taxRules = [
    TaxRule(name: 'VAT', rate: 13.0, isActive: true, description: 'Value Added Tax'),
    TaxRule(name: 'Service Charge', rate: 10.0, isActive: true, description: 'Service charge on dine-in'),
    TaxRule(name: 'Local Tax', rate: 2.0, isActive: false, description: 'Local municipality tax'),
  ];

  @override
  void dispose() {
    _vatRateController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tax Configuration',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage tax rates and rules for your restaurant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // General Tax Settings
            _buildSection(
              title: 'General Settings',
              icon: Icons.settings,
              children: [
                _buildSwitchTile(
                  title: 'Enable Tax System',
                  subtitle: 'Turn on/off tax calculation',
                  value: _enableTax,
                  onChanged: (value) => setState(() => _enableTax = value),
                ),
                _buildSwitchTile(
                  title: 'Inclusive Tax',
                  subtitle: 'Tax included in item prices',
                  value: _inclusiveTax,
                  onChanged: (value) => setState(() => _inclusiveTax = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Default Tax Rates
            _buildSection(
              title: 'Default Tax Rates',
              icon: Icons.percent,
              children: [
                _buildTaxRateField(
                  label: 'VAT Rate (%)',
                  controller: _vatRateController,
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                _buildTaxRateField(
                  label: 'Service Charge (%)',
                  controller: _serviceChargeController,
                  icon: Icons.room_service,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tax Rules Management
            _buildSection(
              title: 'Tax Rules',
              icon: Icons.rule,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _taxRules.length,
                  itemBuilder: (context, index) {
                    return _buildTaxRuleCard(_taxRules[index], index);
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _addNewTaxRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Tax Rule'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tax Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tax Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total active tax rate: ${_calculateTotalTaxRate()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tax calculation: ${_inclusiveTax ? 'Inclusive' : 'Exclusive'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Tax Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
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

  Widget _buildTaxRateField({
    required String label,
    required TextEditingController controller,
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
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            suffixText: '%',
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
        ),
      ],
    );
  }

  Widget _buildTaxRuleCard(TaxRule rule, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rule.isActive ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: rule.isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  rule.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Rate: ${rule.rate}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: rule.isActive,
            onChanged: (value) {
              setState(() {
                _taxRules[index] = rule.copyWith(isActive: value);
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  double _calculateTotalTaxRate() {
    return _taxRules
        .where((rule) => rule.isActive)
        .fold(0.0, (sum, rule) => sum + rule.rate);
  }

  void _addNewTaxRule() {
    // TODO: Implement add new tax rule dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new tax rule feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class TaxRule {
  final String name;
  final double rate;
  final bool isActive;
  final String description;

  TaxRule({
    required this.name,
    required this.rate,
    required this.isActive,
    required this.description,
  });

  TaxRule copyWith({
    String? name,
    double? rate,
    bool? isActive,
    String? description,
  }) {
    return TaxRule(
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}
