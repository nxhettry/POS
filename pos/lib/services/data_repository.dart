import 'api_data_service.dart';
import '../models/models.dart';

class DataRepository {
  final ApiDataService _apiDataService = ApiDataService();

  // ========== AUTHENTICATION ==========
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await _apiDataService.login(username, password);
  }

  Future<void> logout() async {
    await _apiDataService.logout();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiDataService.getUserProfile();
  }

  // ========== MENU CATEGORIES ==========
  Future<List<Category>> fetchCategories() async {
    return await _apiDataService.getMenuCategories();
  }

  Future<Category> createCategory(String name) async {
    return await _apiDataService.createMenuCategory(name);
  }

  Future<Category> updateCategory(int id, String name) async {
    return await _apiDataService.updateMenuCategory(id, name);
  }

  Future<void> deleteCategory(int id) async {
    await _apiDataService.deleteMenuCategory(id);
  }

  // ========== MENU ITEMS ==========
  Future<List<Item>> fetchItems() async {
    return await _apiDataService.getMenuItems();
  }

  Future<List<Item>> fetchItemsByCategory(int categoryId) async {
    return await _apiDataService.getMenuItemsByCategory(categoryId);
  }

  Future<Item> createItem(int categoryId, String itemName, double rate, {String? image}) async {
    return await _apiDataService.createMenuItem(categoryId, itemName, rate, image: image);
  }

  Future<Item> updateItem(int id, int categoryId, String itemName, double rate, {String? image}) async {
    return await _apiDataService.updateMenuItem(id, categoryId, itemName, rate, image: image);
  }

  Future<void> deleteItem(int id) async {
    await _apiDataService.deleteMenuItem(id);
  }

  // ========== TABLES ==========
  Future<List<Table>> fetchTables() async {
    return await _apiDataService.getTables();
  }

  Future<Table> createTable(String name, {String status = 'available'}) async {
    return await _apiDataService.createTable(name, status: status);
  }

  Future<Table> updateTable(int id, String name, {String? status}) async {
    return await _apiDataService.updateTable(id, name, status: status);
  }

  Future<void> deleteTable(int id) async {
    await _apiDataService.deleteTable(id);
  }

  // ========== SALES ==========
  Future<List<Sales>> fetchSales() async {
    return await _apiDataService.getSales();
  }

  Future<Sales> createSale(Sales sale) async {
    return await _apiDataService.createSale(sale);
  }

  Future<List<Sales>> fetchSalesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getSalesByDateRange(startDate, endDate);
  }

  Future<String> getNextInvoiceNumber() async {
    return await _apiDataService.getNextInvoiceNumber();
  }

  Future<double> getTotalSalesForDate(DateTime date) async {
    return await _apiDataService.getTotalSalesForDate(date);
  }

  Future<double> getTotalSalesForDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getTotalSalesForDateRange(startDate, endDate);
  }

  Future<Map<String, dynamic>> getSalesStatistics() async {
    return await _apiDataService.getSalesStatistics();
  }

  // ========== EXPENSES ==========
  Future<List<Expense>> fetchExpenses() async {
    return await _apiDataService.getExpenses();
  }

  Future<List<Expense>> fetchExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getExpensesByDateRange(startDate, endDate);
  }

  Future<Expense> createExpense(String title, String description, double amount, DateTime date, int categoryId) async {
    return await _apiDataService.createExpense(title, description, amount, date, categoryId);
  }

  Future<Expense> updateExpense(Expense expense) async {
    return await _apiDataService.updateExpense(expense);
  }

  Future<void> deleteExpense(int id) async {
    await _apiDataService.deleteExpense(id);
  }

  Future<double> getTotalExpensesForDate(DateTime date) async {
    return await _apiDataService.getTotalExpensesForDate(date);
  }

  Future<double> getTotalExpensesForDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getTotalExpensesForDateRange(startDate, endDate);
  }

  // ========== EXPENSE CATEGORIES ==========
  Future<List<ExpensesCategory>> fetchExpenseCategories() async {
    return await _apiDataService.getExpenseCategories();
  }

  Future<ExpensesCategory> createExpenseCategory(String name) async {
    return await _apiDataService.createExpenseCategory(name);
  }

  Future<ExpensesCategory> updateExpenseCategory(int id, String name) async {
    return await _apiDataService.updateExpenseCategory(id, name);
  }

  Future<void> deleteExpenseCategory(int id) async {
    await _apiDataService.deleteExpenseCategory(id);
  }

  // ========== SETTINGS ==========
  Future<Restaurant> getRestaurantSettings() async {
    return await _apiDataService.getRestaurantSettings();
  }

  Future<Restaurant> updateRestaurantSettings(Restaurant restaurant) async {
    return await _apiDataService.updateRestaurantSettings(restaurant);
  }

  Future<SystemSettings> getSystemSettings() async {
    return await _apiDataService.getSystemSettings();
  }

  Future<SystemSettings> updateSystemSettings(SystemSettings settings) async {
    return await _apiDataService.updateSystemSettings(settings);
  }

  Future<BillSettings> getBillSettings() async {
    return await _apiDataService.getBillSettings();
  }

  Future<BillSettings> updateBillSettings(BillSettings settings) async {
    return await _apiDataService.updateBillSettings(settings);
  }
}
