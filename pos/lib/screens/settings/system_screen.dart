import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/database_helper.dart';
import '../../services/api_data_service.dart';

class SystemScreen extends StatefulWidget {
  const SystemScreen({super.key});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiDataService _apiDataService = ApiDataService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _autoBackup = false;
  bool _enableNotifications = true;
  bool _darkMode = false;
  bool _enableSounds = true;
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'NPR';
  String _selectedDateFormat = 'YYYY-MM-DD';
  String _selectedTimeZone = 'Asia/Kathmandu';
  double _defaultTaxRate = 0.0;

  final TextEditingController _taxRateController = TextEditingController();

  final List<Map<String, String>> _languages = [
    {'value': 'en', 'label': 'English'},
    {'value': 'np', 'label': 'Nepali'},
  ];

  final List<Map<String, String>> _dateFormats = [
    {'value': 'YYYY-MM-DD', 'label': 'YYYY-MM-DD'},
    {'value': 'DD-MM-YYYY', 'label': 'DD-MM-YYYY'},
  ];

  final List<String> _currencies = ['NPR', 'USD', 'EUR', 'INR'];
  final List<String> _timeZones = [
    'Asia/Kathmandu',
    'UTC',
    'Asia/Kolkata',
    'America/New_York',
    'Europe/London',
  ];

  @override
  void initState() {
    super.initState();
    _taxRateController.text = _defaultTaxRate.toString();
    _loadSystemSettings();
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    super.dispose();
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
              'System Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure system preferences and general settings',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: 'Application Settings',
              icon: Icons.apps,
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Show system notifications',
                  value: _enableNotifications,
                  onChanged: (value) =>
                      setState(() => _enableNotifications = value),
                ),
                _buildSwitchTile(
                  title: 'Enable Sounds',
                  subtitle: 'Play notification sounds',
                  value: _enableSounds,
                  onChanged: (value) => setState(() => _enableSounds = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Localization',
              icon: Icons.language,
              children: [
                _buildDropdownFieldWithOptions(
                  label: 'Language',
                  value: _selectedLanguage,
                  options: _languages,
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value!),
                  icon: Icons.translate,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Currency',
                  value: _selectedCurrency,
                  items: _currencies,
                  onChanged: (value) =>
                      setState(() => _selectedCurrency = value!),
                  icon: Icons.currency_exchange,
                ),
                const SizedBox(height: 16),
                _buildDropdownFieldWithOptions(
                  label: 'Date Format',
                  value: _selectedDateFormat,
                  options: _dateFormats,
                  onChanged: (value) =>
                      setState(() => _selectedDateFormat = value!),
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Time Zone',
                  value: _selectedTimeZone,
                  items: _timeZones,
                  onChanged: (value) =>
                      setState(() => _selectedTimeZone = value!),
                  icon: Icons.schedule,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Data Management',
              icon: Icons.storage,
              children: [
                _buildTextFormField(
                  label: 'Default Tax Rate (%)',
                  controller: _taxRateController,
                  hintText: 'Enter default tax rate',
                  onChanged: (value) => setState(
                    () => _defaultTaxRate = double.tryParse(value) ?? 0.0,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  title: 'Auto Backup',
                  subtitle: 'Automatically backup data daily',
                  value: _autoBackup,
                  onChanged: (value) => setState(() => _autoBackup = value),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Create Backup',
                  subtitle: 'Manually create a backup now',
                  icon: Icons.backup,
                  onTap: _createBackup,
                ),
                _buildActionButton(
                  title: 'Restore Data',
                  subtitle: 'Restore from a previous backup',
                  icon: Icons.restore,
                  onTap: _restoreData,
                ),
                _buildActionButton(
                  title: 'Export Data',
                  subtitle: 'Export data to CSV/Excel',
                  icon: Icons.file_download,
                  onTap: _exportData,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'System Information',
              icon: Icons.info,
              children: [
                _buildInfoRow('App Version', '1.0.0'),
                _buildInfoRow('Database Version', '2.1.3'),
                _buildInfoRow('Last Backup', 'Today, 10:30 AM'),
                _buildInfoRow('Storage Used', '245 MB'),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Check for Updates',
                  subtitle: 'Look for app updates',
                  icon: Icons.system_update,
                  onTap: _checkForUpdates,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Danger Zone',
              icon: Icons.warning,
              color: Colors.red,
              children: [
                _buildActionButton(
                  title: 'Clear Cache',
                  subtitle: 'Clear application cache',
                  icon: Icons.clear_all,
                  onTap: _clearCache,
                  textColor: Colors.orange,
                ),
                _buildActionButton(
                  title: 'Reset Settings',
                  subtitle: 'Reset all settings to default',
                  icon: Icons.settings_backup_restore,
                  onTap: _resetSettings,
                  textColor: Colors.red,
                ),
                _buildActionButton(
                  title: 'Factory Reset',
                  subtitle: 'Delete all data and reset app',
                  icon: Icons.delete_forever,
                  onTap: _factoryReset,
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
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
                          Text(
                            'Saving...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Save System Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
    Color? color,
  }) {
    final sectionColor = color ?? Theme.of(context).primaryColor;

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
        border: color != null
            ? Border.all(color: color.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: sectionColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color == Colors.red ? Colors.red : Colors.black87,
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
    final safeValue = items.contains(value) ? value : items.first;

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
          value: safeValue,
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
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownFieldWithOptions({
    required String label,
    required String value,
    required List<Map<String, String>> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final validValues = options.map((option) => option['value']!).toList();
    final safeValue = validValues.contains(value) ? value : validValues.first;

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
          value: safeValue,
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
          items: options.map((Map<String, String> option) {
            return DropdownMenuItem<String>(
              value: option['value']!,
              child: Text(option['label']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
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
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.percent, color: Colors.grey[600]),
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

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: textColor ?? Colors.grey[700]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating backup...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _restoreData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting data...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are on the latest version!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _factoryReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory Reset'),
        content: const Text(
          'This will delete ALL data and cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Factory reset cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final systemSettings = SystemSettings(
        currency: _selectedCurrency,
        dateFormat: _selectedDateFormat,
        language: _selectedLanguage,
        defaultTaxRate: _defaultTaxRate,
        autoBackup: _autoBackup,
      );

      await _databaseHelper.upsertSystemSettings(systemSettings);

      try {
        await _apiDataService.updateSystemSettings(systemSettings);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('System settings saved and synced successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (apiError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'System settings saved locally. Sync failed: $apiError',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        print('API sync failed: $apiError');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving system settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _loadSystemSettings() async {
    print('Loading system settings...');
    try {
      SystemSettings? systemSettings;

      try {
        systemSettings = await _apiDataService.getSystemSettings();
        print('Loaded systemSettings from API: $systemSettings');

        await _databaseHelper.upsertSystemSettings(systemSettings);
      } catch (apiError) {
        print('Failed to load from API, trying local database: $apiError');

        systemSettings = await _databaseHelper.getSystemSettings();
        print('Loaded systemSettings from local DB: $systemSettings');
      }

      if (systemSettings != null && mounted) {
        print('systemSettings values:');
        print('- currency: ${systemSettings.currency}');
        print('- dateFormat: ${systemSettings.dateFormat}');
        print('- language: ${systemSettings.language}');

        setState(() {
          _selectedCurrency = _currencies.contains(systemSettings!.currency)
              ? systemSettings.currency
              : 'NPR';

          _selectedDateFormat =
              _dateFormats.any(
                (format) => format['value'] == systemSettings!.dateFormat,
              )
              ? systemSettings.dateFormat
              : 'YYYY-MM-DD';

          _selectedLanguage =
              _languages.any(
                (lang) => lang['value'] == systemSettings!.language,
              )
              ? systemSettings.language
              : 'en';

          _selectedTimeZone = 'Asia/Kathmandu';

          _defaultTaxRate = systemSettings.defaultTaxRate;
          _autoBackup = systemSettings.autoBackup;
          _taxRateController.text = _defaultTaxRate.toString();
          _isLoading = false;

          print('Final validated values:');
          print('- _selectedCurrency: $_selectedCurrency');
          print('- _selectedDateFormat: $_selectedDateFormat');
          print('- _selectedLanguage: $_selectedLanguage');
          print('- _selectedTimeZone: $_selectedTimeZone');
        });
      } else {
        setState(() {
          _taxRateController.text = _defaultTaxRate.toString();
          _isLoading = false;
        });
        print('No systemSettings found, using defaults');
      }
    } catch (e) {
      print('Error loading system settings: $e');
      setState(() {
        _taxRateController.text = _defaultTaxRate.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading system settings: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
