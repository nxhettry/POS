import 'package:flutter/material.dart';
import '../../services/data_repository.dart';
import '../../services/table_cart_manager.dart';
import '../../models/models.dart' as pos_models;
import '../../utils/responsive.dart';

class TablesView extends StatefulWidget {
  final int? selectedTableId;
  final ValueChanged<pos_models.Table?>? onTableSelected;
  const TablesView({super.key, this.selectedTableId, this.onTableSelected});

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  int? selectedTableId;
  final DataRepository _dataRepository = DataRepository();
  final TableCartManager _cartManager = TableCartManager();

  @override
  void initState() {
    super.initState();
    selectedTableId = widget.selectedTableId;
  }

  Future<Map<String, dynamic>> _getTableCartStatus(int tableId) async {
    try {
      final cartData = await _dataRepository.getCartByTable(tableId);

      if (cartData.isEmpty) {
        return {'hasCart': false, 'itemCount': 0};
      }

      final cartItems = await _dataRepository.getCartItems(cartData['id']);
      final itemCount = cartItems.fold<int>(0, (sum, item) => sum + ((item['quantity'] ?? 0) as int));
      
      return {'hasCart': true, 'itemCount': itemCount};
    } catch (e) {
      print('Error getting table cart status: $e');
      return {'hasCart': false, 'itemCount': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<pos_models.Table>>(
      future: _dataRepository.fetchTables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final tables = snapshot.data ?? <pos_models.Table>[];
        return SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context),
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              final isSelected = selectedTableId == table.id;
              return Container(
                width: 160,
                height: 64,
                margin: EdgeInsets.only(
                  right: ResponsiveUtils.getSpacing(context) * 0.8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTableId = table.id;
                    });
                    
                    // Update cart manager with selected table
                    _cartManager.setSelectedTable(table.id);
                    
                    if (widget.onTableSelected != null) {
                      widget.onTableSelected!(table);
                    }
                  },
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getTableCartStatus(table.id ?? 0),
                    builder: (context, snapshot) {
                      final cartStatus = snapshot.data ?? {'hasCart': false, 'itemCount': 0};
                      final hasActiveCart = cartStatus['hasCart'] as bool;
                      final itemCount = cartStatus['itemCount'] as int;
                      
                      return Card(
                        color: isSelected ? Colors.red[100] : 
                               (hasActiveCart ? Colors.orange[50] : Colors.white),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? Colors.red : 
                                   (hasActiveCart ? Colors.orange : Colors.grey[300]!),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                table.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected ? Colors.red : 
                                         (hasActiveCart ? Colors.orange[800] : Colors.black87),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasActiveCart)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        size: 12,
                                        color: Colors.orange[800],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$itemCount items',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
