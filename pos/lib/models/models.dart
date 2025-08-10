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

  Table({this.id, required this.name, this.status = 'available'});
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

class PaymentMethod {
  final int? id;
  final String name;
  final String type;
  final bool isActive;

  PaymentMethod({
    this.id,
    required this.name,
    required this.type,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type, 'isActive': isActive};
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'cash',
      isActive: _parseBoolFromDynamic(json['isActive'] ?? json['is_active']),
    );
  }
}

class Party {
  final int? id;
  final String name;
  final String type;
  final String? phone;
  final String? email;
  final String? address;

  Party({
    this.id,
    required this.name,
    required this.type,
    this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'customer',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }
}

class SalesItem {
  final int? id;
  final int salesId;
  final int itemId;
  final String itemName;
  final double quantity;
  final double rate;
  final double totalPrice;
  final String? notes;
  final Map<String, dynamic>? menuItem;

  SalesItem({
    this.id,
    required this.salesId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.totalPrice,
    this.notes,
    this.menuItem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salesId': salesId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
      'totalPrice': totalPrice,
      'notes': notes,
      'menuItem': menuItem,
    };
  }

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      id: json['id'],
      salesId: json['salesId'] ?? json['sales_id'],
      itemId: json['itemId'] ?? json['item_id'],
      itemName: json['itemName'] ?? json['item_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? json['total_price'] ?? 0).toDouble(),
      notes: json['notes'],
      menuItem: json['MenuItem'] ?? json['menuItem'],
    );
  }
}

class Sales {
  final int? id;
  final String invoiceNo;
  final String table;
  final String orderType;
  final String orderStatus;
  final String paymentStatus;
  final List<dynamic> items;
  final double subtotal;
  final double tax;
  final double taxRate;
  final double discount;
  final double discountValue;
  final bool isDiscountPercentage;
  final double total;
  final DateTime timestamp;
  final int? tableId;
  final int? paymentMethodId;
  final int? partyId;
  final int? createdBy;
  final int? signedBy;

  final Map<String, dynamic>? tableInfo;
  final PaymentMethod? paymentMethod;
  final Party? party;
  final Map<String, dynamic>? creator;
  final Map<String, dynamic>? signer;

  Sales({
    this.id,
    required this.invoiceNo,
    required this.table,
    required this.orderType,
    this.orderStatus = 'pending',
    this.paymentStatus = 'pending',
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.discount,
    required this.discountValue,
    required this.isDiscountPercentage,
    required this.total,
    required this.timestamp,
    this.tableId,
    this.paymentMethodId,
    this.partyId,
    this.createdBy,
    this.signedBy,
    this.tableInfo,
    this.paymentMethod,
    this.party,
    this.creator,
    this.signer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'table': table,
      'orderType': orderType,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'items': items
          .map(
            (item) => item is CartItem
                ? item.toJson()
                : item is SalesItem
                ? item.toJson()
                : item,
          )
          .toList(),
      'subtotal': subtotal,
      'tax': tax,
      'taxRate': taxRate,
      'discount': discount,
      'discountValue': discountValue,
      'isDiscountPercentage': isDiscountPercentage,
      'total': total,
      'timestamp': timestamp.toIso8601String(),
      'tableId': tableId,
      'paymentMethodId': paymentMethodId,
      'partyId': partyId,
      'createdBy': createdBy,
      'signedBy': signedBy,
      'tableInfo': tableInfo,
      'paymentMethod': paymentMethod?.toJson(),
      'party': party?.toJson(),
      'creator': creator,
      'signer': signer,
    };
  }

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      id: json['id'],
      invoiceNo: json['invoiceNo'] ?? json['invoice_no'] ?? '',
      table: json['table'] ?? json['Table']?['name'] ?? '',
      orderType: json['orderType'] ?? json['order_type'] ?? 'Dine In',
      orderStatus: json['orderStatus'] ?? json['order_status'] ?? 'pending',
      paymentStatus:
          json['paymentStatus'] ?? json['payment_status'] ?? 'pending',
      items: (json['items'] as List? ?? json['SalesItems'] as List? ?? []).map((
        item,
      ) {
        if (item['item'] != null) {
          return CartItem(
            item: item['item'] as Map<String, dynamic>,
            quantity: item['quantity'] as int,
          );
        } else {
          return SalesItem.fromJson(item);
        }
      }).toList(),
      subtotal: (json['subtotal'] ?? json['subTotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? json['tax_rate'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      discountValue: (json['discountValue'] ?? json['discount_value'] ?? 0)
          .toDouble(),
      isDiscountPercentage: _parseBoolFromDynamic(
        json['isDiscountPercentage'] ?? json['is_discount_percentage'],
      ),
      total: (json['total'] ?? 0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ??
            json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      tableId: json['tableId'] ?? json['table_id'],
      paymentMethodId: json['paymentMethodId'] ?? json['payment_method_id'],
      partyId: json['partyId'] ?? json['party_id'],
      createdBy: json['createdBy'] ?? json['created_by'],
      signedBy: json['signedBy'] ?? json['signed_by'],
      tableInfo: json['Table'],
      paymentMethod: json['PaymentMethod'] != null
          ? PaymentMethod.fromJson(json['PaymentMethod'])
          : null,
      party: json['Party'] != null ? Party.fromJson(json['Party']) : null,
      creator: json['User'] ?? json['creator'],
      signer: json['signer'],
    );
  }

  static Sales fromMap(Map<String, dynamic> map) {
    return Sales.fromJson(map);
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
      includeTax: _parseBoolFromDynamic(
        map['include_tax'] ?? map['includeTax'],
      ),
      includeDiscount: _parseBoolFromDynamic(
        map['include_discount'] ?? map['includeDiscount'],
      ),
      printCustomerCopy: _parseBoolFromDynamic(
        map['print_customer_copy'] ?? map['printCustomerCopy'],
      ),
      printKitchenCopy: _parseBoolFromDynamic(
        map['print_kitchen_copy'] ?? map['printKitchenCopy'],
      ),
      showItemCode: _parseBoolFromDynamic(
        map['show_item_code'] ?? map['showItemCode'],
      ),
      billFooter:
          map['bill_footer'] ?? map['billFooter'] ?? "Thank you for visiting!",
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
  final String dateFormat;
  final String language;
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
      defaultTaxRate: (map['default_tax_rate'] ?? map['defaultTaxRate'] ?? 0.0)
          .toDouble(),
      autoBackup: _parseBoolFromDynamic(
        map['auto_backup'] ?? map['autoBackup'],
      ),
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
      'pan': panNumber,
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
      'pan_number': panNumber,
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
      panNumber: map['pan'] ?? map['pan_number'] as String,
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
