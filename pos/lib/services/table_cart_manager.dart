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

          print(
            'Loading cart for table $_selectedTableId with ${cartItemsList.length} items',
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
              'notes': itemData['notes'],
            };

            final cartItem = CartItem(
              item: item,
              quantity: (itemData['quantity'] ?? 0).round(),
              notes: itemData['notes']?.toString(),
            );
            _cartItems.add(cartItem);

            _cartItemIds[menuItem['id']] = itemData['id'];
          }

          print(
            'Loaded ${_cartItems.length} items into cart for table $_selectedTableId',
          );
        }
      } catch (e) {
        print('Error loading cart from API: $e');
      }
    }

    notifyListeners();
  }

  Future<void> addItem(
    Map<String, dynamic> item,
    int quantity, {
    String? notes,
  }) async {
    if (_selectedTableId == null) return;

    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == item['id'],
    );

    bool itemAdded = false;
    int oldQuantity = 0;

    if (existingIndex >= 0) {
      oldQuantity = _cartItems[existingIndex].quantity;
      final newQuantity = _cartItems[existingIndex].quantity + quantity;
      _cartItems[existingIndex].quantity = newQuantity;

      if (notes != null) {
        _cartItems[existingIndex].notes = notes;
        _cartItems[existingIndex].item['notes'] = notes;
      }
    } else {
      if (notes != null) {
        item['notes'] = notes;
      }

      final cartItem = CartItem(item: item, quantity: quantity, notes: notes);
      _cartItems.add(cartItem);
      itemAdded = true;
    }

    // Update UI immediately
    notifyListeners();

    if (!_useDummyData) {
      try {
        await _syncCartToServer();
      } catch (e) {
        print('Failed to sync cart addition to server: $e');
        // Revert the change if sync fails
        if (itemAdded) {
          _cartItems.removeLast();
        } else if (existingIndex >= 0) {
          _cartItems[existingIndex].quantity = oldQuantity;
        }
        notifyListeners();
      }
    } else {
      _saveToDummyData();
    }
  }

  Future<void> _syncCartToServer() async {
    if (_selectedTableId == null || _useDummyData) return;

    try {
      print(
        'Syncing cart to server for table $_selectedTableId with ${_cartItems.length} items',
      );

      final items = _cartItems
          .map(
            (cartItem) => {
              'itemId': cartItem.item['id'],
              'quantity': cartItem.quantity,
              'rate': cartItem.item['rate'],
              'totalPrice': cartItem.totalPrice,
              if (cartItem.notes != null && cartItem.notes!.isNotEmpty)
                'notes': cartItem.notes,
            },
          )
          .toList();

      final result = await _dataRepository.updateCartWithItems(
        _currentCartId,
        _selectedTableId!,
        items,
      );

      if (result['cartId'] != null) {
        _currentCartId = result['cartId'];
      }

      print('Cart sync completed successfully');
      
      // Reload cart from server to ensure consistency
      await _loadTableCart();
    } catch (e) {
      print('Error syncing cart to server: $e');
      // Don't rethrow the error, just log it and let the UI continue
      // The local state will be preserved and user can try again
    }
  }

  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
    if (_selectedTableId == null) return;

    print('Updating item $itemId quantity to $newQuantity');

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == itemId,
    );

    if (index >= 0) {
      final oldQuantity = _cartItems[index].quantity;
      
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
        print('Removed item $itemId from cart');
      } else {
        _cartItems[index].quantity = newQuantity;
        print('Updated item $itemId quantity to $newQuantity');
      }

      // Update UI immediately
      notifyListeners();

      if (!_useDummyData) {
        try {
          await _syncCartToServer();
        } catch (e) {
          print('Failed to sync cart update to server: $e');
          // Revert the change if sync fails
          if (newQuantity <= 0) {
            // For simplicity, just reload the cart from server on error
            await _loadTableCart();
          } else if (index < _cartItems.length) {
            _cartItems[index].quantity = oldQuantity;
          }
          notifyListeners();
        }
      } else {
        _saveToDummyData();
      }
    }
  }

  Future<void> removeItem(int itemId) async {
    await updateItemQuantity(itemId, 0);
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _cartItemIds.clear();

    if (!_useDummyData) {
      await _syncCartToServer();
    } else if (_selectedTableId != null) {
      DummyData.clearTableCart(_selectedTableId!);
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
