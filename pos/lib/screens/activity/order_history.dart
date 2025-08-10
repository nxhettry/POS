import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../models/models.dart";
import "../../services/data_repository.dart";
import "../../utils/invoice.dart";

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String selectedFilter = "All";
  final List<String> filterOptions = ["All", "Dine In", "Takeaway", "Delivery"];
  String selectedDateFilter = "Today";
  final List<String> dateFilterOptions = ["Today", "Yesterday", "Last 2 Days"];
  List<Sales> _allSales = [];
  List<Sales> _filteredSales = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final DataRepository _dataRepository = DataRepository();

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      List<Sales> sales;
      
      // Get date range based on filter
      final dateRange = _getDateRange();
      if (dateRange != null) {
        sales = await _dataRepository.fetchSalesByDateRange(dateRange['start']!, dateRange['end']!);
      } else {
        sales = await _dataRepository.fetchSales();
      }
      
      setState(() {
        _allSales = sales;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allSales = [];
        _filteredSales = [];
        _isLoading = false;
        _errorMessage = 'Failed to load sales: $e';
      });
    }
  }

  Map<String, DateTime>? _getDateRange() {
    final now = DateTime.now();
    
    switch (selectedDateFilter) {
      case "Today":
        return {
          'start': DateTime(now.year, now.month, now.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case "Yesterday":
        final yesterday = now.subtract(const Duration(days: 1));
        return {
          'start': DateTime(yesterday.year, yesterday.month, yesterday.day),
          'end': DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        };
      case "Last 2 Days":
        final twoDaysAgo = now.subtract(const Duration(days: 1));
        return {
          'start': DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      default:
        return null;
    }
  }

  void _applyFilters() {
    List<Sales> filtered = List.from(_allSales);
    
    // Apply order type filter
    if (selectedFilter != "All") {
      filtered = filtered.where((sale) => sale.orderType == selectedFilter).toList();
    }
    
    // Sort by timestamp (most recent first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _filteredSales = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadSales,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    "Order History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: filterOptions.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedFilter = newValue!;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDateFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: dateFilterOptions.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDateFilter = newValue!;
                                  _loadSales();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _filteredSales.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredSales.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(_filteredSales[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Orders',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadSales,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateTitle(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadSales,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.blue[700],
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_allSales.isEmpty) {
      return "No Orders Yet";
    } else {
      return "No Orders Found";
    }
  }

  String _getEmptyStateMessage() {
    String dateMessage;
    switch (selectedDateFilter) {
      case "Today":
        dateMessage = "today";
        break;
      case "Yesterday":
        dateMessage = "yesterday";
        break;
      case "Last 2 Days":
        dateMessage = "in the last 2 days";
        break;
      default:
        dateMessage = "for the selected period";
    }

    if (_allSales.isEmpty) {
      return "No orders have been placed yet.\nStart by creating your first order.";
    } else if (selectedFilter == "All") {
      return "No orders found $dateMessage.\nTry selecting a different date range.";
    } else {
      return "No $selectedFilter orders found $dateMessage.\nTry changing the filter or date range.";
    }
  }

  Widget _buildOrderCard(Sales sale) {
    return GestureDetector(
      onTap: () => _showOrderDetails(sale),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getOrderTypeColor(sale.orderType).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.invoiceNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getOrderTypeIcon(sale.orderType),
                            size: 16,
                            color: _getOrderTypeColor(sale.orderType),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sale.orderType,
                            style: TextStyle(
                              color: _getOrderTypeColor(sale.orderType),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.table_restaurant,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sale.table,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${sale.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(sale.timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(sale.timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Items summary and actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${sale.items.length} items",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _reprintInvoice(sale),
                            icon: const Icon(Icons.print, size: 16),
                            label: const Text("Reprint"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _showOrderDetails(sale),
                            child: const Text("View Details"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reprintInvoice(Sales sale) async {
    try {
      await reprintInvoice(context, sale);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reprinting invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderDetails(Sales sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getOrderTypeColor(sale.orderType).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.invoiceNo,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getOrderTypeIcon(sale.orderType),
                                size: 16,
                                color: _getOrderTypeColor(sale.orderType),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sale.orderType,
                                style: TextStyle(
                                  color: _getOrderTypeColor(sale.orderType),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.table_restaurant,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sale.table,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date and time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(sale.timestamp),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Time",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(sale.timestamp),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Items
                        Text(
                          "Items Ordered",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...sale.items.map((cartItem) => _buildDetailItemRow(cartItem)),
                        
                        const SizedBox(height: 24),
                        Container(height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        
                        // Summary
                        _buildSummaryRow(
                          "Subtotal",
                          "₹${sale.subtotal.toStringAsFixed(2)}",
                        ),
                        if (sale.discount > 0)
                          _buildSummaryRow(
                            "Discount ${sale.isDiscountPercentage ? '(${sale.discountValue.toStringAsFixed(0)}%)' : ''}",
                            "-₹${sale.discount.toStringAsFixed(2)}",
                            color: Colors.orange,
                          ),
                        _buildSummaryRow(
                          "Tax (${(sale.taxRate * 100).toStringAsFixed(0)}%)",
                          "₹${sale.tax.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        Container(height: 1, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          "Total",
                          "₹${sale.total.toStringAsFixed(2)}",
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reprintInvoice(sale),
                          icon: const Icon(Icons.print),
                          label: const Text("Reprint Invoice"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItemRow(CartItem cartItem) {
    final String? imagePath = cartItem.item['image'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath != null && imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.fastfood, color: Colors.grey[400]);
                      },
                    )
                  : Icon(Icons.fastfood, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item['item_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "₹${cartItem.item['rate']} × ${cartItem.quantity}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            "₹${cartItem.totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? (isTotal ? Colors.black87 : Colors.grey[600]),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? (isTotal ? Colors.black87 : Colors.grey[800]),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderTypeColor(String orderType) {
    switch (orderType) {
      case "Dine In":
        return Colors.blue;
      case "Takeaway":
        return Colors.orange;
      case "Delivery":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getOrderTypeIcon(String orderType) {
    switch (orderType) {
      case "Dine In":
        return Icons.restaurant;
      case "Takeaway":
        return Icons.takeout_dining;
      case "Delivery":
        return Icons.delivery_dining;
      default:
        return Icons.receipt;
    }
  }
}
