import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/daybook_service.dart';
import '../../utils/responsive.dart';

class DaybookScreen extends StatefulWidget {
  const DaybookScreen({super.key});

  @override
  State<DaybookScreen> createState() => _DaybookScreenState();
}

class _DaybookScreenState extends State<DaybookScreen> {
  final DaybookService _daybookService = DaybookService();
  
  DaybookSummary? _todaysSummary;
  List<DaybookTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTodaysSummary();
  }

  Future<void> _fetchTodaysSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summaryData = await _daybookService.getTodaysSummary();
      
      _todaysSummary = DaybookSummary.fromJson(summaryData['summary']);
      
      final transactionsData = summaryData['transactions'] as List;
      _transactions = transactionsData
          .map((transaction) => DaybookTransaction.fromJson(transaction))
          .toList();
      
    } catch (e) {
      _error = 'Error fetching daybook data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDataForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedDate = date;
    });

    try {
      final dateString = _daybookService.formatDateForApi(date);
      final summaryData = await _daybookService.getDaybookSummary(dateString);
      
      _todaysSummary = DaybookSummary.fromJson(summaryData);
      
      // Fetch transactions for the selected date
      final entriesData = await _daybookService.getDaybookEntries(
        startDate: dateString,
        endDate: dateString,
      );
      
      _transactions = entriesData
          .map((transaction) => DaybookTransaction.fromJson(transaction))
          .toList();
      
    } catch (e) {
      _error = 'Error fetching daybook data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: ResponsiveUtils.getPadding(context, base: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, DaybookBalance balance, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTotal ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isTotal ? Border.all(color: Colors.blue.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.blue[800] : Colors.grey[800],
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatCurrency(balance.cash),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatCurrency(balance.online),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatCurrency(balance.total),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTotal ? Colors.blue[800] : Colors.grey[800],
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(DaybookTransaction transaction) {
    Color typeColor;
    IconData typeIcon;
    String typeText;

    switch (transaction.transactionType) {
      case 'sale':
        typeColor = Colors.green;
        typeIcon = Icons.shopping_cart;
        typeText = 'Sale';
        break;
      case 'expense':
        typeColor = Colors.red;
        typeIcon = Icons.money_off;
        typeText = 'Expense';
        break;
      case 'opening_balance':
        typeColor = Colors.blue;
        typeIcon = Icons.account_balance;
        typeText = 'Opening Balance';
        break;
      case 'closing_balance':
        typeColor = Colors.purple;
        typeIcon = Icons.lock;
        typeText = 'Closing Balance';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help;
        typeText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transaction.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction.paymentMode == 'cash' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.paymentMode.toUpperCase(),
                  style: TextStyle(
                    color: transaction.paymentMode == 'cash' 
                        ? Colors.green[700]
                        : Colors.blue[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: ResponsiveUtils.getPadding(context, base: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daybook Record',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _fetchDataForDate(date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isSameDate(_selectedDate, DateTime.now()))
                  ElevatedButton(
                    onPressed: _fetchTodaysSummary,
                    child: const Text('Today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[700],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchTodaysSummary,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_todaysSummary != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Opening Cash',
                              _todaysSummary!.openingBalance.cash,
                              Colors.blue,
                              Icons.account_balance_wallet,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Opening Online',
                              _todaysSummary!.openingBalance.online,
                              Colors.purple,
                              Icons.credit_card,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Sales',
                              _todaysSummary!.sales.total,
                              Colors.green,
                              Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Expenses',
                              _todaysSummary!.expenses.total,
                              Colors.red,
                              Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Financial Summary Table
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Summary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Header Row
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Cash (Rs.)',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Online (Rs.)',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Total (Rs.)',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Data rows
                            _buildBalanceRow('Opening Balance', _todaysSummary!.openingBalance),
                            const SizedBox(height: 4),
                            _buildBalanceRow('Sales', DaybookBalance(
                              cash: _todaysSummary!.sales.cash,
                              online: _todaysSummary!.sales.online,
                            )),
                            const SizedBox(height: 4),
                            _buildBalanceRow('Expenses', DaybookBalance(
                              cash: _todaysSummary!.expenses.cash,
                              online: _todaysSummary!.expenses.online,
                            )),
                            const SizedBox(height: 8),
                            _buildBalanceRow('Net Total', DaybookBalance(
                              cash: _todaysSummary!.netCash,
                              online: _todaysSummary!.netOnline,
                            ), isTotal: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transactions List
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Transactions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            if (_transactions.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long, 
                                         color: Colors.grey[400], size: 48),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions for this date',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionTile(_transactions[index]);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(child: Text('No data available')),
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
