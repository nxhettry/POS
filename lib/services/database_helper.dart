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
    return await openDatabase(
      join(path, 'pos_database.db'),
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS sales');
          await _createTables(db);
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
  }

  // Category operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', {
      'name': category.name,
    });
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  // Item operations
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', {
      'category_id': item.categoryId,
      'item_name': item.itemName,
      'rate': item.rate,
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
      );
    });
  }

  // Table operations
  Future<int> insertTable(Table table) async {
    final db = await database;
    return await db.insert('tables', {
      'name': table.name,
    });
  }

  Future<List<Table>> getTables() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tables');
    return List.generate(maps.length, (i) {
      return Table(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  // Sales operations
  Future<int> insertSale(Sales sale) async {
    final db = await database;
    
    // Insert the main sale record
    int saleId = await db.insert('sales', {
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

    // Insert cart items for this sale
    for (CartItem cartItem in sale.items) {
      await db.insert('cart_items', {
        'sale_id': saleId,
        'item_id': cartItem.item['id'],
        'item_name': cartItem.item['itemName'],
        'rate': cartItem.item['rate'],
        'quantity': cartItem.quantity,
        'total_price': cartItem.totalPrice,
      });
    }

    return saleId;
  }

  Future<List<Sales>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> salesMaps = await db.query('sales', orderBy: 'timestamp DESC');
    
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
            'itemName': cartItemMap['item_name'],
            'rate': cartItemMap['rate'],
          },
          quantity: cartItemMap['quantity'],
        );
      }).toList();

      salesList.add(Sales(
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
      ));
    }

    return salesList;
  }

  Future<List<Sales>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
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
            'itemName': cartItemMap['item_name'],
            'rate': cartItemMap['rate'],
          },
          quantity: cartItemMap['quantity'],
        );
      }).toList();

      salesList.add(Sales(
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
      ));
    }

    return salesList;
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
