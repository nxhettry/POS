import 'package:flutter/material.dart';
import "../../data/cart_manager.dart";
import "../../services/database_service.dart";
import "../../models/models.dart";

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  int selectedCategory = 0;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Category>>(
              future: _databaseService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                final categories = snapshot.data ?? [];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "All" category
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: selectedCategory == 0
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'All',
                                    style: TextStyle(
                                      color: selectedCategory == 0
                                          ? Colors.red
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          final category = categories[index - 1];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category.id!;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: selectedCategory == category.id!
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: selectedCategory == category.id!
                                        ? Colors.red
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Items(
                selectedCategory: selectedCategory,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Items extends StatelessWidget {
  final int selectedCategory;
  final String searchQuery;

  const Items({
    super.key,
    required this.selectedCategory,
    required this.searchQuery,
  });

  void _showItemPopup(BuildContext context, Item item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ItemPopup(item: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return FutureBuilder<List<Item>>(
      future: databaseService.getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading items: ${snapshot.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        List<Item> allItems = snapshot.data ?? [];
        List<Item> filteredItems = allItems;

        // Filter by category
        if (selectedCategory != 0) {
          filteredItems = filteredItems
              .where((item) => item.categoryId == selectedCategory)
              .toList();
        }

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          filteredItems = filteredItems
              .where(
                (item) => item.itemName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
        }

        if (filteredItems.isEmpty) {
          String message;
          if (searchQuery.isNotEmpty) {
            message = 'No items found for "$searchQuery"';
          } else if (selectedCategory != 0) {
            message = 'No items found for this category';
          } else {
            message = 'No items available';
          }

          return Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];

            return GestureDetector(
              onTap: () => _showItemPopup(context, item),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: item.image != null
                            ? Image.asset(item.image!, fit: BoxFit.contain)
                            : Icon(
                                Icons.fastfood,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Roboto",
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${item.rate.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ItemPopup extends StatefulWidget {
  final Item item;

  const ItemPopup({super.key, required this.item});

  @override
  State<ItemPopup> createState() => _ItemPopupState();
}

class _ItemPopupState extends State<ItemPopup> {
  int quantity = 1;
  final TextEditingController quantityController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    quantityController.text = quantity.toString();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        quantity = newQuantity;
        quantityController.text = quantity.toString();
      });
    }
  }

  Future<String> _getCategoryName(int categoryId) async {
    try {
      final categories = await _databaseService.getCategories();
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => Category(name: 'Unknown'),
      );
      return category.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            // Item Image
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.item.image != null
                    ? Image.asset(widget.item.image!, fit: BoxFit.cover)
                    : Icon(
                        Icons.fastfood,
                        size: 100,
                        color: Colors.grey[400],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Item Name
            Text(
              widget.item.itemName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Category Badge
            FutureBuilder<String>(
              future: _getCategoryName(widget.item.categoryId),
              builder: (context, snapshot) {
                final categoryName = snapshot.data ?? 'Loading...';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Price
            Text(
              'Rs. ${widget.item.rate.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // Quantity Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    onPressed: () => _updateQuantity(quantity - 1),
                    icon: const Icon(Icons.remove, color: Colors.grey),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Quantity Input
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      final newQuantity = int.tryParse(value) ?? 1;
                      if (newQuantity > 0) {
                        setState(() {
                          quantity = newQuantity;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // Plus button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    onPressed: () => _updateQuantity(quantity + 1),
                    icon: const Icon(Icons.add, color: Colors.grey),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Convert Item to Map format for CartManager compatibility
                  Map<String, dynamic> itemMap = {
                    'id': widget.item.id,
                    'category_id': widget.item.categoryId,
                    'item_name': widget.item.itemName,
                    'rate': widget.item.rate,
                    'image': widget.item.image,
                  };
                  
                  // Add item to cart using CartManager
                  CartManager().addItem(itemMap, quantity);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${widget.item.itemName} (x$quantity) to cart',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart - Rs. ${(widget.item.rate * quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
