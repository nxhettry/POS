import 'package:flutter/material.dart';
import 'package:pos/screens/point-of-sales/bill_section.dart';
import 'package:pos/screens/point-of-sales/items_view.dart';

class PointOfSaleScreen extends StatelessWidget {
  const PointOfSaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: const ItemsView()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: const BillSection()),
            ],
          ),
        ),
      ),
    );
  }
}
