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
  
  // Flag to determine if we're using dummy data or real API
  bool _useDummyData = true;
  int? _currentCartId;

  int? get selectedTableId => _selectedTableId;
  int? get currentCartId => _currentCartId;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isEmpty => _cartItems.isEmpty;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // Set the selected table and load its cart data
  Future<void> setSelectedTable(int? tableId) async {
    if (_selectedTableId != tableId) {
      _selectedTableId = tableId;
      await _loadTableCart();
      notifyListeners();
    }
  }

  // Load cart items for the selected table
  Future<void> _loadTableCart() async {
    _cartItems.clear();
    _currentCartId = null;
    
    if (_selectedTableId == null) return;

    if (_useDummyData) {
      // Load from dummy data
      final tableCartItems = DummyData.getTableCartItems(_selectedTableId!);
      _cartItems.addAll(tableCartItems);
      
      // Set dummy cart ID if table has cart
      final cartData = DummyData.getTableCartData(_selectedTableId!);
      if (cartData != null && cartData['cart'] != null) {
        _currentCartId = cartData['cart']['id'];
      }
    } else {
      // Load from real API
      try {
        final cartData = await _dataRepository.getCartByTable(_selectedTableId!);
        if (cartData != null && cartData.isNotEmpty) {
          _currentCartId = cartData['id'];
          final cartItemsList = await _dataRepository.getCartItems(_currentCartId!);
          
          for (final itemData in cartItemsList) {
            final menuItem = itemData['MenuItem'] ?? {};
            final item = {
              'id': menuItem['id'],
              'item_name': menuItem['itemName'] ?? menuItem['item_name'],
              'rate': menuItem['rate'] ?? itemData['rate'],
              'image': menuItem['image'],
              'description': menuItem['description'],
              'categoryId': menuItem['categoryId'] ?? menuItem['category_id'],
              'isAvailable': menuItem['isAvailable'] ?? menuItem['is_available'] ?? true,
            };
            
            _cartItems.add(CartItem(
              item: item,
              quantity: (itemData['quantity'] ?? 0).round(),
            ));
          }
        }
      } catch (e) {
        print('Error loading cart from API: $e');
        // Fall back to dummy data on error
        final tableCartItems = DummyData.getTableCartItems(_selectedTableId!);
        _cartItems.addAll(tableCartItems);
      }
    }
  }

  // Add item to cart
  Future<void> addItem(Map<String, dynamic> item, int quantity) async {
    if (_selectedTableId == null) return;

    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item['id'] == item['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
      
      if (!_useDummyData && _currentCartId != null) {
        // Update via API
        try {
          final cartItemData = _cartItems[existingIndex];
          // You would need to track cart item IDs for API updates
          // For now, we'll implement this when integrating with real API
        } catch (e) {
          print('Error updating cart item via API: $e');
        }
      }
    } else {
      _cartItems.add(CartItem(item: item, quantity: quantity));
      
      if (!_useDummyData) {
        // Create cart if doesn't exist
        if (_currentCartId == null) {
          try {
            final cartData = await _dataRepository.createCart(_selectedTableId!);
            _currentCartId = cartData['id'];
          } catch (e) {
            print('Error creating cart via API: $e');
            return;
          }
        }
        
        // Add item via API
        try {
          await _dataRepository.addItemToCart(
            _currentCartId!,
            item['id'],
            quantity,
            item['rate'].toDouble(),
          );
        } catch (e) {
          print('Error adding item to cart via API: $e');
        }
      }
    }

    // Save to dummy data for consistency
    if (_useDummyData) {
      _saveToDummyData();
    }
    
    notifyListeners();
  }

  // Update item quantity
  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
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
      
      // Save changes
      if (_useDummyData) {
        _saveToDummyData();
      }
      
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeItem(int itemId) async {
    await updateItemQuantity(itemId, 0);
  }

  // Clear cart
  Future<void> clearCart() async {
    _cartItems.clear();
    
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

  // Save current cart state to dummy data
  void _saveToDummyData() {
    if (_selectedTableId == null) return;
    
    // Clear existing cart items for this table
    DummyData.clearTableCart(_selectedTableId!);
    
    // Add current cart items back to dummy data
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
      DummyData.addItemToTableCart(_selectedTableId!, menuItem, cartItem.quantity);
    }
  }

  // Calculate tax
  double calculateTax(double taxRate) {
    return subtotal * taxRate;
  }

  // Calculate discount
  double calculateDiscount(double discountValue, bool isPercentage) {
    if (isPercentage) {
      return subtotal * (discountValue / 100);
    } else {
      return discountValue;
    }
  }

  // Calculate total
  double calculateTotal(double taxRate, double discountValue, bool isDiscountPercentage) {
    final tax = calculateTax(taxRate);
    final discount = calculateDiscount(discountValue, isDiscountPercentage);
    return subtotal + tax - discount;
  }

  // Get order data for checkout
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
      'invoiceNo': 'TEMP', // This will be replaced with auto-generated invoice number
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
      'orderStatus': 'served', // Order is completed when creating from POS
      'paymentStatus': 'pending',
      'createdBy': 1, // Admin user
    };
  }

  // Perform checkout
  Future<Map<String, dynamic>?> checkout(Map<String, dynamic> orderData) async {
    if (_useDummyData || _currentCartId == null) {
      // For dummy data, just clear the cart after successful order
      await clearCart();
      return {'success': true, 'orderId': DateTime.now().millisecondsSinceEpoch};
    } else {
      // Use real API checkout
      try {
        final result = await _dataRepository.checkout(_currentCartId!, orderData);
        await clearCart();
        return result;
      } catch (e) {
        print('Error during checkout: $e');
        throw e;
      }
    }
  }

  // Toggle between dummy data and real API
  void setUseDummyData(bool useDummy) {
    _useDummyData = useDummy;
    // Reload current table cart with new data source
    if (_selectedTableId != null) {
      _loadTableCart();
    }
  }
}
