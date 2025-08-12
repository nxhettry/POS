import 'models/models.dart';

// Dummy cart data for tables - DEPRECATED: Now using real API data
class DummyData {
  // Static dummy cart data mapped to table IDs - Empty by default as we use real API
  static Map<int, Map<String, dynamic>> tableCartData = {};

  // Helper method to get cart data for a table
  static Map<String, dynamic>? getTableCartData(int tableId) {
    return tableCartData[tableId];
  }

  // Helper method to check if table has active cart
  static bool tableHasActiveCart(int tableId) {
    final cartData = tableCartData[tableId];
    return cartData != null && 
           cartData['cart'] != null && 
           cartData['cart']['status'] == 'open';
  }

  // Helper method to get cart items for a table as CartItem objects
  static List<CartItem> getTableCartItems(int tableId) {
    final cartData = tableCartData[tableId];
    if (cartData == null || cartData['cartItems'] == null) {
      return [];
    }

    final cartItems = cartData['cartItems'] as List<dynamic>;
    return cartItems.map((itemData) {
      final menuItem = itemData['menuItem'];
      // Convert to the format expected by CartItem
      final item = {
        'id': menuItem['id'],
        'item_name': menuItem['itemName'],
        'rate': menuItem['rate'],
        'image': menuItem['image'],
        'description': menuItem['description'],
        'categoryId': menuItem['categoryId'],
        'isAvailable': menuItem['isAvailable'],
      };
      return CartItem(
        item: item,
        quantity: itemData['quantity'],
      );
    }).toList();
  }

  // Helper method to calculate table cart total
  static double getTableCartTotal(int tableId) {
    final cartItems = getTableCartItems(tableId);
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Helper method to get table cart item count
  static int getTableCartItemCount(int tableId) {
    final cartItems = getTableCartItems(tableId);
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Method to clear table cart
  static void clearTableCart(int tableId) {
    if (tableCartData.containsKey(tableId)) {
      tableCartData[tableId]!['cartItems'] = [];
      tableCartData[tableId]!['cart']['status'] = 'closed';
      tableCartData[tableId]!['cart']['updatedAt'] = DateTime.now().toIso8601String();
    }
  }

  // Method to add item to table cart
  static void addItemToTableCart(int tableId, Map<String, dynamic> menuItem, int quantity) {
    // Create cart if doesn't exist
    if (!tableCartData.containsKey(tableId)) {
      final cartId = tableCartData.length + 1;
      tableCartData[tableId] = {
        'cart': {
          'id': cartId,
          'tableId': tableId,
          'userId': 1,
          'status': 'open',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        'cartItems': []
      };
    }

    final cartItems = tableCartData[tableId]!['cartItems'] as List<dynamic>;
    final existingItemIndex = cartItems.indexWhere((item) => 
      item['menuItem']['id'] == menuItem['id']
    );

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = cartItems[existingItemIndex];
      existingItem['quantity'] += quantity;
      existingItem['totalPrice'] = existingItem['quantity'] * existingItem['rate'];
    } else {
      // Add new item
      final newCartItem = {
        'id': cartItems.length + 1,
        'cartId': tableCartData[tableId]!['cart']['id'],
        'itemId': menuItem['id'],
        'quantity': quantity,
        'rate': menuItem['rate'],
        'totalPrice': menuItem['rate'] * quantity,
        'notes': null,
        'createdAt': DateTime.now().toIso8601String(),
        'menuItem': menuItem,
      };
      cartItems.add(newCartItem);
    }

    // Update cart timestamp
    tableCartData[tableId]!['cart']['updatedAt'] = DateTime.now().toIso8601String();
  }

  // Method to update item quantity in table cart
  static void updateTableCartItemQuantity(int tableId, int itemId, int newQuantity) {
    if (!tableCartData.containsKey(tableId)) return;

    final cartItems = tableCartData[tableId]!['cartItems'] as List<dynamic>;
    final itemIndex = cartItems.indexWhere((item) => 
      item['menuItem']['id'] == itemId
    );

    if (itemIndex >= 0) {
      if (newQuantity <= 0) {
        cartItems.removeAt(itemIndex);
      } else {
        cartItems[itemIndex]['quantity'] = newQuantity;
        cartItems[itemIndex]['totalPrice'] = newQuantity * cartItems[itemIndex]['rate'];
      }
      
      // Update cart timestamp
      tableCartData[tableId]!['cart']['updatedAt'] = DateTime.now().toIso8601String();
    }
  }

  // Method to remove item from table cart
  static void removeItemFromTableCart(int tableId, int itemId) {
    updateTableCartItemQuantity(tableId, itemId, 0);
  }
}
