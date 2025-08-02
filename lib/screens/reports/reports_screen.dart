import 'package:flutter/material.dart';
import '../../models.dart';
import '../../data/sales.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedPeriod = '1day';
  final List<String> periods = [
    '1day',
    '7days',
    '1 month',
    '3months',
    '6 months',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSales = _getFilteredSales();
    final reportData = _calculateReportData(filteredSales);
    final mostSoldItems = _getMostSoldItems(filteredSales);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Handle download action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: periods
                  .map((period) => _buildPeriodChip(period))
                  .toList(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards for Sales, Products, and Revenue
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Sales Count',
                          '${reportData['salesCount']}',
                          Icons.receipt_long,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Products Sold',
                          '${reportData['productsSold']}',
                          Icons.shopping_cart,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'Total Sales Amount',
                    'Rs. ${reportData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                    Icons.attach_money,
                    Colors.orange,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 24),

                  // Transaction Summary
                  _buildTransactionSummary(reportData),

                  const SizedBox(height: 24),

                  // Tables Section - Most Sold Items and Sales Records
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Most Sold Items Table
                      Expanded(child: _buildMostSoldItemsTable(mostSoldItems)),
                      const SizedBox(width: 16),
                      // Sales Records Table
                      Expanded(child: _buildSalesRecordsTable(filteredSales)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary(Map<String, dynamic> reportData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Subtotal',
            'Rs. ${reportData['subtotal']?.toStringAsFixed(2) ?? '0.00'}',
          ),
          _buildSummaryRow(
            'Tax',
            'Rs. ${reportData['tax']?.toStringAsFixed(2) ?? '0.00'}',
          ),
          _buildSummaryRow(
            'Discount',
            'Rs. ${reportData['discount']?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const Divider(),
          _buildSummaryRow(
            'Total',
            'Rs. ${reportData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMostSoldItemsTable(List<Map<String, dynamic>> mostSoldItems) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Most Sold Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Revenue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: mostSoldItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: Text(
                            item['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('${item['quantity']}')),
                      DataCell(
                        Text('Rs. ${item['revenue'].toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesRecordsTable(List<Sales> sales) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Sales Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 8,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Table',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: sales.map((sale) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            sale.invoiceNo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 60,
                          child: Text(
                            sale.table,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 70,
                          child: Text(
                            sale.orderType,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('Rs. ${sale.total.toStringAsFixed(2)}')),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${sale.timestamp.month}/${sale.timestamp.day}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions
  List<Sales> _getFilteredSales() {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod) {
      case '1day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case '7days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '1 month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6 months':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return salesData
        .where((sale) => sale.timestamp.isAfter(startDate))
        .toList();
  }

  Map<String, dynamic> _calculateReportData(List<Sales> sales) {
    if (sales.isEmpty) {
      return {
        'salesCount': 0,
        'productsSold': 0,
        'totalAmount': 0.0,
        'subtotal': 0.0,
        'tax': 0.0,
        'discount': 0.0,
      };
    }

    int totalProductsSold = 0;
    double totalAmount = 0.0;
    double totalSubtotal = 0.0;
    double totalTax = 0.0;
    double totalDiscount = 0.0;

    for (final sale in sales) {
      totalProductsSold += sale.items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );
      totalAmount += sale.total;
      totalSubtotal += sale.subtotal;
      totalTax += sale.tax;
      totalDiscount += sale.discount;
    }

    return {
      'salesCount': sales.length,
      'productsSold': totalProductsSold,
      'totalAmount': totalAmount,
      'subtotal': totalSubtotal,
      'tax': totalTax,
      'discount': totalDiscount,
    };
  }

  List<Map<String, dynamic>> _getMostSoldItems(List<Sales> sales) {
    final Map<String, Map<String, dynamic>> itemData = {};

    for (final sale in sales) {
      for (final cartItem in sale.items) {
        final itemName = cartItem.item['item_name'] as String;
        final quantity = cartItem.quantity;
        final revenue = cartItem.totalPrice;

        if (itemData.containsKey(itemName)) {
          itemData[itemName]!['quantity'] += quantity;
          itemData[itemName]!['revenue'] += revenue;
        } else {
          itemData[itemName] = {
            'name': itemName,
            'quantity': quantity,
            'revenue': revenue,
          };
        }
      }
    }

    final sortedItems = itemData.values.toList()
      ..sort((a, b) => b['quantity'].compareTo(a['quantity']));

    return sortedItems.take(10).toList();
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? Colors.black87 : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
