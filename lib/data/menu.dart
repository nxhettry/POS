import "../models/models.dart";

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
  {
    "id": 1,
    "category_id": 1,
    "item_name": "Milk Shake",
    "rate": 220,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 2,
    "category_id": 1,
    "item_name": "Vanila Shake",
    "rate": 220,
    "image": "assets/images/burger.png",
  },
  {
    "id": 3,
    "category_id": 1,
    "item_name": "Strawberry Shake",
    "rate": 220,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 4,
    "category_id": 1,
    "item_name": "Chocolate Shake",
    "rate": 220,
    "image": "assets/images/americano.png",
  },
  {
    "id": 5,
    "category_id": 1,
    "item_name": "Cream Shake",
    "rate": 220,
    "image": "assets/images/milkshake.jpg",
  },

  {
    "id": 6,
    "category_id": 2,
    "item_name": "Strawberry Frappe",
    "rate": 280,
    "image": "assets/images/burger.png",
  },
  {
    "id": 7,
    "category_id": 2,
    "item_name": "Chocolate Frappe",
    "rate": 280,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 8,
    "category_id": 2,
    "item_name": "Oreo Frappe",
    "rate": 280,
    "image": "assets/images/americano.png",
  },
  {
    "id": 9,
    "category_id": 2,
    "item_name": "Vanila Frappe",
    "rate": 280,
    "image": "assets/images/milkshake.jpg",
  },

  {
    "id": 10,
    "category_id": 3,
    "item_name": "Plain Lassi",
    "rate": 120,
    "image": "assets/images/burger.png",
  },
  {
    "id": 11,
    "category_id": 3,
    "item_name": "Sweet Lassi",
    "rate": 150,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 12,
    "category_id": 3,
    "item_name": "Banana Lassi",
    "rate": 180,
    "image": "assets/images/americano.png",
  },
  {
    "id": 13,
    "category_id": 3,
    "item_name": "Vanola Lassi",
    "rate": 200,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 14,
    "category_id": 3,
    "item_name": "Chocolate Lassi",
    "rate": 200,
    "image": "assets/images/burger.png",
  },
  {
    "id": 15,
    "category_id": 3,
    "item_name": "Strawberry Lassi",
    "rate": 200,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 16,
    "category_id": 3,
    "item_name": "Blueberry Lassi",
    "rate": 200,
    "image": "assets/images/americano.png",
  },

  {
    "id": 17,
    "category_id": 4,
    "item_name": "Buff H. Noodles",
    "rate": 250,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 18,
    "category_id": 4,
    "item_name": "Chicken H. Noodles",
    "rate": 230,
    "image": "assets/images/burger.png",
  },
  {
    "id": 19,
    "category_id": 4,
    "item_name": "Pork H. Noodles",
    "rate": 280,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 20,
    "category_id": 4,
    "item_name": "Veg H. Noodles",
    "rate": 200,
    "image": "assets/images/americano.png",
  },

  {
    "id": 21,
    "category_id": 5,
    "item_name": "Buff Fried Rice",
    "rate": 170,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 22,
    "category_id": 5,
    "item_name": "Chicken Fried Rice",
    "rate": 180,
    "image": "assets/images/burger.png",
  },
  {
    "id": 23,
    "category_id": 5,
    "item_name": "Pork Fried Rice",
    "rate": 190,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 24,
    "category_id": 5,
    "item_name": "Mixed Fried Rice",
    "rate": 250,
    "image": "assets/images/americano.png",
  },
  {
    "id": 25,
    "category_id": 5,
    "item_name": "Veg Fried Rice",
    "rate": 150,
    "image": "assets/images/milkshake.jpg",
  },

  {
    "id": 26,
    "category_id": 6,
    "item_name": "Buff Chowmein",
    "rate": 150,
    "image": "assets/images/burger.png",
  },
  {
    "id": 27,
    "category_id": 6,
    "item_name": "Chicken Chowmein",
    "rate": 170,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 28,
    "category_id": 6,
    "item_name": "Pork Chowmein",
    "rate": 180,
    "image": "assets/images/americano.png",
  },
  {
    "id": 29,
    "category_id": 6,
    "item_name": "Veg Chowmein",
    "rate": 130,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 30,
    "category_id": 6,
    "item_name": "Mixed Chowmein",
    "rate": 250,
    "image": "assets/images/burger.png",
  },

  {
    "id": 31,
    "category_id": 7,
    "item_name": "Buff Thukpa",
    "rate": 230,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 32,
    "category_id": 7,
    "item_name": "Chicken Thukpa",
    "rate": 250,
    "image": "assets/images/americano.png",
  },
  {
    "id": 33,
    "category_id": 7,
    "item_name": "Pork Thukpa",
    "rate": 280,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 34,
    "category_id": 7,
    "item_name": "Veg Thukpa",
    "rate": 200,
    "image": "assets/images/burger.png",
  },

  {
    "id": 35,
    "category_id": 8,
    "item_name": "Buff K.Noodles",
    "rate": 250,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 36,
    "category_id": 8,
    "item_name": "Chicken K.Noodles",
    "rate": 230,
    "image": "assets/images/americano.png",
  },
  {
    "id": 37,
    "category_id": 8,
    "item_name": "Veg K.Noodles",
    "rate": 200,
    "image": "assets/images/milkshake.jpg",
  },

  {
    "id": 38,
    "category_id": 9,
    "item_name": "Coke/Fanta/Sprite",
    "rate": 75,
    "image": "assets/images/burger.png",
  },
  {
    "id": 39,
    "category_id": 9,
    "item_name": "Red Bull (Blue)",
    "rate": 280,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 40,
    "category_id": 9,
    "item_name": "Masala Coke",
    "rate": 150,
    "image": "assets/images/americano.png",
  },
  {
    "id": 41,
    "category_id": 9,
    "item_name": "Red Bull (Red)",
    "rate": 170,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 42,
    "category_id": 9,
    "item_name": "Badam Juice",
    "rate": 150,
    "image": "assets/images/burger.png",
  },

  {
    "id": 43,
    "category_id": 10,
    "item_name": "Matka Chiya",
    "rate": 50,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 44,
    "category_id": 10,
    "item_name": "Regular Tea",
    "rate": 35,
    "image": "assets/images/americano.png",
  },
  {
    "id": 45,
    "category_id": 10,
    "item_name": "Black Tea",
    "rate": 25,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 46,
    "category_id": 10,
    "item_name": "Lemon Tea",
    "rate": 30,
    "image": "assets/images/burger.png",
  },
  {
    "id": 47,
    "category_id": 10,
    "item_name": "Ginger Tea (Black)",
    "rate": 30,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 48,
    "category_id": 10,
    "item_name": "Hot Lemon",
    "rate": 100,
    "image": "assets/images/americano.png",
  },
  {
    "id": 49,
    "category_id": 10,
    "item_name": "Hot Lemon With Honey",
    "rate": 130,
    "image": "assets/images/milkshake.jpg",
  },
  {
    "id": 50,
    "category_id": 10,
    "item_name": "Hot Lemon With Ginger Honey",
    "rate": 160,
    "image": "assets/images/burger.png",
  },
  {
    "id": 51,
    "category_id": 10,
    "item_name": "Green Tea",
    "rate": 150,
    "image": "assets/images/noodles.png",
  },
  {
    "id": 52,
    "category_id": 10,
    "item_name": "Milk Coffee",
    "rate": 125,
    "image": "assets/images/americano.png",
  },
  {
    "id": 53,
    "category_id": 10,
    "item_name": "Black Coffee",
    "rate": 80,
    "image": "assets/images/milkshake.jpg",
  },
];

// Helper functions to convert raw data to model objects
List<Category> getCategories() {
  return CATEGORIES
      .map(
        (categoryMap) => Category(
          name: categoryMap['category_name'] as String,
        ),
      )
      .toList();
}

List<Item> getItems() {
  return ITEMS
      .map(
        (itemMap) => Item(
          categoryId: itemMap['category_id'] as int,
          itemName: itemMap['item_name'] as String,
          rate: (itemMap['rate'] as num).toDouble(),
        ),
      )
      .toList();
}

List<Item> getItemsByCategory(int categoryId) {
  return getItems().where((item) => item.categoryId == categoryId).toList();
}
