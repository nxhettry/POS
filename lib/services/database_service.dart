import 'database_helper.dart';
import '../models/models.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> initializeDatabase() async {
    await _databaseHelper.database;
    
    final categories = await getCategories();
    if (categories.isEmpty) {
      await _insertSampleData();
    }
  }

  Future<void> _insertSampleData() async {
    final drinksCategoryId = await _databaseHelper.insertCategory(
      Category(id: 0, name: 'Beverages'),
    );
    final foodCategoryId = await _databaseHelper.insertCategory(
      Category(id: 0, name: 'Food'),
    );

    await _databaseHelper.insertItem(
      Item(id: 0, categoryId: drinksCategoryId, itemName: 'Americano', rate: 150.0),
    );
    await _databaseHelper.insertItem(
      Item(id: 0, categoryId: drinksCategoryId, itemName: 'Milkshake', rate: 200.0),
    );
    await _databaseHelper.insertItem(
      Item(id: 0, categoryId: foodCategoryId, itemName: 'Burger', rate: 350.0),
    );
    await _databaseHelper.insertItem(
      Item(id: 0, categoryId: foodCategoryId, itemName: 'Noodles', rate: 250.0),
    );

    await _databaseHelper.insertTable(Table(id: 0, name: 'Table 1'));
    await _databaseHelper.insertTable(Table(id: 0, name: 'Table 2'));
    await _databaseHelper.insertTable(Table(id: 0, name: 'Table 3'));
    await _databaseHelper.insertTable(Table(id: 0, name: 'Table 4'));
  }

  Future<List<Category>> getCategories() async {
    return await _databaseHelper.getCategories();
  }

  Future<int> addCategory(String name) async {
    return await _databaseHelper.insertCategory(Category(id: 0, name: name));
  }

  Future<List<Item>> getItems() async {
    return await _databaseHelper.getItems();
  }

  Future<List<Item>> getItemsByCategory(int categoryId) async {
    return await _databaseHelper.getItemsByCategory(categoryId);
  }

  Future<int> addItem(int categoryId, String itemName, double rate) async {
    return await _databaseHelper.insertItem(Item(
      id: 0,
      categoryId: categoryId,
      itemName: itemName,
      rate: rate,
    ));
  }

  Future<List<Table>> getTables() async {
    return await _databaseHelper.getTables();
  }

  Future<int> addTable(String name) async {
    return await _databaseHelper.insertTable(Table(id: 0, name: name));
  }

  Future<int> saveSale(Sales sale) async {
    return await _databaseHelper.insertSale(sale);
  }

  Future<List<Sales>> getSales() async {
    return await _databaseHelper.getSales();
  }

  Future<List<Sales>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _databaseHelper.getSalesByDateRange(startDate, endDate);
  }

  Future<double> getTotalSalesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final sales = await getSalesByDateRange(startOfDay, endOfDay);
    return sales.fold<double>(0.0, (total, sale) => total + sale.total);
  }

  Future<double> getTotalSalesForDateRange(DateTime startDate, DateTime endDate) async {
    final sales = await getSalesByDateRange(startDate, endDate);
    return sales.fold<double>(0.0, (total, sale) => total + sale.total);
  }

  Future<Map<String, dynamic>> getSalesStatistics() async {
    final sales = await getSales();
    final totalSales = sales.fold<double>(0.0, (total, sale) => total + sale.total);
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
