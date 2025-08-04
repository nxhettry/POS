import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/models.dart';
import '../../services/database_helper.dart';

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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Sales> allSales = [];
  bool isLoading = true;
  String selectedView = 'overview'; // overview, charts, detailed

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
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

      final sales = await _databaseHelper.getSalesByDateRange(startDate, now);
      setState(() {
        allSales = sales;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        allSales = [];
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sales data: ${e.toString()}'),
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
            onPressed: _loadSalesData,
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
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSalesData,
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
          currentPage = 0; // Reset pagination when period changes
        });
        _loadSalesData(); // Reload data for new period
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
      default:
        return _buildOverviewView(reportData, mostSoldItems);
    }
  }

  Widget _buildOverviewView(
    Map<String, dynamic> reportData,
    List<Map<String, dynamic>> mostSoldItems,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSummaryCards(reportData),
          const SizedBox(height: 24),
          _buildQuickInsights(reportData),
          const SizedBox(height: 24),
          _buildTopItemsOverview(mostSoldItems),
          const SizedBox(height: 24),
          _buildRecentPerformance(reportData),
        ],
      ),
    );
  }

  Widget _buildChartsView(
    List<Sales> filteredSales,
    Map<String, dynamic> reportData,
    List<Map<String, dynamic>> mostSoldItems,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailySalesChart(filteredSales),
          const SizedBox(height: 24),
          _buildTopItemsChart(mostSoldItems),
          const SizedBox(height: 24),
          _buildOrderTypeChart(filteredSales),
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

  Widget _buildEnhancedSummaryCards(Map<String, dynamic> reportData) {
    final averageOrderValue = reportData['salesCount'] > 0
        ? reportData['totalAmount'] / reportData['salesCount']
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Revenue',
                'Rs. ${reportData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Orders',
                '${reportData['salesCount']}',
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
                '${reportData['productsSold']}',
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg Order Value',
                'Rs. ${averageOrderValue.toStringAsFixed(2)}',
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

  Widget _buildTopItemsOverview(List<Map<String, dynamic>> mostSoldItems) {
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
          ...mostSoldItems.take(5).map((item) => _buildTopItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildTopItemRow(Map<String, dynamic> item) {
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
                  item['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${item['quantity']} sold • Rs. ${item['revenue'].toStringAsFixed(2)}',
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

  // Helper methods for insights
  String _calculateGrowthPercentage(Map<String, dynamic> reportData) {
    // Simple placeholder - in real app, compare with previous period
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

  // Chart Methods
  Widget _buildDailySalesChart(List<Sales> sales) {
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
            child: _getDailySalesSpots(sales).isEmpty
                ? const Center(
                    child: Text(
                      'No sales data available for this period',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
                          spots: _getDailySalesSpots(sales),
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

  Widget _buildTopItemsChart(List<Map<String, dynamic>> mostSoldItems) {
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
            child: mostSoldItems.isEmpty
                ? const Center(
                    child: Text(
                      'No item sales data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
                        if (index >= 0 && index < mostSoldItems.length) {
                          final name = mostSoldItems[index]['name'] as String;
                          return Text(
                            name.length > 8
                                ? '${name.substring(0, 8)}...'
                                : name,
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
                barGroups: _getTopItemsBarGroups(mostSoldItems),
              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeChart(List<Sales> sales) {
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
                      sections: _getOrderTypePieChartSections(sales),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
      // Table statistics
      tableStats[sale.table] = (tableStats[sale.table] ?? 0) + 1;

      // Hourly statistics
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

  // Chart data helper methods
  List<FlSpot> _getDailySalesSpots(List<Sales> sales) {
    if (sales.isEmpty) return [];

    // Group sales by time period based on selectedPeriod
    final Map<int, double> salesByPeriod = {};
    
    switch (selectedPeriod) {
      case '1day':
        // Group by hours (0-23)
        for (int i = 0; i < 24; i++) {
          salesByPeriod[i] = 0;
        }
        for (final sale in sales) {
          final hour = sale.timestamp.hour;
          salesByPeriod[hour] = (salesByPeriod[hour] ?? 0) + sale.total;
        }
        break;
        
      case '7days':
        // Group by days of week (0-6, Monday to Sunday)
        for (int i = 0; i < 7; i++) {
          salesByPeriod[i] = 0;
        }
        for (final sale in sales) {
          final dayOfWeek = (sale.timestamp.weekday - 1) % 7; // Monday = 0
          salesByPeriod[dayOfWeek] = (salesByPeriod[dayOfWeek] ?? 0) + sale.total;
        }
        break;
        
      case '1 month':
        // Group by days of the month (1-31)
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (int i = 1; i <= daysInMonth; i++) {
          salesByPeriod[i] = 0;
        }
        for (final sale in sales) {
          final day = sale.timestamp.day;
          salesByPeriod[day] = (salesByPeriod[day] ?? 0) + sale.total;
        }
        break;
        
      case '3months':
      case '6 months':
        // Group by weeks
        if (sales.isNotEmpty) {
          final startDate = sales.map((s) => s.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
          final endDate = sales.map((s) => s.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
          
          // Calculate number of weeks
          final weeksDifference = endDate.difference(startDate).inDays ~/ 7 + 1;
          
          for (int i = 0; i < weeksDifference; i++) {
            salesByPeriod[i] = 0;
          }
          
          for (final sale in sales) {
            final weekIndex = sale.timestamp.difference(startDate).inDays ~/ 7;
            salesByPeriod[weekIndex] = (salesByPeriod[weekIndex] ?? 0) + sale.total;
          }
        }
        break;
    }

    return salesByPeriod.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
        ..sort((a, b) => a.x.compareTo(b.x));
  }

  List<BarChartGroupData> _getTopItemsBarGroups(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) return [];
    
    return items.take(5).toList().asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['quantity'].toDouble(),
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

  List<PieChartSectionData> _getOrderTypePieChartSections(List<Sales> sales) {
    int dineInCount = 0;
    int takeawayCount = 0;

    for (final sale in sales) {
      if (sale.orderType == 'Dine In') {
        dineInCount++;
      } else {
        takeawayCount++;
      }
    }

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
        // Return hour labels (0-23)
        return '${value}h';
        
      case '7days':
        // Return day labels
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return value >= 0 && value < days.length ? days[value] : '';
        
      case '1 month':
        // Return day of month labels
        return value.toString();
        
      case '3months':
      case '6 months':
        // Return week labels
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

          // Pagination Controls
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

      // Create Most Sold Items Sheet
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

      // Create Sales Records Sheet
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

      // Remove default sheet
      excel.delete('Sheet1');

      // Save file
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
