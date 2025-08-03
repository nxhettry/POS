import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
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

  int currentPage = 0;
  final int itemsPerPage = 20;
  bool isExporting = false;

  @override
  Widget build(BuildContext context) {
    final filteredSales = _getFilteredSales();
    final reportData = _calculateReportData(filteredSales);
    final mostSoldItems = _getMostSoldItems(filteredSales);
    final paginatedSales = _getPaginatedSales(filteredSales);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          isExporting
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _exportToExcel,
                ),
        ],
      ),
      body: Column(
        children: [
          // Time Selection Bar
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
                  // Summary Cards
                  _buildSummaryCards(reportData),
                  
                  const SizedBox(height: 24),

                  // Most Sold Items Section
                  _buildMostSoldItemsSection(mostSoldItems),
                  
                  const SizedBox(height: 24),

                  // Sales Records Section with Pagination
                  _buildSalesRecordsSection(filteredSales, paginatedSales),
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
          currentPage = 0; // Reset pagination when period changes
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

  Widget _buildSummaryCards(Map<String, dynamic> reportData) {
    return Column(
      children: [
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
      ],
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

  Widget _buildMostSoldItemsSection(List<Map<String, dynamic>> mostSoldItems) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text(
                    'Rank',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Item Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Quantity Sold',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Revenue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: mostSoldItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRankColor(index),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['quantity']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${item['revenue'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSalesRecordsSection(List<Sales> allSales, List<Sales> paginatedSales) {
    final totalPages = (allSales.length / itemsPerPage).ceil();
    
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Total: ${allSales.length} records',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(
                  label: Text(
                    'Invoice No.',
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
                    'Order Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date & Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: paginatedSales.map((sale) {
                return DataRow(
                  cells: [
                    DataCell(Text(sale.invoiceNo)),
                    DataCell(Text(sale.table)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sale.orderType == 'Dine In' 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sale.orderType,
                          style: TextStyle(
                            color: sale.orderType == 'Dine In' 
                                ? Colors.blue
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${sale.items.fold(0, (sum, item) => sum + item.quantity)} items',
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${sale.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('MMM dd, yyyy\nhh:mm a').format(sale.timestamp),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          
          // Pagination Controls
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${(currentPage * itemsPerPage) + 1}-${(currentPage * itemsPerPage) + paginatedSales.length} of ${allSales.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: currentPage > 0
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      ...List.generate(
                        totalPages > 5 ? 5 : totalPages,
                        (index) {
                          int pageNumber;
                          if (totalPages <= 5) {
                            pageNumber = index;
                          } else {
                            if (currentPage < 3) {
                              pageNumber = index;
                            } else if (currentPage >= totalPages - 3) {
                              pageNumber = totalPages - 5 + index;
                            } else {
                              pageNumber = currentPage - 2 + index;
                            }
                          }
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = pageNumber;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: currentPage == pageNumber
                                    ? Colors.red
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: currentPage == pageNumber
                                      ? Colors.red
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                '${pageNumber + 1}',
                                style: TextStyle(
                                  color: currentPage == pageNumber
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: currentPage == pageNumber
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
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
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<Sales> _getPaginatedSales(List<Sales> sales) {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, sales.length);
    return sales.sublist(startIndex, endIndex);
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[600]!;
      case 2:
        return Colors.orange[700]!;
      default:
        return Colors.blue;
    }
  }

  Future<void> _exportToExcel() async {
    setState(() {
      isExporting = true;
    });

    try {
      final filteredSales = _getFilteredSales();
      final mostSoldItems = _getMostSoldItems(filteredSales);
      final reportData = _calculateReportData(filteredSales);

      var excel = excel_lib.Excel.createExcel();
      
      // Create Sales Summary Sheet
      var summarySheet = excel['Sales Summary'];
      
      // Add headers and data for summary
      summarySheet.cell(excel_lib.CellIndex.indexByString('A1')).value = excel_lib.TextCellValue('Sales Report Summary');
      summarySheet.cell(excel_lib.CellIndex.indexByString('A2')).value = excel_lib.TextCellValue('Period: $selectedPeriod');
      summarySheet.cell(excel_lib.CellIndex.indexByString('A3')).value = excel_lib.TextCellValue('Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}');
      
      summarySheet.cell(excel_lib.CellIndex.indexByString('A5')).value = excel_lib.TextCellValue('Metric');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B5')).value = excel_lib.TextCellValue('Value');
      
      summarySheet.cell(excel_lib.CellIndex.indexByString('A6')).value = excel_lib.TextCellValue('Total Sales Count');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B6')).value = excel_lib.IntCellValue(reportData['salesCount']);
      
      summarySheet.cell(excel_lib.CellIndex.indexByString('A7')).value = excel_lib.TextCellValue('Products Sold');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B7')).value = excel_lib.IntCellValue(reportData['productsSold']);
      
      summarySheet.cell(excel_lib.CellIndex.indexByString('A8')).value = excel_lib.TextCellValue('Total Sales Amount');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B8')).value = excel_lib.DoubleCellValue(reportData['totalAmount']);

      // Create Most Sold Items Sheet
      var mostSoldSheet = excel['Most Sold Items'];
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('A1')).value = excel_lib.TextCellValue('Rank');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('B1')).value = excel_lib.TextCellValue('Item Name');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('C1')).value = excel_lib.TextCellValue('Quantity Sold');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('D1')).value = excel_lib.TextCellValue('Total Revenue');

      for (int i = 0; i < mostSoldItems.length; i++) {
        final item = mostSoldItems[i];
        final row = i + 2;
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = excel_lib.IntCellValue(i + 1);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = excel_lib.TextCellValue(item['name']);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('C$row')).value = excel_lib.IntCellValue(item['quantity']);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('D$row')).value = excel_lib.DoubleCellValue(item['revenue']);
      }

      // Create Sales Records Sheet
      var salesSheet = excel['Sales Records'];
      salesSheet.cell(excel_lib.CellIndex.indexByString('A1')).value = excel_lib.TextCellValue('Invoice No.');
      salesSheet.cell(excel_lib.CellIndex.indexByString('B1')).value = excel_lib.TextCellValue('Table');
      salesSheet.cell(excel_lib.CellIndex.indexByString('C1')).value = excel_lib.TextCellValue('Order Type');
      salesSheet.cell(excel_lib.CellIndex.indexByString('D1')).value = excel_lib.TextCellValue('Total Amount');
      salesSheet.cell(excel_lib.CellIndex.indexByString('E1')).value = excel_lib.TextCellValue('Date');
      salesSheet.cell(excel_lib.CellIndex.indexByString('F1')).value = excel_lib.TextCellValue('Time');

      for (int i = 0; i < filteredSales.length; i++) {
        final sale = filteredSales[i];
        final row = i + 2;
        salesSheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = excel_lib.TextCellValue(sale.invoiceNo);
        salesSheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = excel_lib.TextCellValue(sale.table);
        salesSheet.cell(excel_lib.CellIndex.indexByString('C$row')).value = excel_lib.TextCellValue(sale.orderType);
        salesSheet.cell(excel_lib.CellIndex.indexByString('D$row')).value = excel_lib.DoubleCellValue(sale.total);
        salesSheet.cell(excel_lib.CellIndex.indexByString('E$row')).value = excel_lib.TextCellValue(DateFormat('MMM dd, yyyy').format(sale.timestamp));
        salesSheet.cell(excel_lib.CellIndex.indexByString('F$row')).value = excel_lib.TextCellValue(DateFormat('hh:mm a').format(sale.timestamp));
      }

      // Remove default sheet
      excel.delete('Sheet1');

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'sales_report_${selectedPeriod}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported successfully to: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isExporting = false;
      });
    }
  }
}
