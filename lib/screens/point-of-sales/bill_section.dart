import "package:flutter/material.dart";

class BillSection extends StatelessWidget {
  const BillSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: const Center(
        child: Text(
          'Bill Section',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
