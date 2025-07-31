import 'package:flutter/foundation.dart';
import '../models.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  bool get isEmpty => _cartItems.isEmpty;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Map<String, dynamic> item, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == item['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(item: item, quantity: quantity));
    }

    notifyListeners();
  }

  void updateItemQuantity(int itemId, int newQuantity) {
    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == itemId,
    );

    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item['id'] == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
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
      'invoiceNo': '#${DateTime.now().millisecondsSinceEpoch}',
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
