import 'models/models.dart';

// Dummy cart data for tables
class DummyData {
  // Static dummy cart data mapped to table IDs
  static Map<int, Map<String, dynamic>> tableCartData = {
    // Table 1 - occupied with some orders
    1: {
      'cart': {
        'id': 1,
        'tableId': 1,
        'userId': 1, // Admin user
        'status': 'open',
        'createdAt': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'cartItems': [
        {
          'id': 1,
          'cartId': 1,
          'itemId': 1,
          'quantity': 2,
          'rate': 250.0,
          'totalPrice': 500.0,
          'notes': null,
          'createdAt': DateTime.now().subtract(Duration(minutes: 25)).toIso8601String(),
          'menuItem': {
            'id': 1,
            'categoryId': 1,
            'itemName': 'Chicken Momo',
            'description': 'Steamed chicken dumplings with special sauce',
            'rate': 250.0,
            'image': null,
            'isAvailable': true,
          }
        },
        {
          'id': 2,
          'cartId': 1,
          'itemId': 3,
          'quantity': 1,
          'rate': 180.0,
          'totalPrice': 180.0,
          'notes': 'Extra spicy',
          'createdAt': DateTime.now().subtract(Duration(minutes: 20)).toIso8601String(),
          'menuItem': {
            'id': 3,
            'categoryId': 1,
            'itemName': 'Pork Momo',
            'description': 'Steamed pork dumplings',
            'rate': 180.0,
            'image': null,
            'isAvailable': true,
          }
        }
      ]
    },

    // Table 2 - has different items
    2: {
      'cart': {
        'id': 2,
        'tableId': 2,
        'userId': 1, // Admin user
        'status': 'open',
        'createdAt': DateTime.now().subtract(Duration(minutes: 15)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'cartItems': [
        {
          'id': 3,
          'cartId': 2,
          'itemId': 5,
          'quantity': 3,
          'rate': 120.0,
          'totalPrice': 360.0,
          'notes': null,
          'createdAt': DateTime.now().subtract(Duration(minutes: 12)).toIso8601String(),
          'menuItem': {
            'id': 5,
            'categoryId': 2,
            'itemName': 'Fried Rice',
            'description': 'Special fried rice with vegetables',
            'rate': 120.0,
            'image': null,
            'isAvailable': true,
          }
        },
        {
          'id': 4,
          'cartId': 2,
          'itemId': 6,
          'quantity': 2,
          'rate': 200.0,
          'totalPrice': 400.0,
          'notes': null,
          'createdAt': DateTime.now().subtract(Duration(minutes: 10)).toIso8601String(),
          'menuItem': {
            'id': 6,
            'categoryId': 2,
            'itemName': 'Chicken Chowmein',
            'description': 'Stir-fried noodles with chicken and vegetables',
            'rate': 200.0,
            'image': null,
            'isAvailable': true,
          }
        }
      ]
    },

    // Table 3 - has different items
    3: {
      'cart': {
        'id': 3,
        'tableId': 3,
        'userId': 1, // Admin user
        'status': 'open',
        'createdAt': DateTime.now().subtract(Duration(minutes: 45)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'cartItems': [
        {
          'id': 5,
          'cartId': 3,
          'itemId': 8,
          'quantity': 1,
          'rate': 350.0,
          'totalPrice': 350.0,
          'notes': null,
          'createdAt': DateTime.now().subtract(Duration(minutes: 40)).toIso8601String(),
          'menuItem': {
            'id': 8,
            'categoryId': 3,
            'itemName': 'Dal Bhat Set',
            'description': 'Traditional Nepali meal with rice, lentils, and curry',
            'rate': 350.0,
            'image': null,
            'isAvailable': true,
          }
        }
      ]
    },

    // Table 5 - another table with items
    5: {
      'cart': {
        'id': 4,
        'tableId': 5,
        'userId': 1, // Admin user
        'status': 'open',
        'createdAt': DateTime.now().subtract(Duration(minutes: 60)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'cartItems': [
        {
          'id': 6,
          'cartId': 4,
          'itemId': 10,
          'quantity': 2,
          'rate': 80.0,
          'totalPrice': 160.0,
          'notes': null,
          'createdAt': DateTime.now().subtract(Duration(minutes: 55)).toIso8601String(),
          'menuItem': {
            'id': 10,
            'categoryId': 4,
            'itemName': 'Milk Tea',
            'description': 'Traditional Nepali milk tea',
            'rate': 80.0,
            'image': null,
            'isAvailable': true,
          }
        },
        {
          'id': 7,
          'cartId': 4,
          'itemId': 11,
          'quantity': 1,
          'rate': 150.0,
          'totalPrice': 150.0,
          'notes': 'No sugar',
          'createdAt': DateTime.now().subtract(Duration(minutes: 50)).toIso8601String(),
          'menuItem': {
            'id': 11,
            'categoryId': 4,
            'itemName': 'Fresh Juice',
            'description': 'Seasonal fresh fruit juice',
            'rate': 150.0,
            'image': null,
            'isAvailable': true,
          }
        }
      ]
    },

    // Tables 4, 6, 7, 8 are empty (no cart data)
  };

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
