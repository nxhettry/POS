import "../models.dart";

const List<Map<String, dynamic>> CATEGORIES = [
  {"id": 1, "category_name": "Cold Beverages"},
  {"id": 2, "category_name": "Frappe"},
  {"id": 3, "category_name": "Lassi"},
  {"id": 4, "category_name": "Hakka Noodles"},
  {"id": 5, "category_name": "Fried Rice"},
  {"id": 6, "category_name": "Chowmein"},
  {"id": 7, "category_name": "Thukpa"},
  {"id": 8, "category_name": "Keema Noodles"},
  {"id": 9, "category_name": "Soft Drinks"},
  {"id": 10, "category_name": "Hot Beverages"},
];

const List<Map<String, dynamic>> ITEMS = [
  {"id": 1, "category_id": 1, "item_name": "Milk Shake", "rate": 220},
  {"id": 2, "category_id": 1, "item_name": "Vanila Shake", "rate": 220},
  {"id": 3, "category_id": 1, "item_name": "Strawberry Shake", "rate": 220},
  {"id": 4, "category_id": 1, "item_name": "Chocolate Shake", "rate": 220},
  {"id": 5, "category_id": 1, "item_name": "Cream Shake", "rate": 220},

  {"id": 6, "category_id": 2, "item_name": "Strawberry Frappe", "rate": 280},
  {"id": 7, "category_id": 2, "item_name": "Chocolate Frappe", "rate": 280},
  {"id": 8, "category_id": 2, "item_name": "Oreo Frappe", "rate": 280},
  {"id": 9, "category_id": 2, "item_name": "Vanila Frappe", "rate": 280},

  {"id": 10, "category_id": 3, "item_name": "Plain Lassi", "rate": 120},
  {"id": 11, "category_id": 3, "item_name": "Sweet Lassi", "rate": 150},
  {"id": 12, "category_id": 3, "item_name": "Banana Lassi", "rate": 180},
  {"id": 13, "category_id": 3, "item_name": "Vanola Lassi", "rate": 200},
  {"id": 14, "category_id": 3, "item_name": "Chocolate Lassi", "rate": 200},
  {"id": 15, "category_id": 3, "item_name": "Strawberry Lassi", "rate": 200},
  {"id": 16, "category_id": 3, "item_name": "Blueberry Lassi", "rate": 200},

  {"id": 17, "category_id": 4, "item_name": "Buff H. Noodles", "rate": 250},
  {"id": 18, "category_id": 4, "item_name": "Chicken H. Noodles", "rate": 230},
  {"id": 19, "category_id": 4, "item_name": "Pork H. Noodles", "rate": 280},
  {"id": 20, "category_id": 4, "item_name": "Veg H. Noodles", "rate": 200},

  {"id": 21, "category_id": 5, "item_name": "Buff Fried Rice", "rate": 170},
  {"id": 22, "category_id": 5, "item_name": "Chicken Fried Rice", "rate": 180},
  {"id": 23, "category_id": 5, "item_name": "Pork Fried Rice", "rate": 190},
  {"id": 24, "category_id": 5, "item_name": "Mixed Fried Rice", "rate": 250},
  {"id": 25, "category_id": 5, "item_name": "Veg Fried Rice", "rate": 150},

  {"id": 26, "category_id": 6, "item_name": "Buff Chowmein", "rate": 150},
  {"id": 27, "category_id": 6, "item_name": "Chicken Chowmein", "rate": 170},
  {"id": 28, "category_id": 6, "item_name": "Pork Chowmein", "rate": 180},
  {"id": 29, "category_id": 6, "item_name": "Veg Chowmein", "rate": 130},
  {"id": 30, "category_id": 6, "item_name": "Mixed Chowmein", "rate": 250},

  {"id": 31, "category_id": 7, "item_name": "Buff Thukpa", "rate": 230},
  {"id": 32, "category_id": 7, "item_name": "Chicken Thukpa", "rate": 250},
  {"id": 33, "category_id": 7, "item_name": "Pork Thukpa", "rate": 280},
  {"id": 34, "category_id": 7, "item_name": "Veg Thukpa", "rate": 200},

  {"id": 35, "category_id": 8, "item_name": "Buff K.Noodles", "rate": 250},
  {"id": 36, "category_id": 8, "item_name": "Chicken K.Noodles", "rate": 230},
  {"id": 37, "category_id": 8, "item_name": "Veg K.Noodles", "rate": 200},

  {"id": 38, "category_id": 9, "item_name": "Coke/Fanta/Sprite", "rate": 75},
  {"id": 39, "category_id": 9, "item_name": "Red Bull (Blue)", "rate": 280},
  {"id": 40, "category_id": 9, "item_name": "Masala Coke", "rate": 150},
  {"id": 41, "category_id": 9, "item_name": "Red Bull (Red)", "rate": 170},
  {"id": 42, "category_id": 9, "item_name": "Badam Juice", "rate": 150},

  {"id": 43, "category_id": 10, "item_name": "Matka Chiya", "rate": 50},
  {"id": 44, "category_id": 10, "item_name": "Regular Tea", "rate": 35},
  {"id": 45, "category_id": 10, "item_name": "Black Tea", "rate": 25},
  {"id": 46, "category_id": 10, "item_name": "Lemon Tea", "rate": 30},
  {"id": 47, "category_id": 10, "item_name": "Ginger Tea (Black)", "rate": 30},
  {"id": 48, "category_id": 10, "item_name": "Hot Lemon", "rate": 100},
  {
    "id": 49,
    "category_id": 10,
    "item_name": "Hot Lemon With Honey",
    "rate": 130,
  },
  {
    "id": 50,
    "category_id": 10,
    "item_name": "Hot Lemon With Ginger Honey",
    "rate": 160,
  },
  {"id": 51, "category_id": 10, "item_name": "Green Tea", "rate": 150},
  {"id": 52, "category_id": 10, "item_name": "Milk Coffee", "rate": 125},
  {"id": 53, "category_id": 10, "item_name": "Black Coffee", "rate": 80},
];

// Helper functions to convert raw data to model objects
List<Category> getCategories() {
  return CATEGORIES.map((categoryMap) => Category(
    id: categoryMap['id'] as int,
    name: categoryMap['category_name'] as String,
  )).toList();
}

List<Item> getItems() {
  return ITEMS.map((itemMap) => Item(
    id: itemMap['id'] as int,
    categoryId: itemMap['category_id'] as int,
    itemName: itemMap['item_name'] as String,
    rate: (itemMap['rate'] as num).toDouble(),
  )).toList();
}

List<Item> getItemsByCategory(int categoryId) {
  return getItems().where((item) => item.categoryId == categoryId).toList();
}
