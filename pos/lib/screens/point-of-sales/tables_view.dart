import 'package:flutter/material.dart';
import '../../services/data_repository.dart';
import '../../services/table_cart_manager.dart';
import '../../models/models.dart' as pos_models;
import '../../utils/responsive.dart';
import '../../data.dart';

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
                  child: Card(
                    color: isSelected ? Colors.red[100] : 
                           (DummyData.tableHasActiveCart(table.id ?? 0) ? Colors.orange[50] : Colors.white),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Colors.red : 
                               (DummyData.tableHasActiveCart(table.id ?? 0) ? Colors.orange : Colors.grey[300]!),
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
                                     (DummyData.tableHasActiveCart(table.id ?? 0) ? Colors.orange[800] : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (DummyData.tableHasActiveCart(table.id ?? 0))
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
                                    '${DummyData.getTableCartItemCount(table.id ?? 0)} items',
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
