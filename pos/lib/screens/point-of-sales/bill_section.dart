import "package:flutter/material.dart";
import "../../services/data_repository.dart";
import "../../services/table_cart_manager.dart";
import "../../models/models.dart" as models;
import "../../utils/responsive.dart";
import "../../utils/invoice.dart";
import 'dart:developer' as developer;

class BillSection extends StatefulWidget {
  final models.Table? selectedTable;
  
  const BillSection({super.key, this.selectedTable});

  @override
  State<BillSection> createState() => _BillSectionState();
}

class _BillSectionState extends State<BillSection> {
  String? selectedTax = "0%";
  String? selectedOrderType = "dine_in";
  double discountValue = 0.00;
  bool isDiscountPercentage = true;
  late final TableCartManager cartManager;
  final TextEditingController discountController = TextEditingController();
  List<models.Table> availableTables = [];
  final DataRepository _dataRepository = DataRepository();

  @override
  void initState() {
    super.initState();
    cartManager = TableCartManager();
    cartManager.addListener(_onCartChanged);
    _loadTables();
  }

  @override
  void didUpdateWidget(BillSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When selected table changes, update cart manager
    if (oldWidget.selectedTable?.id != widget.selectedTable?.id) {
      cartManager.setSelectedTable(widget.selectedTable?.id);
    }
  }

  Future<void> _loadTables() async {
    try {
      final tables = await _dataRepository.fetchTables();
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

    if (widget.selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a table before placing the order.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final orderData = cartManager.getOrderData(
      widget.selectedTable!.name,
      selectedOrderType == "dine_in" ? "Dine In" : "Takeaway",
      taxRate,
      discountValue,
      isDiscountPercentage,
    );

    try {
      final invoiceNo = await _dataRepository.getNextInvoiceNumber();
      developer.log('Generated invoice number: $invoiceNo', name: 'POS');
      
      orderData['invoiceNo'] = invoiceNo;
      
      final sale = models.Sales.fromMap(orderData);
      developer.log('Sales object created: ${sale.invoiceNo}', name: 'POS');
      
      final savedSale = await _dataRepository.createSale(sale);
      developer.log('Sale saved with invoice: ${savedSale.invoiceNo}', name: 'POS');
      
      try {
        await reprintInvoice(context, savedSale);
        developer.log('Invoice reprinted successfully: ${savedSale.invoiceNo}', name: 'POS');
      } catch (billError) {
        developer.log('Error reprinting invoice: $billError', name: 'POS');
      }
      
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
      padding: ResponsiveUtils.getPadding(context),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveUtils.getSpacing(context),
            ),
            child: Column(
              children: [
                Text(
                  "Sales Invoice",
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, base: 8)),
                Text(
                  "Invoice No: #111",
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    color: Colors.grey,
                  ),
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
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getSpacing(context, base: 12),
                      horizontal: ResponsiveUtils.getSpacing(context, base: 12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Table: ",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.selectedTable?.name ?? "No Table Selected",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: widget.selectedTable != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
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
                      labelStyle: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context, base: 12),
                        horizontal: ResponsiveUtils.getSpacing(context, base: 12),
                      ),
                    ),
                    value: selectedOrderType,
                    items: [
                      DropdownMenuItem(
                        value: "dine_in",
                        child: Text(
                          "Dine In",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "takeaway",
                        child: Text(
                          "Takeaway",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                        ),
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

          Expanded(
            child: AnimatedBuilder(
              animation: cartManager,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (cartManager.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.getSpacing(context, base: 40),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: ResponsiveUtils.isSmallDesktop(context) ? 60 : 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: ResponsiveUtils.getSpacing(context)),
                              Text(
                                'No items in cart',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.getSpacing(context, base: 8)),
                              Text(
                                'Add items from the menu to get started',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 14),
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

          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getSpacing(context, base: 12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: ResponsiveUtils.isSmallDesktop(context) ? 40 : 45,
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
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 12),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getSpacing(context, base: 8),
                          horizontal: ResponsiveUtils.getSpacing(context, base: 10),
                        ),
                      ),
                      value: selectedTax,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                        color: Colors.black,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "0%", 
                          child: Text(
                            "0%",
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 14),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "13%", 
                          child: Text(
                            "13%",
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 14),
                            ),
                          ),
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
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 12)),
                Expanded(
                  child: Container(
                    height: ResponsiveUtils.isSmallDesktop(context) ? 40 : 45,
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
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                      ),
                      decoration: InputDecoration(
                        labelText: "Discount",
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 12),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getSpacing(context, base: 8),
                          horizontal: ResponsiveUtils.getSpacing(context, base: 10),
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
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                Container(
                  height: ResponsiveUtils.isSmallDesktop(context) ? 40 : 45,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getSpacing(context, base: 8),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: DropdownButton<String>(
                    value: isDiscountPercentage ? "%" : "\$",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                      color: Colors.black,
                    ),
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: "%", 
                        child: Text(
                          "%",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "\$", 
                        child: Text(
                          "Rs.",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                        ),
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

          SizedBox(height: ResponsiveUtils.getSpacing(context, base: 12)),
          Divider(height: 1),
          AnimatedBuilder(
            animation: cartManager,
            builder: (context, child) {
              return Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveUtils.getSpacing(context, base: 12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Rs. ${subtotal.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tax ($selectedTax)",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Rs. ${tax.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "-Rs. ${discount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context, base: 8),
                      ),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Rs. ${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 18),
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

          SizedBox(height: ResponsiveUtils.getSpacing(context, base: 12)),
          AnimatedBuilder(
            animation: cartManager,
            builder: (context, child) {
              return SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.isSmallDesktop(context) ? 44 : 48,
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
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
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
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, base: 8),
      ),
      child: Container(
        padding: ResponsiveUtils.getPadding(context, base: 12),
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
            Container(
              width: ResponsiveUtils.isSmallDesktop(context) ? 45 : 50,
              height: ResponsiveUtils.isSmallDesktop(context) ? 45 : 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item['image'] != null && item['image'].toString().isNotEmpty
                    ? Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.grey[600],
                              size: ResponsiveUtils.isSmallDesktop(context) ? 20 : 24,
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.grey[600],
                          size: ResponsiveUtils.isSmallDesktop(context) ? 20 : 24,
                        ),
                      ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, base: 12)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item_name'],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                  Text(
                    "Rs. ${item['rate']} each",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red,
                      size: ResponsiveUtils.isSmallDesktop(context) ? 16 : 18,
                    ),
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
                    constraints: BoxConstraints(
                      minWidth: ResponsiveUtils.isSmallDesktop(context) ? 28 : 32,
                      minHeight: ResponsiveUtils.isSmallDesktop(context) ? 28 : 32,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getSpacing(context, base: 12),
                  ),
                  child: Text(
                    "${cartItem.quantity}",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
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
                    icon: Icon(
                      Icons.add,
                      color: Colors.green,
                      size: ResponsiveUtils.isSmallDesktop(context) ? 16 : 18,
                    ),
                    onPressed: () {
                      cartManager.updateItemQuantity(
                        item['id'],
                        cartItem.quantity + 1,
                      );
                    },
                    constraints: BoxConstraints(
                      minWidth: ResponsiveUtils.isSmallDesktop(context) ? 28 : 32,
                      minHeight: ResponsiveUtils.isSmallDesktop(context) ? 28 : 32,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: ResponsiveUtils.getSpacing(context, base: 12)),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rs. ${cartItem.totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 12),
                      color: Colors.red[600],
                    ),
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
