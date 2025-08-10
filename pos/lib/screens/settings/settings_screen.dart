import 'package:flutter/material.dart';
import 'settings_list_item.dart';
import 'restaurant_info_screen.dart';
import 'sales_bill_screen.dart';
import 'tax_screen.dart';
import 'system_screen.dart';
import "./setup_screen.dart";

enum SettingsSection { restaurantInfo, salesBill, tax, system, setup }

class SettingsMenuItem {
  final SettingsSection section;
  final String title;
  final IconData icon;

  SettingsMenuItem({
    required this.section,
    required this.title,
    required this.icon,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSection _selectedSection = SettingsSection.restaurantInfo;

  final List<SettingsMenuItem> _menuItems = [
    SettingsMenuItem(
      section: SettingsSection.restaurantInfo,
      title: 'Restaurant Info',
      icon: Icons.restaurant,
    ),
    SettingsMenuItem(
      section: SettingsSection.salesBill,
      title: 'Sales Bill',
      icon: Icons.receipt_long,
    ),
    SettingsMenuItem(
      section: SettingsSection.tax,
      title: 'Tax',
      icon: Icons.percent,
    ),
    SettingsMenuItem(
      section: SettingsSection.system,
      title: 'System',
      icon: Icons.settings,
    ),
    SettingsMenuItem(
      section: SettingsSection.setup,
      title: 'Setup',
      icon: Icons.build,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: 350,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[50]!, Colors.grey[100]!],
            ),
            border: Border(
              right: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            Text(
                              'Configure your POS',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return SettingsListItem(
                        title: item.title,
                        icon: item.icon,
                        isSelected: _selectedSection == item.section,
                        onTap: () {
                          setState(() {
                            _selectedSection = item.section;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right Content Area
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: _buildSelectedScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedSection) {
      case SettingsSection.restaurantInfo:
        return const RestaurantInfoScreen();
      case SettingsSection.salesBill:
        return const SalesBillScreen();
      case SettingsSection.tax:
        return const TaxScreen();
      case SettingsSection.system:
        return const SystemScreen();
      case SettingsSection.setup:
        return const SetupScreen();
    }
  }
}
