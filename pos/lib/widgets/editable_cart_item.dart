import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart' as pos_models;
import '../services/table_cart_manager.dart';
import '../utils/responsive.dart';

class EditableCartItem extends StatefulWidget {
  final pos_models.CartItem cartItem;
  final Function()? onChanged;
  final bool isEnabled;
  
  const EditableCartItem({
    super.key,
    required this.cartItem,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<EditableCartItem> createState() => _EditableCartItemState();
}

class _EditableCartItemState extends State<EditableCartItem> {
  late TextEditingController quantityController;
  late TextEditingController rateController;
  late TextEditingController notesController;
  
  final TableCartManager _cartManager = TableCartManager();
  bool _isEditing = false;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.cartItem.quantity.toString());
    rateController = TextEditingController(text: widget.cartItem.item['rate'].toStringAsFixed(2));
    notesController = TextEditingController(text: widget.cartItem.item['notes']?.toString() ?? '');
  }

  @override
  void didUpdateWidget(EditableCartItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers when cart item data changes
    if (oldWidget.cartItem != widget.cartItem || 
        oldWidget.cartItem.quantity != widget.cartItem.quantity ||
        oldWidget.cartItem.item['rate'] != widget.cartItem.item['rate'] ||
        oldWidget.cartItem.item['notes'] != widget.cartItem.item['notes']) {
      
      quantityController.text = widget.cartItem.quantity.toString();
      rateController.text = widget.cartItem.item['rate'].toStringAsFixed(2);
      notesController.text = widget.cartItem.item['notes']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) async {
    if (newQuantity > 0 && newQuantity != widget.cartItem.quantity) {
      try {
        await _cartManager.updateItemQuantity(widget.cartItem.item['id'], newQuantity);
        quantityController.text = newQuantity.toString();
        // Only call onChanged after successful server update
        widget.onChanged?.call();
      } catch (e) {
        // Reset to original value on error
        quantityController.text = widget.cartItem.quantity.toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update quantity: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _updateRate(double newRate) async {
    if (newRate > 0) {
      try {
        // Update the item data in cart manager
        widget.cartItem.item['rate'] = newRate;
        await _cartManager.updateItemQuantity(widget.cartItem.item['id'], widget.cartItem.quantity);
        // Only call onChanged after successful server update
        widget.onChanged?.call();
      } catch (e) {
        // Reset to original value on error
        rateController.text = widget.cartItem.item['rate'].toStringAsFixed(2);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update rate: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _updateNotes(String notes) async {
    try {
      // Update the item data in cart manager
      widget.cartItem.item['notes'] = notes;
      // Trigger a cart sync for notes update
      await _cartManager.updateItemQuantity(widget.cartItem.item['id'], widget.cartItem.quantity);
      // Only call onChanged after successful server update
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeItem() async {
    try {
      await _cartManager.removeItem(widget.cartItem.item['id']);
      // Only call onChanged after successful server update
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.cartItem.item;
    final isSmallScreen = ResponsiveUtils.isSmallDesktop(context);
    
    // Update controllers if they don't match current values (handles async updates)
    if (quantityController.text != widget.cartItem.quantity.toString()) {
      quantityController.text = widget.cartItem.quantity.toString();
    }
    if (rateController.text != widget.cartItem.item['rate'].toStringAsFixed(2)) {
      rateController.text = widget.cartItem.item['rate'].toStringAsFixed(2);
    }
    final currentNotes = widget.cartItem.item['notes']?.toString() ?? '';
    if (notesController.text != currentNotes) {
      notesController.text = currentNotes;
    }
    
    return Card(
      elevation: 3, // Increased elevation
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, base: 5), // Increased margin
        horizontal: ResponsiveUtils.getSpacing(context, base: 2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isEditing ? Colors.blue : Colors.grey.shade300,
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          leading: Container(
            width: isSmallScreen ? 50 : 60, // Increased size
            height: isSmallScreen ? 50 : 60, // Increased size
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item['image'] != null && item['image'].toString().isNotEmpty
                  ? Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          color: Colors.grey[600],
                          size: isSmallScreen ? 20 : 24, // Increased icon size
                        );
                      },
                    )
                  : Icon(
                      Icons.fastfood,
                      color: Colors.grey[600],
                      size: isSmallScreen ? 20 : 24, // Increased icon size
                    ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item_name'],
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 16), // Increased font size
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Rs. ${item['rate'].toStringAsFixed(2)} x ${widget.cartItem.quantity}",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 13), // Increased font size
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Rs. ${widget.cartItem.totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16), // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          trailing: _isExpanded 
              ? Icon(Icons.expand_less, color: Colors.grey[600])
              : Icon(Icons.expand_more, color: Colors.grey[600]),
          children: [
            Padding(
              padding: ResponsiveUtils.getPadding(context, base: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity and Rate Row
                  Row(
                    children: [
                      // Quantity Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 12),
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildQuantityButton(
                                  icon: Icons.remove,
                                  color: Colors.red,
                                  onPressed: () => _updateQuantity(widget.cartItem.quantity - 1),
                                ),
                                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    controller: quantityController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: ResponsiveUtils.getSpacing(context, base: 8),
                                      ),
                                      isDense: true,
                                    ),
                                    onFieldSubmitted: (value) {
                                      final newQuantity = int.tryParse(value) ?? widget.cartItem.quantity;
                                      if (newQuantity > 0) {
                                        _updateQuantity(newQuantity);
                                      } else {
                                        quantityController.text = widget.cartItem.quantity.toString();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  color: Colors.green,
                                  onPressed: () => _updateQuantity(widget.cartItem.quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: ResponsiveUtils.getSpacing(context, base: 16)),
                      
                      // Rate Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rate (Rs.)",
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 12),
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                            TextFormField(
                              controller: rateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 14),
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: ResponsiveUtils.getPadding(context, base: 8),
                                isDense: true,
                                prefixText: "Rs. ",
                                prefixStyle: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                                  color: Colors.grey[600],
                                ),
                              ),
                              onFieldSubmitted: (value) {
                                final newRate = double.tryParse(value) ?? widget.cartItem.item['rate'];
                                if (newRate > 0) {
                                  _updateRate(newRate);
                                } else {
                                  rateController.text = widget.cartItem.item['rate'].toStringAsFixed(2);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getSpacing(context, base: 12)),
                  
                  // Notes Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notes (Optional)",
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 12),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                      TextFormField(
                        controller: notesController,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Add special instructions...",
                          contentPadding: ResponsiveUtils.getPadding(context, base: 8),
                          isDense: true,
                        ),
                        onFieldSubmitted: (value) => _updateNotes(value),
                        onEditingComplete: () => _updateNotes(notesController.text),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _removeItem,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: Text(
                          "Remove",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: ResponsiveUtils.getPadding(context, base: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        constraints: BoxConstraints(
          minWidth: ResponsiveUtils.isSmallDesktop(context) ? 32 : 36,
          minHeight: ResponsiveUtils.isSmallDesktop(context) ? 32 : 36,
        ),
        iconSize: ResponsiveUtils.isSmallDesktop(context) ? 16 : 18,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final pos_models.CartItem cartItem;
  final VoidCallback onSave;

  const EditItemDialog({
    super.key,
    required this.cartItem,
    required this.onSave,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController quantityController;
  late TextEditingController rateController;
  late TextEditingController notesController;
  
  final TableCartManager _cartManager = TableCartManager();

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.cartItem.quantity.toString());
    rateController = TextEditingController(text: widget.cartItem.item['rate'].toStringAsFixed(2));
    notesController = TextEditingController(text: widget.cartItem.item['notes']?.toString() ?? '');
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final quantity = int.tryParse(quantityController.text) ?? widget.cartItem.quantity;
    final rate = double.tryParse(rateController.text) ?? widget.cartItem.item['rate'];
    final notes = notesController.text.trim();

    if (quantity > 0 && rate > 0) {
      // Update item data
      widget.cartItem.item['rate'] = rate;
      widget.cartItem.item['notes'] = notes.isEmpty ? null : notes;
      
      // Update quantity in cart manager
      await _cartManager.updateItemQuantity(widget.cartItem.item['id'], quantity);
      
      widget.onSave();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid quantity and rate'),
          backgroundColor: Colors.red,
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
        width: 400,
        padding: ResponsiveUtils.getPadding(context, base: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                Text(
                  "Edit Item",
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
            
            Text(
              widget.cartItem.item['item_name'],
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 20)),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quantity", style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: ResponsiveUtils.getPadding(context, base: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rate (Rs.)", style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                      TextFormField(
                        controller: rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: ResponsiveUtils.getPadding(context, base: 12),
                          prefixText: "Rs. ",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 16)),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notes (Optional)", style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: ResponsiveUtils.getSpacing(context, base: 4)),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: "Add special instructions...",
                    contentPadding: ResponsiveUtils.getPadding(context, base: 12),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context, base: 24)),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context, base: 8)),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
