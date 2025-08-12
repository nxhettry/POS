import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data.dart';
import 'data_repository.dart';

class TableCartManager extends ChangeNotifier {
  static final TableCartManager _instance = TableCartManager._internal();
  factory TableCartManager() => _instance;
  TableCartManager._internal();

  int? _selectedTableId;
  final List<CartItem> _cartItems = [];
  final DataRepository _dataRepository = DataRepository();

  bool _useDummyData = false;
  int? _currentCartId;
  Map<int, int> _cartItemIds = {};

  int? get selectedTableId => _selectedTableId;
  int? get currentCartId => _currentCartId;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isEmpty => _cartItems.isEmpty;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> setSelectedTable(int? tableId) async {
    if (_selectedTableId != tableId) {
      _selectedTableId = tableId;
      await _loadTableCart();
      notifyListeners();
    }
  }

  Future<void> _loadTableCart() async {
    _cartItems.clear();
    _currentCartId = null;
    _cartItemIds.clear();

    if (_selectedTableId == null) return;

    if (_useDummyData) {
      final tableCartItems = DummyData.getTableCartItems(_selectedTableId!);
      _cartItems.addAll(tableCartItems);

      final cartData = DummyData.getTableCartData(_selectedTableId!);
      if (cartData != null && cartData['cart'] != null) {
        _currentCartId = cartData['cart']['id'];
      }
    } else {
      try {
        final cartData = await _dataRepository.getCartByTable(
          _selectedTableId!,
        );
        if (cartData.isNotEmpty) {
          _currentCartId = cartData['id'];
          final cartItemsList = await _dataRepository.getCartItems(
            _currentCartId!,
          );

          for (final itemData in cartItemsList) {
            final menuItem = itemData['MenuItem'] ?? {};
            final item = {
              'id': menuItem['id'],
              'item_name': menuItem['itemName'] ?? menuItem['item_name'],
              'rate': (menuItem['rate'] ?? itemData['rate']).toDouble(),
              'image': menuItem['image'],
              'description': menuItem['description'],
              'categoryId': menuItem['categoryId'] ?? menuItem['category_id'],
              'isAvailable':
                  menuItem['isAvailable'] ?? menuItem['is_available'] ?? true,
            };

            final cartItem = CartItem(
              item: item,
              quantity: (itemData['quantity'] ?? 0).round(),
            );
            _cartItems.add(cartItem);

            _cartItemIds[menuItem['id']] = itemData['id'];
          }
        }
      } catch (e) {
        print('Error loading cart from API: $e');
      }
    }
  }

  Future<void> addItem(Map<String, dynamic> item, int quantity) async {
    if (_selectedTableId == null) return;

    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == item['id'],
    );

    if (existingIndex >= 0) {
      final newQuantity = _cartItems[existingIndex].quantity + quantity;

      if (!_useDummyData &&
          _currentCartId != null &&
          _cartItemIds.containsKey(item['id'])) {
        try {
          await _dataRepository.updateCartItem(
            _cartItemIds[item['id']]!,
            newQuantity,
            item['rate'].toDouble(),
          );
          _cartItems[existingIndex].quantity = newQuantity;
        } catch (e) {
          print('Error updating cart item via API: $e');
          return;
        }
      } else {
        _cartItems[existingIndex].quantity = newQuantity;
      }
    } else {
      final cartItem = CartItem(item: item, quantity: quantity);

      if (!_useDummyData) {
        if (_currentCartId == null) {
          try {
            final cartData = await _dataRepository.createCart(
              _selectedTableId!,
            );
            _currentCartId = cartData['id'];
          } catch (e) {
            print('Error creating cart via API: $e');
            return;
          }
        }

        try {
          await _dataRepository.addItemToCart(
            _currentCartId!,
            item['id'],
            quantity,
            item['rate'].toDouble(),
          );

          await _loadTableCart();
          notifyListeners();
          return;
        } catch (e) {
          print('Error adding item to cart via API: $e');
          return;
        }
      }

      _cartItems.add(cartItem);
    }

    if (_useDummyData) {
      _saveToDummyData();
    }

    notifyListeners();
  }

  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
    if (_selectedTableId == null) return;

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == itemId,
    );

    if (index >= 0) {
      if (newQuantity <= 0) {
        if (!_useDummyData && _cartItemIds.containsKey(itemId)) {
          try {
            await _dataRepository.removeCartItem(_cartItemIds[itemId]!);
            _cartItemIds.remove(itemId);
          } catch (e) {
            print('Error removing cart item via API: $e');
            return;
          }
        }
        _cartItems.removeAt(index);
      } else {
        if (!_useDummyData && _cartItemIds.containsKey(itemId)) {
          try {
            await _dataRepository.updateCartItem(
              _cartItemIds[itemId]!,
              newQuantity,
              _cartItems[index].item['rate'].toDouble(),
            );
          } catch (e) {
            print('Error updating cart item via API: $e');
            return;
          }
        }
        _cartItems[index].quantity = newQuantity;
      }

      if (_useDummyData) {
        _saveToDummyData();
      }

      notifyListeners();
    }
  }

  Future<void> removeItem(int itemId) async {
    await updateItemQuantity(itemId, 0);
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _cartItemIds.clear();

    if (_useDummyData) {
      if (_selectedTableId != null) {
        DummyData.clearTableCart(_selectedTableId!);
      }
    } else if (_currentCartId != null) {
      try {
        await _dataRepository.clearCartItems(_currentCartId!);
      } catch (e) {
        print('Error clearing cart via API: $e');
      }
    }

    _currentCartId = null;
    notifyListeners();
  }

  void _saveToDummyData() {
    if (_selectedTableId == null) return;

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
      'tableId': _selectedTableId,
      'items': _cartItems.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'taxRate': taxRate,
      'discount': discount,
      'discountValue': discountValue,
      'isDiscountPercentage': isDiscountPercentage,
      'total': total,
      'timestamp': DateTime.now().toIso8601String(),
      'orderStatus': 'served',
      'paymentStatus': 'pending',
      'createdBy': 1,
    };
  }

  Future<Map<String, dynamic>?> checkout(Map<String, dynamic> orderData) async {
    if (_useDummyData || _currentCartId == null) {
      await clearCart();
      return {
        'success': true,
        'orderId': DateTime.now().millisecondsSinceEpoch,
      };
    } else {
      try {
        final result = await _dataRepository.checkout(
          _currentCartId!,
          orderData,
        );
        await clearCart();
        return result;
      } catch (e) {
        print('Error during checkout: $e');
        throw e;
      }
    }
  }

  void setUseDummyData(bool useDummy) {
    _useDummyData = useDummy;

    if (_selectedTableId != null) {
      _loadTableCart();
    }
  }

  static Future<bool> hasActiveCart(int tableId) async {
    try {
      final dataRepository = DataRepository();
      final cartData = await dataRepository.getCartByTable(tableId);
      return cartData.isNotEmpty;
    } catch (e) {
      print('Error checking table cart status: $e');
      return false;
    }
  }

  static Future<int> getTableItemCount(int tableId) async {
    try {
      final dataRepository = DataRepository();
      final cartData = await dataRepository.getCartByTable(tableId);
      if (cartData.isEmpty) return 0;

      final cartItems = await dataRepository.getCartItems(cartData['id']);
      return cartItems.fold<int>(
        0,
        (sum, item) => sum + ((item['quantity'] ?? 0) as int),
      );
    } catch (e) {
      print('Error getting table cart item count: $e');
      return 0;
    }
  }

  static Future<double> getTableTotal(int tableId) async {
    try {
      final dataRepository = DataRepository();
      final cartData = await dataRepository.getCartByTable(tableId);
      if (cartData.isEmpty) return 0.0;

      final cartItems = await dataRepository.getCartItems(cartData['id']);
      return cartItems.fold<double>(0.0, (sum, item) {
        final quantity = (item['quantity'] ?? 0) as int;
        final rate = ((item['rate'] ?? 0) as num).toDouble();
        return sum + (quantity * rate);
      });
    } catch (e) {
      print('Error getting table cart total: $e');
      return 0.0;
    }
  }
}
