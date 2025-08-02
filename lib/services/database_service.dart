import 'database_helper.dart';
import '../models/models.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> initializeDatabase() async {
    await _databaseHelper.database;
    await _seedDefaultTables();
  }

  Future<void> _seedDefaultTables() async {
    // Check if tables already exist
    final existingTables = await getTables();
    if (existingTables.isEmpty) {
      // Add some default tables
      for (int i = 1; i <= 12; i++) {
        await addTable("Table $i");
      }
    }
  }

  Future<List<Category>> getCategories() async {
    return await _databaseHelper.getCategories();
  }

  Future<int> addCategory(String name) async {
    return await _databaseHelper.insertCategory(Category(name: name));
  }

  Future<List<Item>> getItems() async {
    return await _databaseHelper.getItems();
  }

  Future<List<Item>> getItemsByCategory(int categoryId) async {
    return await _databaseHelper.getItemsByCategory(categoryId);
  }

  Future<int> addItem(
    int categoryId,
    String itemName,
    double rate, {
    String? image,
  }) async {
    return await _databaseHelper.insertItem(
      Item(
        categoryId: categoryId,
        itemName: itemName,
        rate: rate,
        image: image,
      ),
    );
  }

  Future<List<Table>> getTables() async {
    return await _databaseHelper.getTables();
  }

  Future<int> addTable(String name) async {
    return await _databaseHelper.insertTable(Table(name: name));
  }

  Future<int> deleteTable(int tableId) async {
    return await _databaseHelper.deleteTable(tableId);
  }

  Future<int> saveSale(Sales sale) async {
    print('DatabaseService: Saving sale with invoice: ${sale.invoiceNo}');
    print('DatabaseService: Sale items count: ${sale.items.length}');
    try {
      final result = await _databaseHelper.insertSale(sale);
      print('DatabaseService: Sale saved successfully with ID: $result');
      return result;
    } catch (e) {
      print('DatabaseService: Error saving sale: $e');
      rethrow;
    }
  }

  Future<List<Sales>> getSales() async {
    return await _databaseHelper.getSales();
  }

  Future<String> getNextInvoiceNumber() async {
    return await _databaseHelper.getNextInvoiceNumber();
  }

  Future<List<Sales>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _databaseHelper.getSalesByDateRange(startDate, endDate);
  }

  Future<double> getTotalSalesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final sales = await getSalesByDateRange(startOfDay, endOfDay);
    return sales.fold<double>(0.0, (total, sale) => total + sale.total);
  }

  Future<double> getTotalSalesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sales = await getSalesByDateRange(startDate, endDate);
    return sales.fold<double>(0.0, (total, sale) => total + sale.total);
  }

  Future<Map<String, dynamic>> getSalesStatistics() async {
    final sales = await getSales();
    final totalSales = sales.fold<double>(
      0.0,
      (total, sale) => total + sale.total,
    );
    final totalOrders = sales.length;
    final averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    final today = DateTime.now();
    final todaysSales = await getTotalSalesForDate(today);

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'todaysSales': todaysSales,
    };
  }

  Future<void> clearAllData() async {
    await _databaseHelper.deleteDatabase();
  }
}
