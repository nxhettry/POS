import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'finance_list_item.dart';
import 'daybook_screen.dart';
import 'parties_screen.dart';

enum FinanceSection { daybookRecord, parties, reports }

class FinanceMenuItem {
  final FinanceSection section;
  final String title;
  final IconData icon;

  FinanceMenuItem({
    required this.section,
    required this.title,
    required this.icon,
  });
}

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  FinanceSection _selectedSection = FinanceSection.parties;

  final List<FinanceMenuItem> _menuItems = [
    FinanceMenuItem(
      section: FinanceSection.daybookRecord,
      title: 'Daybook Record',
      icon: Icons.book,
    ),
    FinanceMenuItem(
      section: FinanceSection.parties,
      title: 'Parties',
      icon: Icons.people,
    ),
    FinanceMenuItem(
      section: FinanceSection.reports,
      title: 'Financial Reports',
      icon: Icons.analytics,
    ),
  ];

  Widget _getContentWidget() {
    switch (_selectedSection) {
      case FinanceSection.daybookRecord:
        return const DaybookScreen();
      case FinanceSection.parties:
        return const PartiesScreen();
      case FinanceSection.reports:
        return _buildPlaceholderScreen('Financial Reports', 'Financial reports coming soon');
    }
  }

  Widget _buildPlaceholderScreen(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: ResponsiveUtils.isExtraSmallDesktop(context) ? 300 : 350,
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
                padding: ResponsiveUtils.getPadding(context, base: 24),
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green[700],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Finance',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                              ),
                              Text(
                                'Manage your finances',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Padding(
                  padding: ResponsiveUtils.getPadding(context, base: 16),
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FinanceListItem(
                          title: item.title,
                          icon: item.icon,
                          isSelected: _selectedSection == item.section,
                          onTap: () {
                            setState(() {
                              _selectedSection = item.section;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!, width: 1.0),
            ),
            child: _getContentWidget(),
          ),
        ),
      ],
    );
  }
}
