class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class Item {
  final int id;
  final int categoryId;
  final String itemName;
  final double rate;

  Item({
    required this.id,
    required this.categoryId,
    required this.itemName,
    required this.rate,
  });
}

class Table {
  final int id;
  final String name;

  Table({required this.id, required this.name});
}

class CartItem {
  final Map<String, dynamic> item;
  int quantity;
  
  CartItem({required this.item, this.quantity = 1});
  
  double get totalPrice => (item['rate'] as num).toDouble() * quantity;
  
  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}
