import 'package:flutter/material.dart';
import 'package:pos/screens/point-of-sales/bill_section.dart';
import 'package:pos/screens/point-of-sales/items_view.dart';
import 'package:pos/screens/point-of-sales/tables_view.dart';
import '../../utils/responsive.dart';
import '../../models/models.dart' as models;

class PointOfSaleScreen extends StatefulWidget {
  const PointOfSaleScreen({super.key});

  @override
  State<PointOfSaleScreen> createState() => _PointOfSaleScreenState();
}

class _PointOfSaleScreenState extends State<PointOfSaleScreen> {
  models.Table? selectedTable;

  void _onTableSelected(models.Table? table) {
    setState(() {
      selectedTable = table;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Padding(
          padding: ResponsiveUtils.getPadding(context),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: TablesView(
                        selectedTableId: selectedTable?.id,
                        onTableSelected: _onTableSelected,
                      ),
                    ),
                    Expanded(child: ItemsView()),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: ResponsiveUtils.getBillSectionFlex(context).round(),
                child: BillSection(selectedTable: selectedTable),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
