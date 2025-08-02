import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../data/sales.dart";
import "../../models/models.dart";

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String selectedFilter = "All";
  final List<String> filterOptions = ["All", "Dine In", "Takeaway", "Delivery"];

  List<Sales> get filteredSales {
    if (selectedFilter == "All") {
      return salesData;
    }
    return salesData.where((sale) => sale.orderType == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Order History",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredSales.length} Orders",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterOptions.length,
                    itemBuilder: (context, index) {
                      final option = filterOptions[index];
                      final isSelected = selectedFilter == option;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = option;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[100],
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue[700]
                                : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blue[300]!
                                : Colors.grey[300]!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSales.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return _buildOrderCard(sale);
                    },
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
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No orders found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Orders will appear here once they are placed",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Sales sale) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...sale.items.map((cartItem) => _buildItemRow(cartItem)),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),
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
                  "Tax (${sale.taxRate}%)",
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
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              child: Image.asset(
                cartItem.item['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.fastfood, color: Colors.grey[400]);
                },
              ),
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
                    fontSize: 14,
                  ),
                ),
                Text(
                  "₹${cartItem.item['rate']} × ${cartItem.quantity}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "₹${cartItem.totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
