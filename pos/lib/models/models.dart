/// Utility function to parse boolean from dynamic values
bool _parseBoolFromDynamic(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});
}

class Item {
  final int? id;
  final int categoryId;
  final String itemName;
  final double rate;
  final String? image;

  Item({
    this.id,
    required this.categoryId,
    required this.itemName,
    required this.rate,
    this.image,
  });
}

class Table {
  final int? id;
  final String name;
  final String status;

  Table({
    this.id, 
    required this.name,
    this.status = 'available',
  });
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
      isDiscountPercentage: _parseBoolFromDynamic(json['isDiscountPercentage']),
      total: (json['total'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static Sales fromMap(Map<String, dynamic> map) {
    return Sales(
      invoiceNo: map['invoiceNo'] as String,
      table: map['table'] as String,
      orderType: map['orderType'] as String,
      items: (map['items'] as List)
          .map(
            (item) => CartItem(
              item: item['item'] as Map<String, dynamic>,
              quantity: item['quantity'] as int,
            ),
          )
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      taxRate: (map['taxRate'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      discountValue: (map['discountValue'] as num).toDouble(),
      isDiscountPercentage: _parseBoolFromDynamic(map['isDiscountPercentage']),
      total: (map['total'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class RestaurantInfo {
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String pan;

  RestaurantInfo({
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    required this.pan,
  });
}

class BillSettings {
  final int? id;
  final bool includeTax;
  final bool includeDiscount;
  final bool printCustomerCopy;
  final bool printKitchenCopy;
  final bool showItemCode;
  final String billFooter;

  BillSettings({
    this.id,
    this.includeTax = true,
    this.includeDiscount = true,
    this.printCustomerCopy = true,
    this.printKitchenCopy = false,
    this.showItemCode = true,
    this.billFooter = "Thank you for visiting!",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'include_tax': includeTax ? 1 : 0,
      'include_discount': includeDiscount ? 1 : 0,
      'print_customer_copy': printCustomerCopy ? 1 : 0,
      'print_kitchen_copy': printKitchenCopy ? 1 : 0,
      'show_item_code': showItemCode ? 1 : 0,
      'bill_footer': billFooter,
    };
  }

  // For server API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'includeTax': includeTax,
      'includeDiscount': includeDiscount,
      'printCustomerCopy': printCustomerCopy,
      'printKitchenCopy': printKitchenCopy,
      'showItemCode': showItemCode,
      'billFooter': billFooter,
    };
  }

  factory BillSettings.fromMap(Map<String, dynamic> map) {
    return BillSettings(
      id: map['id'] as int?,
      includeTax: _parseBoolFromDynamic(map['include_tax'] ?? map['includeTax']),
      includeDiscount: _parseBoolFromDynamic(map['include_discount'] ?? map['includeDiscount']),
      printCustomerCopy: _parseBoolFromDynamic(map['print_customer_copy'] ?? map['printCustomerCopy']),
      printKitchenCopy: _parseBoolFromDynamic(map['print_kitchen_copy'] ?? map['printKitchenCopy']),
      showItemCode: _parseBoolFromDynamic(map['show_item_code'] ?? map['showItemCode']),
      billFooter: map['bill_footer'] ?? map['billFooter'] ?? "Thank you for visiting!",
    );
  }

  BillSettings copyWith({
    int? id,
    bool? includeTax,
    bool? includeDiscount,
    bool? printCustomerCopy,
    bool? printKitchenCopy,
    bool? showItemCode,
    String? billFooter,
  }) {
    return BillSettings(
      id: id ?? this.id,
      includeTax: includeTax ?? this.includeTax,
      includeDiscount: includeDiscount ?? this.includeDiscount,
      printCustomerCopy: printCustomerCopy ?? this.printCustomerCopy,
      printKitchenCopy: printKitchenCopy ?? this.printKitchenCopy,
      showItemCode: showItemCode ?? this.showItemCode,
      billFooter: billFooter ?? this.billFooter,
    );
  }
}

class SystemSettings {
  final int? id;
  final String currency;
  final String dateFormat; // "YYYY-MM-DD" or "DD-MM-YYYY"
  final String language; // "en" or "np"
  final double defaultTaxRate;
  final bool autoBackup;

  SystemSettings({
    this.id,
    required this.currency,
    required this.dateFormat,
    required this.language,
    this.defaultTaxRate = 0.0,
    this.autoBackup = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currency': currency,
      'date_format': dateFormat,
      'language': language,
      'default_tax_rate': defaultTaxRate,
      'auto_backup': autoBackup ? 1 : 0,
    };
  }

  // For server API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'dateFormat': dateFormat,
      'language': language,
      'defaultTaxRate': defaultTaxRate,
      'autoBackup': autoBackup,
    };
  }

  factory SystemSettings.fromMap(Map<String, dynamic> map) {
    return SystemSettings(
      id: map['id'] as int?,
      currency: map['currency'] as String,
      dateFormat: map['date_format'] ?? map['dateFormat'] as String,
      language: map['language'] as String,
      defaultTaxRate: (map['default_tax_rate'] ?? map['defaultTaxRate'] ?? 0.0).toDouble(),
      autoBackup: _parseBoolFromDynamic(map['auto_backup'] ?? map['autoBackup']),
    );
  }

  SystemSettings copyWith({
    int? id,
    String? currency,
    String? dateFormat,
    String? language,
    double? defaultTaxRate,
    bool? autoBackup,
  }) {
    return SystemSettings(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      language: language ?? this.language,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }
}

class TaxSettings {
  final int? id;
  final double taxRate;
  final String taxName;
  final bool isEnabled;

  TaxSettings({
    this.id,
    required this.taxRate,
    required this.taxName,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tax_rate': taxRate,
      'tax_name': taxName,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  factory TaxSettings.fromMap(Map<String, dynamic> map) {
    return TaxSettings(
      id: map['id'] as int?,
      taxRate: (map['tax_rate'] as num).toDouble(),
      taxName: map['tax_name'] as String,
      isEnabled: _parseBoolFromDynamic(map['is_enabled']),
    );
  }

  TaxSettings copyWith({
    int? id,
    double? taxRate,
    String? taxName,
    bool? isEnabled,
  }) {
    return TaxSettings(
      id: id ?? this.id,
      taxRate: taxRate ?? this.taxRate,
      taxName: taxName ?? this.taxName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class Restaurant {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String panNumber;
  final String? website;
  final String? logo;

  Restaurant({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.panNumber,
    this.website,
    this.logo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'pan': panNumber, // Changed to match server expectation
      'website': website,
      'logo': logo,
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'pan_number': panNumber, // Keep for local database compatibility
      'website': website,
      'logo': logo,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      panNumber: map['pan'] ?? map['pan_number'] as String, // Handle both formats
      website: map['website'] as String?,
      logo: map['logo'] as String?,
    );
  }

  Restaurant copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? panNumber,
    String? website,
    String? logo,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      panNumber: panNumber ?? this.panNumber,
      website: website ?? this.website,
      logo: logo ?? this.logo,
    );
  }
}

class Expense {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final int categoryId;

  Expense({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as int,
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    int? categoryId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class ExpensesCategory {
  final int? id;
  final String name;

  ExpensesCategory({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory ExpensesCategory.fromMap(Map<String, dynamic> map) {
    return ExpensesCategory(id: map['id'] as int?, name: map['name'] as String);
  }

  ExpensesCategory copyWith({int? id, String? name}) {
    return ExpensesCategory(id: id ?? this.id, name: name ?? this.name);
  }
}
