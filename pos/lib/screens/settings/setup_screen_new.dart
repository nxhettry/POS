import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../services/data_repository.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _categoryFormKey = GlobalKey<FormState>();

  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemRateController = TextEditingController();
  final _itemFormKey = GlobalKey<FormState>();

  final DataRepository _dataRepository = DataRepository();

  List<Category> _categories = [];
  List<Item> _items = [];
  Category? _selectedCategory;
  Category? _selectedCategoryForEdit;
  Item? _selectedItemForEdit;
  bool _isEditingCategory = false;
  bool _isEditingItem = false;
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _isLoadingCategories = false;
  bool _isLoadingItems = false;
  bool _isSavingCategory = false;
  bool _isSavingItem = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemRateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _dataRepository.fetchCategories();
      final items = await _dataRepository.fetchItems();

      setState(() {
        _categories = categories;
        _items = items;
        if (_categories.isNotEmpty && _selectedCategory == null) {
          _selectedCategory = _categories.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorMessage('Error loading data: ${e.toString()}');
      }
    }
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await _dataRepository.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        _showErrorMessage('Error loading categories: ${e.toString()}');
      }
    }
  }

  Future<void> _refreshItems() async {
    setState(() {
      _isLoadingItems = true;
    });

    try {
      final items = await _dataRepository.fetchItems();
      setState(() {
        _items = items;
        _isLoadingItems = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingItems = false;
      });
      if (mounted) {
        _showErrorMessage('Error loading items: ${e.toString()}');
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

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Categories', Icons.category, 0),
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

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
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
        Expanded(
          flex: 2,
          child: _buildSection(
            title: 'Categories',
            icon: Icons.category,
            child: Column(
              children: [
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

                Expanded(
                  child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
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
        Expanded(
          flex: 2,
          child: _buildSection(
            title: 'Menu Items',
            icon: Icons.restaurant_menu,
            child: Column(
              children: [
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
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ..._categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _categories.isEmpty
                          ? null
                          : () => _showItemDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
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
                if (_categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please create at least one category before adding items',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                Expanded(
                  child: _isLoadingItems
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
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

        Expanded(
          flex: 1,
          child: _buildSection(
            title: _isEditingItem ? 'Edit Item' : 'Item Details',
            icon: Icons.info,
            child: _isEditingItem ? _buildItemForm() : _buildItemDetails(),
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
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
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
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final itemCount = _items
        .where((item) => item.categoryId == category.id)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.isActive
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category,
              color: category.isActive ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: category.isActive ? Colors.black87 : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$itemCount items'),
              if (category.description != null && category.description!.isNotEmpty)
                Text(
                  category.description!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (!category.isActive)
                const Text(
                  'Inactive',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () => _viewCategory(category),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editCategory(category),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategory(category),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    final category = _categories.firstWhere(
      (cat) => cat.id == item.categoryId,
      orElse: () => Category(name: 'Unknown'),
    );

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
                    child: Image.network(
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: item.isAvailable ? Colors.black87 : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name),
              if (item.description != null && item.description!.isNotEmpty)
                Text(
                  item.description!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                'Rs. ${item.rate.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!item.isAvailable)
                const Text(
                  'Unavailable',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () => _viewItem(item),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editItem(item),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(item),
                tooltip: 'Delete',
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
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Description (Optional)',
            controller: _categoryDescriptionController,
            hint: 'Enter category description',
            icon: Icons.description,
            maxLines: 3,
          ),
          const Spacer(),
          if (_isSavingCategory)
            const Center(child: CircularProgressIndicator())
          else
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
                    child: Text(_selectedCategoryForEdit == null ? 'Create' : 'Update'),
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
          _buildFormField(
            label: 'Description (Optional)',
            controller: _itemDescriptionController,
            hint: 'Enter item description',
            icon: Icons.description,
            maxLines: 2,
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
            items: _categories.where((cat) => cat.isActive).map((category) {
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
          if (_isSavingItem)
            const Center(child: CircularProgressIndicator())
          else
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
                    child: Text(_selectedItemForEdit == null ? 'Create' : 'Update'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetails() {
    if (_selectedCategoryForEdit == null) {
      return const Center(
        child: Text(
          'Select a category to view details',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final categoryItems = _items
        .where((item) => item.categoryId == _selectedCategoryForEdit!.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategoryForEdit!.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedCategoryForEdit!.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _selectedCategoryForEdit!.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: _selectedCategoryForEdit!.isActive ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedCategoryForEdit!.description != null && 
            _selectedCategoryForEdit!.description!.isNotEmpty) ...[
          Text(
            _selectedCategoryForEdit!.description!,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          'Items: ${categoryItems.length}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        if (_selectedCategoryForEdit!.createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Created: ${_selectedCategoryForEdit!.createdAt.toString().split('.')[0]}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        if (categoryItems.isNotEmpty) ...[
          const Text(
            'Items in this category:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: categoryItems.length,
              itemBuilder: (context, index) {
                final item = categoryItems[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.restaurant_menu,
                    color: item.isAvailable ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  title: Text(
                    item.itemName,
                    style: TextStyle(
                      color: item.isAvailable ? Colors.black87 : Colors.grey,
                    ),
                  ),
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
      orElse: () => Category(name: 'Unknown'),
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
              child: Image.network(
                _selectedItemForEdit!.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    size: 50,
                    color: Colors.grey[600],
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedItemForEdit!.itemName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedItemForEdit!.isAvailable
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _selectedItemForEdit!.isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(
                  color: _selectedItemForEdit!.isAvailable ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedItemForEdit!.description != null && 
            _selectedItemForEdit!.description!.isNotEmpty) ...[
          Text(
            _selectedItemForEdit!.description!,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          'Category: ${category.name}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
        if (_selectedItemForEdit!.createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Created: ${_selectedItemForEdit!.createdAt.toString().split('.')[0]}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
    return _items
        .where((item) => item.categoryId == _selectedCategory!.id)
        .toList();
  }

  void _showCategoryDialog() {
    _categoryNameController.clear();
    _categoryDescriptionController.clear();
    _selectedCategoryForEdit = null;
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
                labelText: 'Category Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
    _itemDescriptionController.clear();
    _itemRateController.clear();
    _selectedItemForEdit = null;
    _isEditingItem = false;
    
    // Set default category if none selected
    if (_selectedCategory == null && _categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
    
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
                labelText: 'Item Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.where((cat) => cat.isActive).map((category) {
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
                labelText: 'Price (Rs.) *',
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

  Future<void> _addCategory() async {
    try {
      final newCategory = await _dataRepository.createCategory(
        _categoryNameController.text.trim(),
        description: _categoryDescriptionController.text.trim().isEmpty 
            ? null 
            : _categoryDescriptionController.text.trim(),
      );

      setState(() {
        _categories.add(newCategory);
        if (_selectedCategory == null) {
          _selectedCategory = newCategory;
        }
      });
      
      _showSuccessMessage('Category added successfully!');
    } catch (e) {
      _showErrorMessage('Error adding category: ${e.toString()}');
    }
  }

  void _editCategory(Category category) {
    _categoryNameController.text = category.name;
    _categoryDescriptionController.text = category.description ?? '';
    _selectedCategoryForEdit = category;
    setState(() {
      _isEditingCategory = true;
    });
  }

  void _viewCategory(Category category) {
    setState(() {
      _selectedCategoryForEdit = category;
      _isEditingCategory = false;
    });
  }

  Future<void> _addItem() async {
    try {
      final newItem = await _dataRepository.createItem(
        _selectedCategory!.id!,
        _itemNameController.text.trim(),
        double.parse(_itemRateController.text),
        description: _itemDescriptionController.text.trim().isEmpty 
            ? null 
            : _itemDescriptionController.text.trim(),
      );

      setState(() {
        _items.add(newItem);
      });
      
      _showSuccessMessage('Item added successfully!');
    } catch (e) {
      _showErrorMessage('Error adding item: ${e.toString()}');
    }
  }

  void _editItem(Item item) {
    _itemNameController.text = item.itemName;
    _itemDescriptionController.text = item.description ?? '';
    _itemRateController.text = item.rate.toString();
    _selectedCategory = _categories.firstWhere(
      (cat) => cat.id == item.categoryId,
    );
    _selectedItemForEdit = item;
    setState(() {
      _isEditingItem = true;
    });
  }

  void _viewItem(Item item) {
    setState(() {
      _selectedItemForEdit = item;
      _isEditingItem = false;
    });
  }

  Future<void> _deleteCategory(Category category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This will also delete all items in this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _dataRepository.deleteCategory(category.id!);

        setState(() {
          _categories.removeWhere((cat) => cat.id == category.id);
          _items.removeWhere((item) => item.categoryId == category.id);

          if (_selectedCategory?.id == category.id) {
            _selectedCategory = _categories.isNotEmpty
                ? _categories.first
                : null;
          }
          
          if (_selectedCategoryForEdit?.id == category.id) {
            _selectedCategoryForEdit = null;
          }
        });
        
        _showSuccessMessage('Category deleted successfully!');
      } catch (e) {
        _showErrorMessage('Error deleting category: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteItem(Item item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _dataRepository.deleteItem(item.id!);

        setState(() {
          _items.removeWhere((i) => i.id == item.id);
          if (_selectedItemForEdit?.id == item.id) {
            _selectedItemForEdit = null;
          }
        });
        
        _showSuccessMessage('Item deleted successfully!');
      } catch (e) {
        _showErrorMessage('Error deleting item: ${e.toString()}');
      }
    }
  }

  Future<void> _saveCategoryChanges() async {
    if (!_categoryFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingCategory = true;
    });

    try {
      Category updatedCategory;
      
      if (_selectedCategoryForEdit == null) {
        // Create new category
        updatedCategory = await _dataRepository.createCategory(
          _categoryNameController.text.trim(),
          description: _categoryDescriptionController.text.trim().isEmpty 
              ? null 
              : _categoryDescriptionController.text.trim(),
        );
        
        setState(() {
          _categories.add(updatedCategory);
        });
      } else {
        // Update existing category
        updatedCategory = await _dataRepository.updateCategory(
          _selectedCategoryForEdit!.id!,
          _categoryNameController.text.trim(),
          description: _categoryDescriptionController.text.trim().isEmpty 
              ? null 
              : _categoryDescriptionController.text.trim(),
        );

        final index = _categories.indexWhere(
          (cat) => cat.id == _selectedCategoryForEdit!.id,
        );
        if (index != -1) {
          setState(() {
            _categories[index] = updatedCategory;
          });
        }
      }

      setState(() {
        _selectedCategoryForEdit = updatedCategory;
        _isEditingCategory = false;
        _isSavingCategory = false;
      });
      
      _showSuccessMessage(_selectedCategoryForEdit == null 
          ? 'Category created successfully!'
          : 'Category updated successfully!');
    } catch (e) {
      setState(() {
        _isSavingCategory = false;
      });
      _showErrorMessage('Error saving category: ${e.toString()}');
    }
  }

  Future<void> _saveItemChanges() async {
    if (!_itemFormKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    setState(() {
      _isSavingItem = true;
    });

    try {
      Item updatedItem;
      
      if (_selectedItemForEdit == null) {
        // Create new item
        updatedItem = await _dataRepository.createItem(
          _selectedCategory!.id!,
          _itemNameController.text.trim(),
          double.parse(_itemRateController.text),
          description: _itemDescriptionController.text.trim().isEmpty 
              ? null 
              : _itemDescriptionController.text.trim(),
        );
        
        setState(() {
          _items.add(updatedItem);
        });
      } else {
        // Update existing item
        updatedItem = await _dataRepository.updateItem(
          _selectedItemForEdit!.id!,
          _selectedCategory!.id!,
          _itemNameController.text.trim(),
          double.parse(_itemRateController.text),
          description: _itemDescriptionController.text.trim().isEmpty 
              ? null 
              : _itemDescriptionController.text.trim(),
        );

        final index = _items.indexWhere(
          (item) => item.id == _selectedItemForEdit!.id,
        );
        if (index != -1) {
          setState(() {
            _items[index] = updatedItem;
          });
        }
      }

      setState(() {
        _selectedItemForEdit = updatedItem;
        _isEditingItem = false;
        _isSavingItem = false;
      });
      
      _showSuccessMessage(_selectedItemForEdit == null 
          ? 'Item created successfully!'
          : 'Item updated successfully!');
    } catch (e) {
      setState(() {
        _isSavingItem = false;
      });
      _showErrorMessage('Error saving item: ${e.toString()}');
    }
  }

  void _cancelCategoryEdit() {
    setState(() {
      _isEditingCategory = false;
      _selectedCategoryForEdit = null;
      _categoryNameController.clear();
      _categoryDescriptionController.clear();
    });
  }

  void _cancelItemEdit() {
    setState(() {
      _isEditingItem = false;
      _selectedItemForEdit = null;
      _itemNameController.clear();
      _itemDescriptionController.clear();
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
