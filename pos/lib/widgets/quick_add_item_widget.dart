import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart' as pos_models;
import '../services/data_repository.dart';
import '../services/table_cart_manager.dart';
import '../utils/responsive.dart';

class QuickAddItemWidget extends StatefulWidget {
  final Function()? onItemAdded;
  
  const QuickAddItemWidget({
    super.key,
    this.onItemAdded,
  });

  @override
  State<QuickAddItemWidget> createState() => _QuickAddItemWidgetState();
}

class _QuickAddItemWidgetState extends State<QuickAddItemWidget> {
  final DataRepository _dataRepository = DataRepository();
  final TableCartManager _cartManager = TableCartManager();
  final TextEditingController _searchController = TextEditingController();
  
  List<pos_models.Item> _allItems = [];
  List<pos_models.Item> _filteredItems = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _dataRepository.fetchItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item.itemName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addItemToCart(pos_models.Item item) async {
    final itemMap = {
      'id': item.id,
      'category_id': item.categoryId,
      'item_name': item.itemName,
      'rate': item.rate,
      'image': item.image,
      'description': item.description,
    };

    await _cartManager.addItem(itemMap, 1);
    widget.onItemAdded?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.itemName} added to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      builder: (context) => QuickAddDialog(
        onItemAdded: () {
          widget.onItemAdded?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, base: 4),
        horizontal: ResponsiveUtils.getSpacing(context, base: 2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          leading: Container(
            width: ResponsiveUtils.isSmallDesktop(context) ? 40 : 50,
            height: ResponsiveUtils.isSmallDesktop(context) ? 40 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.add_shopping_cart,
              color: Colors.green,
              size: ResponsiveUtils.isSmallDesktop(context) ? 20 : 24,
            ),
          ),
          title: Text(
            "Add Items",
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          subtitle: Text(
            "Tap to add more items to cart",
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 12),
              color: Colors.grey[600],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _showQuickAddDialog,
                icon: Icon(Icons.search, color: Colors.blue),
                tooltip: "Quick Search & Add",
                constraints: BoxConstraints(
                  minWidth: ResponsiveUtils.isSmallDesktop(context) ? 32 : 36,
                  minHeight: ResponsiveUtils.isSmallDesktop(context) ? 32 : 36,
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey[600],
              ),
            ],
          ),
          children: [
            Padding(
              padding: ResponsiveUtils.getPadding(context, base: 16),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search items to add...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: ResponsiveUtils.getPadding(context, base: 8),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                    ),
                    onChanged: _filterItems,
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getSpacing(context, base: 12)),
                  
                  // Items List
                  if (_isLoading)
                    Container(
                      height: 100,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_filteredItems.isEmpty)
                    Container(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, color: Colors.grey, size: 32),
                            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 8)),
                            Text(
                              _searchController.text.isEmpty 
                                  ? "No items available" 
                                  : "No items found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      child: ListView.separated(
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey[200],
                              ),
                              child: item.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        item.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.fastfood, size: 16);
                                        },
                                      ),
                                    )
                                  : Icon(Icons.fastfood, size: 16),
                            ),
                            title: Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Rs. ${item.rate.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 12),
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () => _addItemToCart(item),
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              tooltip: "Add to cart",
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAddDialog extends StatefulWidget {
  final Function()? onItemAdded;
  
  const QuickAddDialog({
    super.key,
    this.onItemAdded,
  });

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  final DataRepository _dataRepository = DataRepository();
  final TableCartManager _cartManager = TableCartManager();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  
  List<pos_models.Item> _allItems = [];
  List<pos_models.Item> _filteredItems = [];
  pos_models.Item? _selectedItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _dataRepository.fetchItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item.itemName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addSelectedItem() async {
    if (_selectedItem == null) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final itemMap = {
      'id': _selectedItem!.id,
      'category_id': _selectedItem!.categoryId,
      'item_name': _selectedItem!.itemName,
      'rate': _selectedItem!.rate,
      'image': _selectedItem!.image,
      'description': _selectedItem!.description,
    };

    await _cartManager.addItem(itemMap, quantity);
    widget.onItemAdded?.call();
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedItem!.itemName} (x$quantity) added to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: ResponsiveUtils.isSmallDesktop(context) ? 400 : 500,
        height: ResponsiveUtils.isSmallDesktop(context) ? 500 : 600,
        padding: ResponsiveUtils.getPadding(context, base: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.add_shopping_cart, color: Colors.green, size: 24),
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                Text(
                  "Quick Add Items",
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
            
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _filterItems,
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
            
            // Items List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, color: Colors.grey, size: 48),
                              SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
                              Text(
                                _searchController.text.isEmpty 
                                    ? "No items available" 
                                    : "No items found",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredItems.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = _selectedItem?.id == item.id;
                            
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.blue.withOpacity(0.1),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: item.image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          item.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.fastfood, size: 20);
                                          },
                                        ),
                                      )
                                    : Icon(Icons.fastfood, size: 20),
                              ),
                              title: Text(
                                item.itemName,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "Rs. ${item.rate.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: Colors.blue)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedItem = item;
                                });
                              },
                            );
                          },
                        ),
            ),
            
            if (_selectedItem != null) ...[
              const Divider(),
              
              // Selected Item & Quantity
              Container(
                padding: ResponsiveUtils.getPadding(context, base: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected: ${_selectedItem!.itemName}",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, base: 8)),
                    Row(
                      children: [
                        Text("Quantity:"),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              contentPadding: ResponsiveUtils.getPadding(context, base: 8),
                              isDense: true,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Total: Rs. ${(_selectedItem!.rate * (int.tryParse(_quantityController.text) ?? 1)).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                  ElevatedButton(
                    onPressed: _addSelectedItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
