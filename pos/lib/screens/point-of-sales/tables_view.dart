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
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: ResponsiveUtils.getGridColumns(context),
      crossAxisSpacing: ResponsiveUtils.getSpacing(context),
      mainAxisSpacing: ResponsiveUtils.getSpacing(context),
      childAspectRatio: 1.5,
    ),
    itemCount: tables.length,
    itemBuilder: (context, index) {
      final table = tables[index];
      final isSelected = selectedTableId == table.id;
      return GestureDetector(
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
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.red : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              table.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                color: isSelected ? Colors.red : Colors.black,
              ),
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
