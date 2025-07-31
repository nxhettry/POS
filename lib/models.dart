import 'package:flutter/material.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class Item {
  final int id;
  final int categoryId;
  final String itemName;
  final double rate;

  Item({
    required this.id,
    required this.categoryId,
    required this.itemName,
    required this.rate,
  });
}

class Table {
  final int id;
  final String name;

  Table({required this.id, required this.name});
}

class CartItem {
  final Map<String, dynamic> item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice => (item['rate'] as num).toDouble() * quantity;

  Map<String, dynamic> toJson() {
    return {'item': item, 'quantity': quantity, 'totalPrice': totalPrice};
  }
}

class Sales {
  final String invoiceNo;
  final String table;
  final String orderType;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double taxRate;
  final double discount;
  final double discountValue;
  final bool isDiscountPercentage;
  final double total;
  final DateTime timestamp;

  Sales({
    required this.invoiceNo,
    required this.table,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.discount,
    required this.discountValue,
    required this.isDiscountPercentage,
    required this.total,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceNo': invoiceNo,
      'table': table,
      'orderType': orderType,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'taxRate': taxRate,
      'discount': discount,
      'discountValue': discountValue,
      'isDiscountPercentage': isDiscountPercentage,
      'total': total,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      invoiceNo: json['invoiceNo'] as String,
      table: json['table'] as String,
      orderType: json['orderType'] as String,
      items: (json['items'] as List)
          .map(
            (item) => CartItem(
              item: item['item'] as Map<String, dynamic>,
              quantity: item['quantity'] as int,
            ),
          )
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      discountValue: (json['discountValue'] as num).toDouble(),
      isDiscountPercentage: json['isDiscountPercentage'] as bool,
      total: (json['total'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
