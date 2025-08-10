import 'package:flutter/material.dart';
import '../../services/data_repository.dart';
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
          height: 80, // Fixed height for horizontal scroll
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
                width: 160, // Fixed width for rectangular cards (similar to w-40)
                height: 64, // Fixed height (similar to h-16)
                margin: EdgeInsets.only(
                  right: ResponsiveUtils.getSpacing(context) * 0.8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTableId = table.id;
                    });
                    if (widget.onTableSelected != null) {
                      widget.onTableSelected!(table);
                    }
                  },
                  child: Card(
                    color: isSelected ? Colors.red[100] : Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Colors.red : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          table.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected ? Colors.red : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
