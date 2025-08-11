import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/models.dart';
import '../../services/data_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

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
  final DataRepository _dataRepository = DataRepository();
  List<Sales> allSales = [];
  List<Expense> allExpenses = [];
  List<ExpensesCategory> expenseCategories = [];
  Map<String, dynamic> analyticsData = {};
  bool isLoading = true;
  String selectedView = 'overview';

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    setState(() {
      isLoading = true;
    });

    try {
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

      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _dataRepository.fetchSalesByDateRange(startDate, now),
        _dataRepository.fetchExpensesByDateRange(startDate, now),
        _dataRepository.fetchExpenseCategories(),
        _dataRepository.getSalesAnalytics(startDate, now),
      ]);

      setState(() {
        allSales = results[0] as List<Sales>;
        allExpenses = results[1] as List<Expense>;
        expenseCategories = results[2] as List<ExpensesCategory>;
        analyticsData = results[3] as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        allSales = [];
        allExpenses = [];
        expenseCategories = [];
        analyticsData = {};
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: const Text('Sales Analytics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filteredSales = _getFilteredSales();
    final reportData = _calculateReportData(filteredSales);
    final mostSoldItems = _getMostSoldItems(filteredSales);
    final paginatedSales = _getPaginatedSales(filteredSales);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportsData,
          ),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: periods
                      .map((period) => _buildPeriodChip(period))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildViewChip('overview', 'Overview', Icons.dashboard),
                    _buildViewChip('charts', 'Charts', Icons.bar_chart),
                    _buildViewChip('detailed', 'Detailed', Icons.table_chart),
                    _buildViewChip('expenses', 'Expenses', Icons.receipt_long),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReportsData,
              child: allSales.isEmpty
                  ? _buildEmptyState()
                  : _buildSelectedView(
                      filteredSales,
                      reportData,
                      mostSoldItems,
                      paginatedSales,
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
          currentPage = 0;
        });
        _loadReportsData();
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

  Widget _buildViewChip(String view, String label, IconData icon) {
    final isSelected = selectedView == view;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedView = view;
          currentPage = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No sales data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make some sales to see analytics here',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedView(
    List<Sales> filteredSales,
    Map<String, dynamic> reportData,
    List<Map<String, dynamic>> mostSoldItems,
    List<Sales> paginatedSales,
  ) {
    switch (selectedView) {
      case 'overview':
        return _buildOverviewView(reportData, mostSoldItems);
      case 'charts':
        return _buildChartsView(filteredSales, reportData, mostSoldItems);
      case 'detailed':
        return _buildDetailedView(filteredSales, paginatedSales);
      case 'expenses':
        return _buildExpensesView();
      default:
        return _buildOverviewView(reportData, mostSoldItems);
    }
  }

  Widget _buildOverviewView(
    Map<String, dynamic> reportData,
    List<Map<String, dynamic>> mostSoldItems,
  ) {
    // Use analytics data if available, fallback to calculated data
    final summary = analyticsData['summary'] ?? {};
    final topItems = analyticsData['topItems'] ?? mostSoldItems;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSummaryCards(summary),
          const SizedBox(height: 24),
          _buildQuickInsights(summary),
          const SizedBox(height: 24),
          _buildTopItemsOverview(topItems),
          const SizedBox(height: 24),
          _buildRecentPerformance(summary),
        ],
      ),
    );
  }

  Widget _buildChartsView(
    List<Sales> filteredSales,
    Map<String, dynamic> reportData,
    List<Map<String, dynamic>> mostSoldItems,
  ) {
    // Use analytics data if available
    final dailySales = analyticsData['dailySales'] ?? {};
    final topItems = analyticsData['topItems'] ?? mostSoldItems;
    final orderTypeStats = analyticsData['orderTypeStats'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailySalesChart(dailySales),
          const SizedBox(height: 24),
          _buildTopItemsChart(topItems),
          const SizedBox(height: 24),
          _buildOrderTypeChart(orderTypeStats),
          const SizedBox(height: 24),
          _buildHourlySalesChart(filteredSales),
        ],
      ),
    );
  }

  Widget _buildDetailedView(
    List<Sales> filteredSales,
    List<Sales> paginatedSales,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalesRecordsSection(filteredSales, paginatedSales),
          const SizedBox(height: 24),
          _buildDetailedStatistics(filteredSales),
        ],
      ),
    );
  }

  Widget _buildExpensesView() {
    final filteredExpenses = allExpenses;
    final totalExpenses = analyticsData['summary']?['totalExpenses']?.toDouble() ?? 
        filteredExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpenseSummaryCards(totalExpenses, filteredExpenses.length),
          const SizedBox(height: 24),
          _buildExpenseCategoryChart(filteredExpenses),
          const SizedBox(height: 24),
          _buildExpenseRecordsSection(filteredExpenses),
        ],
      ),
    );
  }

  Widget _buildExpenseSummaryCards(double totalExpenses, int expenseCount) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Expenses',
            'NPR ${NumberFormat('#,##0.00').format(totalExpenses)}',
            Icons.money_off,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Number of Expenses',
            '$expenseCount',
            Icons.receipt,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Average Expense',
            expenseCount > 0
                ? 'NPR ${NumberFormat('#,##0.00').format(totalExpenses / expenseCount)}'
                : 'NPR 0.00',
            Icons.calculate,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCategoryChart(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<int, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final category = expenseCategories.firstWhere(
              (cat) => cat.id == entry.key,
              orElse: () => ExpensesCategory(name: 'Unknown'),
            );
            final percentage =
                (entry.value /
                    expenses.fold<double>(0.0, (sum, e) => sum + e.amount)) *
                100;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red[400]!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NPR ${NumberFormat('#,##0.00').format(entry.value)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpenseRecordsSection(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No expenses found for selected period',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final paginatedExpenses = expenses
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Total: ${expenses.length} expenses',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Payment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paginatedExpenses.length,
            itemBuilder: (context, index) {
              final expense = paginatedExpenses[index];
              final category = expenseCategories.firstWhere(
                (cat) => cat.id == expense.categoryId,
                orElse: () => ExpensesCategory(name: 'Unknown'),
              );

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        expense.description ?? 'No description',
                        style: TextStyle(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.paymentMethod?.name ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'NPR ${NumberFormat('#,##0.00').format(expense.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(expense.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (expenses.length > itemsPerPage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${(currentPage * itemsPerPage) + 1}-${(currentPage * itemsPerPage) + paginatedExpenses.length} of ${expenses.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      Text(
                        'Page ${currentPage + 1} of ${(expenses.length / itemsPerPage).ceil()}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        onPressed:
                            currentPage <
                                (expenses.length / itemsPerPage).ceil() - 1
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

  Widget _buildEnhancedSummaryCards(Map<String, dynamic> summary) {
    final totalRevenue = summary['totalSales']?.toDouble() ?? 0.0;
    final totalExpenses = summary['totalExpenses']?.toDouble() ?? 0.0;
    final netProfit = summary['netProfit']?.toDouble() ?? (totalRevenue - totalExpenses);
    final totalOrders = summary['totalOrders']?.toInt() ?? 0;
    final totalItemsSold = summary['totalItemsSold']?.toInt() ?? 0;
    final averageOrderValue = summary['averageOrderValue']?.toDouble() ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Revenue',
                'NPR ${NumberFormat('#,##0.00').format(totalRevenue)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Expenses',
                'NPR ${NumberFormat('#,##0.00').format(totalExpenses)}',
                Icons.money_off,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Net Profit',
                'NPR ${NumberFormat('#,##0.00').format(netProfit)}',
                Icons.account_balance_wallet,
                netProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Orders',
                '$totalOrders',
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Items Sold',
                '$totalItemsSold',
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg Order Value',
                'NPR ${NumberFormat('#,##0.00').format(averageOrderValue)}',
                Icons.calculate,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInsights(Map<String, dynamic> reportData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Quick Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(
            Icons.schedule,
            'Peak Hours',
            'Most sales between 12 PM - 2 PM',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            Icons.trending_up,
            'Growth',
            '${_calculateGrowthPercentage(reportData)}% vs last period',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            Icons.star,
            'Best Day',
            _getBestPerformingDay(allSales),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemsOverview(List<dynamic> topItems) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...topItems.take(5).map((item) => _buildTopItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildTopItemRow(dynamic item) {
    final itemName = item is Map ? item['name']?.toString() ?? 'Unknown' : 'Unknown';
    final quantity = item is Map ? item['quantity']?.toString() ?? '0' : '0';
    final revenue = item is Map ? item['revenue']?.toDouble() ?? 0.0 : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.fastfood, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$quantity sold • Rs. ${revenue.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPerformance(Map<String, dynamic> reportData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                  'Tax Collected',
                  'Rs. ${reportData['tax']?.toStringAsFixed(2) ?? '0.00'}',
                  Icons.account_balance,
                  Colors.indigo,
                ),
              ),
              Expanded(
                child: _buildMetricColumn(
                  'Discounts Given',
                  'Rs. ${reportData['discount']?.toStringAsFixed(2) ?? '0.00'}',
                  Icons.local_offer,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
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

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.yellow;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _calculateGrowthPercentage(Map<String, dynamic> reportData) {
    return "+12.5";
  }

  String _getBestPerformingDay(List<Sales> sales) {
    if (sales.isEmpty) return "No data available";

    final Map<String, double> dailyTotals = {};
    for (final sale in sales) {
      final day = DateFormat('EEEE').format(sale.timestamp);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + sale.total;
    }

    if (dailyTotals.isEmpty) return "No data available";

    final bestDay = dailyTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return bestDay.key;
  }

  Widget _buildDailySalesChart(Map<String, dynamic> dailySalesData) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getChartTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dailySalesData.isEmpty
                ? const Center(
                    child: Text(
                      'No sales data available for this period',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'Rs.${(value / 1000).toStringAsFixed(0)}k',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _getBottomTitleLabel(value.toInt()),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getDailySalesSpotsFromAnalytics(dailySalesData),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getDailySalesSpotsFromAnalytics(Map<String, dynamic> dailySalesData) {
    if (dailySalesData.isEmpty) return [];
    
    final spots = <FlSpot>[];
    final sortedKeys = dailySalesData.keys.toList()..sort();
    
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = dailySalesData[key]?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return spots;
  }

  Widget _buildTopItemsChart(List<dynamic> topItems) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Items by Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: topItems.isEmpty
                ? const Center(
                    child: Text(
                      'No item sales data available',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < topItems.length) {
                                final item = topItems[index];
                                final name = item is Map ? item['name']?.toString() ?? '' : '';
                                return Text(
                                  name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getTopItemsBarGroupsFromAnalytics(topItems),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getTopItemsBarGroupsFromAnalytics(List<dynamic> items) {
    if (items.isEmpty) return [];

    return items.take(5).toList().asMap().entries.map((entry) {
      final item = entry.value;
      final quantity = item is Map ? item['quantity']?.toDouble() ?? 0.0 : 0.0;
      
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: quantity,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildOrderTypeChart(Map<String, dynamic> orderTypeStats) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Type Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: _getOrderTypePieChartSectionsFromAnalytics(orderTypeStats),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Dine In', Colors.blue),
                      const SizedBox(height: 8),
                      _buildLegendItem('Takeaway', Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getOrderTypePieChartSectionsFromAnalytics(Map<String, dynamic> orderTypeStats) {
    final dineInCount = orderTypeStats['dineIn']?.toInt() ?? 0;
    final takeawayCount = orderTypeStats['takeaway']?.toInt() ?? 0;
    final total = dineInCount + takeawayCount;
    
    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: dineInCount.toDouble(),
        title: '${((dineInCount / total) * 100).toStringAsFixed(1)}%',
        color: Colors.blue,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: takeawayCount.toDouble(),
        title: '${((takeawayCount / total) * 100).toStringAsFixed(1)}%',
        color: Colors.orange,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildHourlySalesChart(List<Sales> sales) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Hour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: sales.isEmpty
                ? const Center(
                    child: Text(
                      'No hourly sales data available',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              if (value >= 1000) {
                                return Text(
                                  'Rs.${(value / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(fontSize: 10),
                                );
                              } else {
                                return Text(
                                  'Rs.${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final hour = value.toInt();
                              if (hour >= 0 && hour <= 23) {
                                return Text(
                                  '${hour}h',
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getHourlySalesBarGroups(sales),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatistics(List<Sales> sales) {
    final Map<String, int> tableStats = {};
    final Map<String, double> hourlyStats = {};

    for (final sale in sales) {
      tableStats[sale.table] = (tableStats[sale.table] ?? 0) + 1;

      final hour = sale.timestamp.hour.toString();
      hourlyStats[hour] = (hourlyStats[hour] ?? 0) + sale.total;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Table Performance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...tableStats.entries
                        .take(5)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${entry.key}: ${entry.value} orders',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peak Hours',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...hourlyStats.entries
                        .take(5)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${entry.key}:00 - Rs. ${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<BarChartGroupData> _getHourlySalesBarGroups(List<Sales> sales) {
    final Map<int, double> hourlyRevenue = {};
    for (int i = 0; i < 24; i++) {
      hourlyRevenue[i] = 0;
    }

    for (final sale in sales) {
      final hour = sale.timestamp.hour;
      hourlyRevenue[hour] = (hourlyRevenue[hour] ?? 0) + sale.total;
    }

    return hourlyRevenue.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.green,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ],
      );
    }).toList();
  }

  String _getBottomTitleLabel(int value) {
    switch (selectedPeriod) {
      case '1day':
        return '${value}h';

      case '7days':
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return value >= 0 && value < days.length ? days[value] : '';

      case '1 month':
        return value.toString();

      case '3months':
      case '6 months':
        return 'W${value + 1}';

      default:
        return value.toString();
    }
  }

  String _getChartTitle() {
    switch (selectedPeriod) {
      case '1day':
        return 'Hourly Sales Trend';
      case '7days':
        return 'Daily Sales Trend';
      case '1 month':
        return 'Daily Sales Trend (This Month)';
      case '3months':
        return 'Weekly Sales Trend (3 Months)';
      case '6 months':
        return 'Weekly Sales Trend (6 Months)';
      default:
        return 'Sales Trend';
    }
  }

  Widget _buildSalesRecordsSection(
    List<Sales> allSales,
    List<Sales> paginatedSales,
  ) {
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    'Payment Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Items Count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Subtotal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tax',
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
                // Calculate total items from SalesItems if available
                int totalItems = 0;
                if (sale.items.isNotEmpty) {
                  for (var item in sale.items) {
                    if (item is SalesItem) {
                      totalItems += item.quantity.toInt();
                    } else if (item is CartItem) {
                      totalItems += item.quantity;
                    } else if (item is Map) {
                      totalItems += ((item['quantity'] ?? 0) as num).toInt();
                    }
                  }
                }

                return DataRow(
                  cells: [
                    DataCell(Text(sale.invoiceNo.isNotEmpty ? sale.invoiceNo : 'N/A')),
                    DataCell(Text(sale.table.isNotEmpty ? sale.table : 'N/A')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sale.orderType == 'Dine In' || sale.orderType == 'dine-in'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sale.orderType,
                          style: TextStyle(
                            color: sale.orderType == 'Dine In' || sale.orderType == 'dine-in'
                                ? Colors.blue
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentStatusColor(sale.paymentStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sale.paymentStatus,
                          style: TextStyle(
                            color: _getPaymentStatusColor(sale.paymentStatus),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text('$totalItems items')),
                    DataCell(
                      Text(
                        'Rs. ${sale.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${sale.tax.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${sale.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat(
                          'MMM dd, yyyy\nhh:mm a',
                        ).format(sale.timestamp),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${(currentPage * itemsPerPage) + 1}-${(currentPage * itemsPerPage) + paginatedSales.length} of ${allSales.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      ...List.generate(totalPages > 5 ? 5 : totalPages, (
                        index,
                      ) {
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
                      }),
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

  List<Sales> _getFilteredSales() {
    return allSales..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
      // Calculate total products sold
      for (final item in sale.items) {
        int itemQuantity = 0;
        
        if (item is CartItem) {
          itemQuantity = item.quantity;
        } else if (item is SalesItem) {
          itemQuantity = item.quantity.round();
        } else if (item is Map<String, dynamic>) {
          itemQuantity = ((item['quantity'] ?? 0) as num).round();
        }
        
        totalProductsSold += itemQuantity;
      }
      
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
      for (final item in sale.items) {
        String itemName;
        double quantity;
        double revenue;

        if (item is CartItem) {
          itemName = item.item['item_name'] ?? item.item['itemName'] ?? 'Unknown';
          quantity = item.quantity.toDouble();
          revenue = item.totalPrice;
        } else if (item is SalesItem) {
          itemName = item.itemName;
          quantity = item.quantity;
          revenue = item.totalPrice;
        } else if (item is Map<String, dynamic>) {
          // Handle raw data from API
          if (item.containsKey('item')) {
            // CartItem format
            final itemMap = item['item'] as Map<String, dynamic>;
            itemName = itemMap['item_name'] ?? itemMap['itemName'] ?? 'Unknown';
            quantity = (item['quantity'] ?? 0).toDouble();
            revenue = (item['totalPrice'] ?? 0).toDouble();
          } else {
            // SalesItem format
            itemName = item['itemName'] ?? 'Unknown';
            quantity = (item['quantity'] ?? 0).toDouble();
            revenue = (item['totalPrice'] ?? 0).toDouble();
          }
        } else {
          // Skip unknown item types
          continue;
        }

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

  Future<void> _exportToExcel() async {
    setState(() {
      isExporting = true;
    });

    try {
      final filteredSales = _getFilteredSales();
      final mostSoldItems = _getMostSoldItems(filteredSales);
      final reportData = _calculateReportData(filteredSales);

      var excel = excel_lib.Excel.createExcel();

      var summarySheet = excel['Sales Summary'];

      summarySheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
          excel_lib.TextCellValue('Sales Report Summary');
      summarySheet.cell(excel_lib.CellIndex.indexByString('A2')).value =
          excel_lib.TextCellValue('Period: $selectedPeriod');
      summarySheet
          .cell(excel_lib.CellIndex.indexByString('A3'))
          .value = excel_lib.TextCellValue(
        'Generated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
      );

      summarySheet.cell(excel_lib.CellIndex.indexByString('A5')).value =
          excel_lib.TextCellValue('Metric');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B5')).value =
          excel_lib.TextCellValue('Value');

      summarySheet.cell(excel_lib.CellIndex.indexByString('A6')).value =
          excel_lib.TextCellValue('Total Sales Count');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B6')).value =
          excel_lib.IntCellValue(reportData['salesCount']);

      summarySheet.cell(excel_lib.CellIndex.indexByString('A7')).value =
          excel_lib.TextCellValue('Products Sold');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B7')).value =
          excel_lib.IntCellValue(reportData['productsSold']);

      summarySheet.cell(excel_lib.CellIndex.indexByString('A8')).value =
          excel_lib.TextCellValue('Total Sales Amount');
      summarySheet.cell(excel_lib.CellIndex.indexByString('B8')).value =
          excel_lib.DoubleCellValue(reportData['totalAmount']);

      var mostSoldSheet = excel['Most Sold Items'];
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
          excel_lib.TextCellValue('Rank');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('B1')).value =
          excel_lib.TextCellValue('Item Name');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('C1')).value =
          excel_lib.TextCellValue('Quantity Sold');
      mostSoldSheet.cell(excel_lib.CellIndex.indexByString('D1')).value =
          excel_lib.TextCellValue('Total Revenue');

      for (int i = 0; i < mostSoldItems.length; i++) {
        final item = mostSoldItems[i];
        final row = i + 2;
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            excel_lib.IntCellValue(i + 1);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            excel_lib.TextCellValue(item['name']);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('C$row')).value =
            excel_lib.IntCellValue(item['quantity']);
        mostSoldSheet.cell(excel_lib.CellIndex.indexByString('D$row')).value =
            excel_lib.DoubleCellValue(item['revenue']);
      }

      var salesSheet = excel['Sales Records'];
      salesSheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
          excel_lib.TextCellValue('Invoice No.');
      salesSheet.cell(excel_lib.CellIndex.indexByString('B1')).value =
          excel_lib.TextCellValue('Table');
      salesSheet.cell(excel_lib.CellIndex.indexByString('C1')).value =
          excel_lib.TextCellValue('Order Type');
      salesSheet.cell(excel_lib.CellIndex.indexByString('D1')).value =
          excel_lib.TextCellValue('Total Amount');
      salesSheet.cell(excel_lib.CellIndex.indexByString('E1')).value =
          excel_lib.TextCellValue('Date');
      salesSheet.cell(excel_lib.CellIndex.indexByString('F1')).value =
          excel_lib.TextCellValue('Time');

      for (int i = 0; i < filteredSales.length; i++) {
        final sale = filteredSales[i];
        final row = i + 2;
        salesSheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            excel_lib.TextCellValue(sale.invoiceNo);
        salesSheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            excel_lib.TextCellValue(sale.table);
        salesSheet.cell(excel_lib.CellIndex.indexByString('C$row')).value =
            excel_lib.TextCellValue(sale.orderType);
        salesSheet.cell(excel_lib.CellIndex.indexByString('D$row')).value =
            excel_lib.DoubleCellValue(sale.total);
        salesSheet
            .cell(excel_lib.CellIndex.indexByString('E$row'))
            .value = excel_lib.TextCellValue(
          DateFormat('MMM dd, yyyy').format(sale.timestamp),
        );
        salesSheet
            .cell(excel_lib.CellIndex.indexByString('F$row'))
            .value = excel_lib.TextCellValue(
          DateFormat('hh:mm a').format(sale.timestamp),
        );
      }

      excel.delete('Sheet1');

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'sales_report_${selectedPeriod}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
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
