import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  int? _selectedTableId;
  final List<CartItem> _cartItems = [];

  int? get selectedTableId => _selectedTableId;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  bool get isEmpty => _cartItems.isEmpty;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void setSelectedTable(int? tableId) {
    if (_selectedTableId != tableId) {
      _selectedTableId = tableId;
      _loadTableCart();
      notifyListeners();
    }
  }

  void _loadTableCart() {
    _cartItems.clear();
    if (_selectedTableId != null) {
      final tableCartItems = DummyData.getTableCartItems(_selectedTableId!);
      _cartItems.addAll(tableCartItems);
    }
  }

  void _saveTableCart() {
    if (_selectedTableId != null) {
      DummyData.clearTableCart(_selectedTableId!);

      for (final cartItem in _cartItems) {
        final menuItem = {
          'id': cartItem.item['id'],
          'itemName': cartItem.item['item_name'],
          'description': cartItem.item['description'],
          'rate': cartItem.item['rate'],
          'image': cartItem.item['image'],
          'categoryId': cartItem.item['categoryId'],
          'isAvailable': cartItem.item['isAvailable'] ?? true,
        };
        DummyData.addItemToTableCart(
          _selectedTableId!,
          menuItem,
          cartItem.quantity,
        );
      }
    }
  }

  void addItem(Map<String, dynamic> item, int quantity) {
    if (_selectedTableId == null) {
      return;
    }

    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == item['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(item: item, quantity: quantity));
    }

    _saveTableCart();
    notifyListeners();
  }

  void updateItemQuantity(int itemId, int newQuantity) {
    if (_selectedTableId == null) return;

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == itemId,
    );

    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      _saveTableCart();
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    if (_selectedTableId == null) return;

    _cartItems.removeWhere((cartItem) => cartItem.item['id'] == itemId);
    _saveTableCart();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    if (_selectedTableId != null) {
      DummyData.clearTableCart(_selectedTableId!);
    }
    notifyListeners();
  }

  double calculateTax(double taxRate) {
    return subtotal * taxRate;
  }

  double calculateDiscount(double discountValue, bool isPercentage) {
    if (isPercentage) {
      return subtotal * (discountValue / 100);
    } else {
      return discountValue;
    }
  }

  double calculateTotal(
    double taxRate,
    double discountValue,
    bool isDiscountPercentage,
  ) {
    final tax = calculateTax(taxRate);
    final discount = calculateDiscount(discountValue, isDiscountPercentage);
    return subtotal + tax - discount;
  }

  Map<String, dynamic> getOrderData(
    String? selectedTable,
    String? orderType,
    double taxRate,
    double discountValue,
    bool isDiscountPercentage,
  ) {
    final tax = calculateTax(taxRate);
    final discount = calculateDiscount(discountValue, isDiscountPercentage);
    final total = calculateTotal(taxRate, discountValue, isDiscountPercentage);

    return {
      'invoiceNo': 'TEMP',
      'table': selectedTable ?? 'No Table',
      'orderType': orderType ?? 'Dine In',
      'items': _cartItems.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'taxRate': taxRate,
      'discount': discount,
      'discountValue': discountValue,
      'isDiscountPercentage': isDiscountPercentage,
      'total': total,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
