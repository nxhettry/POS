import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../services/database_helper.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Controllers for category form
  final _categoryNameController = TextEditingController();
  final _categoryFormKey = GlobalKey<FormState>();

  // Controllers for item form
  final _itemNameController = TextEditingController();
  final _itemRateController = TextEditingController();
  final _itemFormKey = GlobalKey<FormState>();

  // State variables
  List<Category> _categories = [];
  List<Item> _items = [];
  Category? _selectedCategory;
  Item? _selectedItemForEdit;
  bool _isEditingCategory = false;
  bool _isEditingItem = false;
  int _selectedTab = 0; // 0 for categories, 1 for items

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _itemNameController.dispose();
    _itemRateController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Load categories from database
      _categories = await dbHelper.getCategories();
      
      // Load items from database
      _items = await dbHelper.getItems();

      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
      setState(() {});
    } catch (e) {
      print('Error loading data: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Menu Setup',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your restaurant categories and menu items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Categories',
                    Icons.category,
                    0,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Menu Items',
                    Icons.restaurant_menu,
                    1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: _selectedTab == 0 ? _buildCategoriesTab() : _buildItemsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Row(
      children: [
        // Categories List
        Expanded(
          flex: 2,
          child: _buildSection(
            title: 'Categories',
            icon: Icons.category,
            child: Column(
              children: [
                // Add Category Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Categories List
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Category Details/Form
        Expanded(
          flex: 1,
          child: _buildSection(
            title: _isEditingCategory ? 'Edit Category' : 'Category Details',
            icon: Icons.info,
            child: _isEditingCategory
                ? _buildCategoryForm()
                : _buildCategoryDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTab() {
    return Row(
      children: [
        // Items List
        Expanded(
          flex: 2,
          child: _buildSection(
            title: 'Menu Items',
            icon: Icons.restaurant_menu,
            child: Column(
              children: [
                // Category Filter and Add Item Button
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showItemDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Items List
                Expanded(
                  child: ListView.builder(
                    itemCount: _getFilteredItems().length,
                    itemBuilder: (context, index) {
                      final item = _getFilteredItems()[index];
                      return _buildItemCard(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Item Details/Form
        Expanded(
          flex: 1,
          child: _buildSection(
            title: _isEditingItem ? 'Edit Item' : 'Item Details',
            icon: Icons.info,
            child: _isEditingItem
                ? _buildItemForm()
                : _buildItemDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final itemCount = _items.where((item) => item.categoryId == category.id).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.category, color: Colors.red, size: 20),
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('$itemCount items'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editCategory(category),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategory(category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    final category = _categories.firstWhere((cat) => cat.id == item.categoryId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.restaurant, color: Colors.grey[600]);
                      },
                    ),
                  )
                : Icon(Icons.restaurant, color: Colors.grey[600]),
          ),
          title: Text(
            item.itemName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name),
              Text(
                'Rs. ${item.rate.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editItem(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryForm() {
    return Form(
      key: _categoryFormKey,
      child: Column(
        children: [
          _buildFormField(
            label: 'Category Name',
            controller: _categoryNameController,
            hint: 'Enter category name',
            icon: Icons.category,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelCategoryEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveCategoryChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemForm() {
    return Form(
      key: _itemFormKey,
      child: Column(
        children: [
          _buildFormField(
            label: 'Item Name',
            controller: _itemNameController,
            hint: 'Enter item name',
            icon: Icons.restaurant_menu,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Price (Rs.)',
            controller: _itemRateController,
            hint: 'Enter price',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter valid price';
              }
              return null;
            },
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelItemEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveItemChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetails() {
    if (_selectedCategory == null) {
      return const Center(
        child: Text(
          'Select a category to view details',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final categoryItems = _items.where((item) => item.categoryId == _selectedCategory!.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedCategory!.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Items: ${categoryItems.length}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        if (categoryItems.isNotEmpty) ...[
          const Text(
            'Items in this category:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: categoryItems.length,
              itemBuilder: (context, index) {
                final item = categoryItems[index];
                return ListTile(
                  dense: true,
                  title: Text(item.itemName),
                  trailing: Text(
                    'Rs. ${item.rate.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemDetails() {
    if (_selectedItemForEdit == null) {
      return const Center(
        child: Text(
          'Select an item to view details',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final category = _categories.firstWhere(
      (cat) => cat.id == _selectedItemForEdit!.categoryId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedItemForEdit!.image != null)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _selectedItemForEdit!.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.restaurant, size: 50, color: Colors.grey[600]);
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          _selectedItemForEdit!.itemName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Category: ${category.name}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Price: Rs. ${_selectedItemForEdit!.rate.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  List<Item> _getFilteredItems() {
    if (_selectedCategory == null) {
      return _items;
    }
    return _items.where((item) => item.categoryId == _selectedCategory!.id).toList();
  }

  void _showCategoryDialog() {
    _categoryNameController.clear();
    _isEditingCategory = false;
    setState(() {});
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryNameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_categoryNameController.text.isNotEmpty) {
                _addCategory();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showItemDialog() {
    _itemNameController.clear();
    _itemRateController.clear();
    _isEditingItem = false;
    setState(() {});
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemRateController,
              decoration: const InputDecoration(
                labelText: 'Price (Rs.)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_itemNameController.text.isNotEmpty &&
                  _itemRateController.text.isNotEmpty &&
                  _selectedCategory != null) {
                _addItem();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCategory() async {
    try {
      final dbHelper = DatabaseHelper();
      final newCategory = Category(
        name: _categoryNameController.text,
      );
      
      final id = await dbHelper.insertCategory(newCategory);
      final categoryWithId = Category(id: id, name: newCategory.name);
      
      setState(() {
        _categories.add(categoryWithId);
      });
      _showSuccessMessage('Category added successfully!');
    } catch (e) {
      print('Error adding category: $e');
      _showErrorMessage('Error adding category: $e');
    }
  }

  void _editCategory(Category category) {
    _categoryNameController.text = category.name;
    _selectedCategory = category;
    setState(() {
      _isEditingCategory = true;
    });
  }

  void _addItem() async {
    try {
      final dbHelper = DatabaseHelper();
      final newItem = Item(
        categoryId: _selectedCategory!.id!,
        itemName: _itemNameController.text,
        rate: double.parse(_itemRateController.text),
      );
      
      final id = await dbHelper.insertItem(newItem);
      final itemWithId = Item(
        id: id,
        categoryId: newItem.categoryId,
        itemName: newItem.itemName,
        rate: newItem.rate,
        image: newItem.image,
      );
      
      setState(() {
        _items.add(itemWithId);
      });
      _showSuccessMessage('Item added successfully!');
    } catch (e) {
      print('Error adding item: $e');
      _showErrorMessage('Error adding item: $e');
    }
  }

  void _editItem(Item item) {
    _itemNameController.text = item.itemName;
    _itemRateController.text = item.rate.toString();
    _selectedCategory = _categories.firstWhere((cat) => cat.id == item.categoryId);
    _selectedItemForEdit = item;
    setState(() {
      _isEditingItem = true;
    });
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This will also delete all items in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteCategory(category.id!);
                
                setState(() {
                  _categories.removeWhere((cat) => cat.id == category.id);
                  _items.removeWhere((item) => item.categoryId == category.id);
                  // Reset selected category if it was deleted
                  if (_selectedCategory?.id == category.id) {
                    _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
                  }
                });
                Navigator.pop(context);
                _showSuccessMessage('Category deleted successfully!');
              } catch (e) {
                Navigator.pop(context);
                _showErrorMessage('Error deleting category: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteItem(item.id!);
                
                setState(() {
                  _items.removeWhere((i) => i.id == item.id);
                });
                Navigator.pop(context);
                _showSuccessMessage('Item deleted successfully!');
              } catch (e) {
                Navigator.pop(context);
                _showErrorMessage('Error deleting item: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveCategoryChanges() async {
    if (_categoryFormKey.currentState!.validate()) {
      try {
        final dbHelper = DatabaseHelper();
        final updatedCategory = Category(
          id: _selectedCategory!.id,
          name: _categoryNameController.text,
        );
        
        await dbHelper.updateCategory(updatedCategory);
        
        final index = _categories.indexWhere((cat) => cat.id == _selectedCategory!.id);
        if (index != -1) {
          setState(() {
            _categories[index] = updatedCategory;
            _selectedCategory = updatedCategory;
            _isEditingCategory = false;
          });
          _showSuccessMessage('Category updated successfully!');
        }
      } catch (e) {
        print('Error updating category: $e');
        _showErrorMessage('Error updating category: $e');
      }
    }
  }

  void _saveItemChanges() async {
    if (_itemFormKey.currentState!.validate()) {
      try {
        final dbHelper = DatabaseHelper();
        final updatedItem = Item(
          id: _selectedItemForEdit!.id,
          categoryId: _selectedCategory!.id!,
          itemName: _itemNameController.text,
          rate: double.parse(_itemRateController.text),
          image: _selectedItemForEdit!.image,
        );
        
        await dbHelper.updateItem(updatedItem);
        
        final index = _items.indexWhere((item) => item.id == _selectedItemForEdit!.id);
        if (index != -1) {
          setState(() {
            _items[index] = updatedItem;
            _selectedItemForEdit = updatedItem;
            _isEditingItem = false;
          });
          _showSuccessMessage('Item updated successfully!');
        }
      } catch (e) {
        print('Error updating item: $e');
        _showErrorMessage('Error updating item: $e');
      }
    }
  }

  void _cancelCategoryEdit() {
    setState(() {
      _isEditingCategory = false;
      _categoryNameController.clear();
    });
  }

  void _cancelItemEdit() {
    setState(() {
      _isEditingItem = false;
      _selectedItemForEdit = null;
      _itemNameController.clear();
      _itemRateController.clear();
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
