import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'pos_database.db');
    print('Database path: $dbPath'); // Debug: Print the actual database path
    return await openDatabase(
      dbPath,
      version: 6,
      onCreate: (db, version) async {
        await _createTables(db);
        print('Database created at: $dbPath'); // Debug: Confirm creation
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS sales');
          await _createTables(db);
        }
        if (oldVersion < 3) {
          // Add image column to items table
          await db.execute('ALTER TABLE items ADD COLUMN image TEXT');
        }
        if (oldVersion < 4) {
          // Add counters table for auto-increment functionality
          await db.execute('''
            CREATE TABLE counters (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              counter_name TEXT UNIQUE NOT NULL,
              counter_value INTEGER NOT NULL DEFAULT 0
            )
          ''');
          // Initialize invoice counter
          await db.execute('''
            INSERT INTO counters (counter_name, counter_value) VALUES ('invoice_counter', 0)
          ''');
        }
        if (oldVersion < 5) {
          // Add restaurant table
          await db.execute('''
            CREATE TABLE restaurant (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              address TEXT NOT NULL,
              phone TEXT NOT NULL,
              email TEXT NOT NULL,
              pan_number TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE bill_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              include_tax INTEGER NOT NULL DEFAULT 1,
              include_discount INTEGER NOT NULL DEFAULT 1,
              print_customer_copy INTEGER NOT NULL DEFAULT 1,
              print_kitchen_copy INTEGER NOT NULL DEFAULT 1
            )
          ''');
          await db.execute('''
            CREATE TABLE system_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              currency TEXT NOT NULL DEFAULT 'NPR',
              date_format TEXT NOT NULL DEFAULT 'dd/MM/yyyy',
              language TEXT NOT NULL DEFAULT 'English'
            )
          ''');
          await db.execute('''
            CREATE TABLE tax_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tax_rate REAL NOT NULL DEFAULT 13.0,
              tax_name TEXT NOT NULL DEFAULT 'VAT',
              is_enabled INTEGER NOT NULL DEFAULT 1
            )
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        rate REAL NOT NULL,
        image TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create tables table
    await db.execute('''
      CREATE TABLE tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL,
        table_name TEXT NOT NULL,
        order_type TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        tax_rate REAL NOT NULL,
        discount REAL NOT NULL,
        discount_value REAL NOT NULL,
        is_discount_percentage INTEGER NOT NULL,
        total REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create cart_items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        rate REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Create restaurant table
    await db.execute('''
      CREATE TABLE restaurant (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        pan_number TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bill_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        include_tax INTEGER NOT NULL DEFAULT 1,
        include_discount INTEGER NOT NULL DEFAULT 1,
        print_customer_copy INTEGER NOT NULL DEFAULT 1,
        print_kitchen_copy INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE system_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currency TEXT NOT NULL DEFAULT 'NPR',
        date_format TEXT NOT NULL DEFAULT 'dd/MM/yyyy',
        language TEXT NOT NULL DEFAULT 'English'
      )
    ''');

    await db.execute('''
      CREATE TABLE tax_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tax_rate REAL NOT NULL DEFAULT 13.0,
        tax_name TEXT NOT NULL DEFAULT 'VAT',
        is_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create counters table for auto-increment values
    await db.execute('''
      CREATE TABLE counters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        counter_name TEXT UNIQUE NOT NULL,
        counter_value INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Initialize invoice counter
    await db.execute('''
      INSERT INTO counters (counter_name, counter_value) VALUES ('invoice_counter', 0)
    ''');
  }

  // Category operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', {'name': category.name});
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category(id: maps[i]['id'], name: maps[i]['name']);
    });
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      {'name': category.name},
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int categoryId) async {
    final db = await database;
    // First delete all items in this category
    await db.delete('items', where: 'category_id = ?', whereArgs: [categoryId]);
    // Then delete the category
    return await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
  }

  // Item operations
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', {
      'category_id': item.categoryId,
      'item_name': item.itemName,
      'rate': item.rate,
      'image': item.image,
    });
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        categoryId: maps[i]['category_id'],
        itemName: maps[i]['item_name'],
        rate: maps[i]['rate'],
        image: maps[i]['image'],
      );
    });
  }

  Future<List<Item>> getItemsByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        categoryId: maps[i]['category_id'],
        itemName: maps[i]['item_name'],
        rate: maps[i]['rate'],
        image: maps[i]['image'],
      );
    });
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      {
        'category_id': item.categoryId,
        'item_name': item.itemName,
        'rate': item.rate,
        'image': item.image,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int itemId) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
  }

  // Table operations
  Future<int> insertTable(Table table) async {
    final db = await database;
    return await db.insert('tables', {'name': table.name});
  }

  Future<List<Table>> getTables() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tables');
    return List.generate(maps.length, (i) {
      return Table(id: maps[i]['id'], name: maps[i]['name']);
    });
  }

  Future<int> deleteTable(int tableId) async {
    final db = await database;
    return await db.delete('tables', where: 'id = ?', whereArgs: [tableId]);
  }

  Future<String> getNextInvoiceNumber() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'counters',
      where: 'counter_name = ?',
      whereArgs: ['invoice_counter'],
    );

    int currentCounter = 0;
    if (result.isNotEmpty) {
      currentCounter = result.first['counter_value'] as int;
    }

    final newCounter = currentCounter + 1;

    await db.update(
      'counters',
      {'counter_value': newCounter},
      where: 'counter_name = ?',
      whereArgs: ['invoice_counter'],
    );

    return 'INV-${newCounter.toString().padLeft(3, '0')}';
  }

  Future<int> insertSale(Sales sale) async {
    final db = await database;
    print('DatabaseHelper: Starting to insert sale: ${sale.invoiceNo}');

    try {
      int saleId = await db.transaction((txn) async {
        int saleId = await txn.insert('sales', {
          'invoice_no': sale.invoiceNo,
          'table_name': sale.table,
          'order_type': sale.orderType,
          'subtotal': sale.subtotal,
          'tax': sale.tax,
          'tax_rate': sale.taxRate,
          'discount': sale.discount,
          'discount_value': sale.discountValue,
          'is_discount_percentage': sale.isDiscountPercentage ? 1 : 0,
          'total': sale.total,
          'timestamp': sale.timestamp.toIso8601String(),
        });

        print('DatabaseHelper: Main sale record inserted with ID: $saleId');

        for (int i = 0; i < sale.items.length; i++) {
          CartItem cartItem = sale.items[i];
          print(
            'DatabaseHelper: Inserting cart item ${i + 1}: ${cartItem.item['item_name']}',
          );

          await txn.insert('cart_items', {
            'sale_id': saleId,
            'item_id': cartItem.item['id'],
            'item_name': cartItem.item['item_name'],
            'rate': cartItem.item['rate'],
            'quantity': cartItem.quantity,
            'total_price': cartItem.totalPrice,
          });
        }

        print(
          'DatabaseHelper: All ${sale.items.length} cart items inserted successfully',
        );
        return saleId;
      });

      return saleId;
    } catch (e) {
      print(
        'DatabaseHelper: Error inserting sale (transaction rolled back): $e',
      );
      rethrow;
    }
  }

  Future<List<Sales>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> salesMaps = await db.query(
      'sales',
      orderBy: 'timestamp DESC',
    );

    List<Sales> salesList = [];
    for (Map<String, dynamic> saleMap in salesMaps) {
      // Get cart items for this sale
      final List<Map<String, dynamic>> cartItemsMaps = await db.query(
        'cart_items',
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      List<CartItem> cartItems = cartItemsMaps.map((cartItemMap) {
        return CartItem(
          item: {
            'id': cartItemMap['item_id'],
            'item_name': cartItemMap['item_name'],
            'rate': cartItemMap['rate'],
          },
          quantity: cartItemMap['quantity'],
        );
      }).toList();

      salesList.add(
        Sales(
          invoiceNo: saleMap['invoice_no'],
          table: saleMap['table_name'],
          orderType: saleMap['order_type'],
          items: cartItems,
          subtotal: saleMap['subtotal'],
          tax: saleMap['tax'],
          taxRate: saleMap['tax_rate'],
          discount: saleMap['discount'],
          discountValue: saleMap['discount_value'],
          isDiscountPercentage: saleMap['is_discount_percentage'] == 1,
          total: saleMap['total'],
          timestamp: DateTime.parse(saleMap['timestamp']),
        ),
      );
    }

    return salesList;
  }

  Future<List<Sales>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> salesMaps = await db.query(
      'sales',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    List<Sales> salesList = [];
    for (Map<String, dynamic> saleMap in salesMaps) {
      final List<Map<String, dynamic>> cartItemsMaps = await db.query(
        'cart_items',
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      List<CartItem> cartItems = cartItemsMaps.map((cartItemMap) {
        return CartItem(
          item: {
            'id': cartItemMap['item_id'],
            'item_name': cartItemMap['item_name'],
            'rate': cartItemMap['rate'],
          },
          quantity: cartItemMap['quantity'],
        );
      }).toList();

      salesList.add(
        Sales(
          invoiceNo: saleMap['invoice_no'],
          table: saleMap['table_name'],
          orderType: saleMap['order_type'],
          items: cartItems,
          subtotal: saleMap['subtotal'],
          tax: saleMap['tax'],
          taxRate: saleMap['tax_rate'],
          discount: saleMap['discount'],
          discountValue: saleMap['discount_value'],
          isDiscountPercentage: saleMap['is_discount_percentage'] == 1,
          total: saleMap['total'],
          timestamp: DateTime.parse(saleMap['timestamp']),
        ),
      );
    }

    return salesList;
  }

  // Restaurant operations
  Future<int> insertRestaurant(Restaurant restaurant) async {
    final db = await database;
    return await db.insert('restaurant', restaurant.toMap());
  }

  Future<Restaurant?> getRestaurant() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('restaurant', limit: 1);
    
    if (maps.isNotEmpty) {
      return Restaurant.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRestaurant(Restaurant restaurant) async {
    final db = await database;
    return await db.update(
      'restaurant',
      restaurant.toMap(),
      where: 'id = ?',
      whereArgs: [restaurant.id],
    );
  }

  Future<int> upsertRestaurant(Restaurant restaurant) async {
    final existing = await getRestaurant();
    if (existing != null) {
      return await updateRestaurant(restaurant.copyWith(id: existing.id));
    } else {
      return await insertRestaurant(restaurant);
    }
  }

  Future<int> insertBillSettings(BillSettings settings) async {
    final db = await database;
    return await db.insert('bill_settings', settings.toMap());
  }

  Future<BillSettings?> getBillSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bill_settings', limit: 1);
    
    if (maps.isNotEmpty) {
      return BillSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBillSettings(BillSettings settings) async {
    final db = await database;
    return await db.update(
      'bill_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  Future<int> upsertBillSettings(BillSettings settings) async {
    final existing = await getBillSettings();
    if (existing != null) {
      return await updateBillSettings(settings.copyWith(id: existing.id));
    } else {
      return await insertBillSettings(settings);
    }
  }

  Future<int> insertSystemSettings(SystemSettings settings) async {
    final db = await database;
    return await db.insert('system_settings', settings.toMap());
  }

  Future<SystemSettings?> getSystemSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('system_settings', limit: 1);
    
    if (maps.isNotEmpty) {
      return SystemSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSystemSettings(SystemSettings settings) async {
    final db = await database;
    return await db.update(
      'system_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  Future<int> upsertSystemSettings(SystemSettings settings) async {
    final existing = await getSystemSettings();
    if (existing != null) {
      return await updateSystemSettings(settings.copyWith(id: existing.id));
    } else {
      return await insertSystemSettings(settings);
    }
  }

  Future<int> insertTaxSettings(TaxSettings settings) async {
    final db = await database;
    return await db.insert('tax_settings', settings.toMap());
  }

  Future<TaxSettings?> getTaxSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tax_settings', limit: 1);
    
    if (maps.isNotEmpty) {
      return TaxSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTaxSettings(TaxSettings settings) async {
    final db = await database;
    return await db.update(
      'tax_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  Future<int> upsertTaxSettings(TaxSettings settings) async {
    final existing = await getTaxSettings();
    if (existing != null) {
      return await updateTaxSettings(settings.copyWith(id: existing.id));
    } else {
      return await insertTaxSettings(settings);
    }
  }

  // Utility methods
  Future<void> deleteDatabase() async {
    String path = await getDatabasesPath();
    await databaseFactory.deleteDatabase(join(path, 'pos_database.db'));
    _database = null;
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
