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

  Item({required this.id, required this.categoryId, required this.itemName, required this.rate});
}
