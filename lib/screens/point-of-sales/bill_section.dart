import "package:flutter/material.dart";
import "package:pos/services/database_service.dart";
import "../../data/cart_manager.dart";
import "../../models/models.dart" as models;
import 'dart:developer' as developer;

class BillSection extends StatefulWidget {
  const BillSection({super.key});

  @override
  State<BillSection> createState() => _BillSectionState();
}

class _BillSectionState extends State<BillSection> {
  String? selectedTable;
  String? selectedTax = "0%";
  String? selectedOrderType = "dine_in";
  double discountValue = 0.00;
  bool isDiscountPercentage = true;
  late final CartManager cartManager;
  final TextEditingController discountController = TextEditingController();
  List<models.Table> availableTables = [];
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    cartManager = CartManager();
    cartManager.addListener(_onCartChanged);
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await _dbService.getTables();
      setState(() {
        availableTables = tables;
      });
    } catch (e) {
      developer.log('Error loading tables: $e', name: 'BillSection');
    }
  }

  @override
  void dispose() {
    cartManager.removeListener(_onCartChanged);
    discountController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    developer.log('Cart changed! Items count: ${cartManager.cartItems.length}', name: 'BillSection');
    if (mounted) {
      setState(() {});
    }
  }

  double get taxRate {
    switch (selectedTax) {
      case "13%":
        return 0.13;
      default:
        return 0.0;
    }
  }

  double get subtotal => cartManager.subtotal;
  double get tax => cartManager.calculateTax(taxRate);
  double get discount =>
      cartManager.calculateDiscount(discountValue, isDiscountPercentage);
  double get total =>
      cartManager.calculateTotal(taxRate, discountValue, isDiscountPercentage);

  Future<void> _placeOrder() async {
    if (cartManager.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cart is empty! Please add items before placing order.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final orderData = cartManager.getOrderData(
      selectedTable,
      selectedOrderType == "dine_in" ? "Dine In" : "Takeaway",
      taxRate,
      discountValue,
      isDiscountPercentage,
    );

    // Log order data to console
    developer.log('Order placed successfully!', name: 'POS');
    developer.log('Order Data: ${orderData.toString()}', name: 'POS');

    // Db operation to save order
    try {
      // Get the next invoice number from database
      final invoiceNo = await DatabaseService().getNextInvoiceNumber();
      developer.log('Generated invoice number: $invoiceNo', name: 'POS');
      
      // Update the order data with the proper invoice number
      orderData['invoiceNo'] = invoiceNo;
      
      final sale = models.Sales.fromMap(orderData);
      developer.log('Sales object created: ${sale.invoiceNo}', name: 'POS');
      
      final saleId = await DatabaseService().saveSale(sale);
      developer.log('Sale saved with ID: $saleId', name: 'POS');
    } catch (e) {
      developer.log('Error saving sale: $e', name: 'POS');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return; // Don't clear cart if save failed
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${orderData['invoiceNo']} placed successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Clear cart after successful order
    cartManager.clearCart();

    // Reset form fields
    setState(() {
      selectedTable = null;
      selectedOrderType = "dine_in";
      selectedTax = "0%";
      discountValue = 0.00;
      discountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Text(
                  "Sales Invoice",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Invoice No: #111",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Table No",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    value: selectedTable,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          availableTables.isEmpty 
                            ? "Loading tables..." 
                            : "Select a Table",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      for (var table in availableTables)
                        DropdownMenuItem<String>(
                          value: table.name,
                          child: Text(table.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTable = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Dine In / Takeaway",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    value: selectedOrderType,
                    items: [
                      DropdownMenuItem(
                        value: "dine_in",
                        child: Text("Dine In"),
                      ),
                      DropdownMenuItem(
                        value: "takeaway",
                        child: Text("Takeaway"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOrderType = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          // Items Section
          Expanded(
            child: AnimatedBuilder(
              animation: cartManager,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (cartManager.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items in cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add items from the menu to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...cartManager.cartItems.map(
                          (cartItem) => buildItemRow(cartItem),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Tax and Discount Section
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                // Tax Section
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Tax",
                        labelStyle: TextStyle(fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                      ),
                      value: selectedTax,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      items: [
                        DropdownMenuItem(
                          value: "0%", 
                          child: Text("0%", style: TextStyle(fontSize: 14))
                        ),
                        DropdownMenuItem(
                          value: "13%", 
                          child: Text("13%", style: TextStyle(fontSize: 14))
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedTax = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Discount Section
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: discountController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Discount",
                        labelStyle: TextStyle(fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          discountValue = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 45,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: DropdownButton<String>(
                    value: isDiscountPercentage ? "%" : "\$",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: "%", 
                        child: Text("%", style: TextStyle(fontSize: 14))
                      ),
                      DropdownMenuItem(
                        value: "\$", 
                        child: Text("Rs.", style: TextStyle(fontSize: 14))
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        isDiscountPercentage = value == "%";
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Calculation and Total Section
          SizedBox(height: 12),
          Divider(height: 1),
          AnimatedBuilder(
            animation: cartManager,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          "Rs. ${subtotal.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tax ($selectedTax)",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          "Rs. ${tax.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          "-Rs. ${discount.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Rs. ${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Place Order Button
          SizedBox(height: 12),
          AnimatedBuilder(
            animation: cartManager,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartManager.isEmpty
                        ? Colors.grey
                        : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    cartManager.isEmpty ? "Add Items to Cart" : "Place Order",
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildItemRow(models.CartItem cartItem) {
    final item = cartItem.item;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs. ${item['rate']} each",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red, size: 18),
                    onPressed: () {
                      if (cartItem.quantity > 1) {
                        cartManager.updateItemQuantity(
                          item['id'],
                          cartItem.quantity - 1,
                        );
                      } else {
                        cartManager.removeItem(item['id']);
                      }
                    },
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "${cartItem.quantity}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.green, size: 18),
                    onPressed: () {
                      cartManager.updateItemQuantity(
                        item['id'],
                        cartItem.quantity + 1,
                      );
                    },
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Total price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rs. ${cartItem.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Remove button
                TextButton(
                  onPressed: () {
                    cartManager.removeItem(item['id']);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: Text(
                    "Remove",
                    style: TextStyle(fontSize: 12, color: Colors.red[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
