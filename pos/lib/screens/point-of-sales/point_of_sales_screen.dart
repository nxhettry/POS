import 'package:flutter/material.dart';
import 'package:pos/screens/point-of-sales/bill_section.dart';
import 'package:pos/screens/point-of-sales/items_view.dart';
import 'package:pos/screens/point-of-sales/tables_view.dart';
import '../../utils/responsive.dart';

class PointOfSaleScreen extends StatelessWidget {
  const PointOfSaleScreen({super.key});

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
                      child: TablesView(),
                    ),
                    Expanded(child: ItemsView()),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: ResponsiveUtils.getBillSectionFlex(context).round(),
                child: const BillSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
