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

  Future<Category> getCategoryById(int id) async {
    return await _apiDataService.getMenuCategoryById(id);
  }

  Future<Category> createCategory(String name, {String? description}) async {
    return await _apiDataService.createMenuCategory(name, description: description);
  }

  Future<Category> updateCategory(int id, String name, {String? description}) async {
    return await _apiDataService.updateMenuCategory(id, name, description: description);
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

  Future<Item> getItemById(int id) async {
    return await _apiDataService.getMenuItemById(id);
  }

  Future<Item> createItem(int categoryId, String itemName, double rate, {String? description, String? image}) async {
    return await _apiDataService.createMenuItem(categoryId, itemName, rate, description: description, image: image);
  }

  Future<Item> updateItem(int id, int categoryId, String itemName, double rate, {String? description, String? image}) async {
    return await _apiDataService.updateMenuItem(id, categoryId, itemName, rate, description: description, image: image);
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

  Future<Sales> getSalesById(int id) async {
    return await _apiDataService.getSalesById(id);
  }

  Future<Sales> createSale(Sales sale) async {
    return await _apiDataService.createSale(sale);
  }

  Future<Sales> updateSale(int id, Sales sale) async {
    return await _apiDataService.updateSale(id, sale);
  }

  Future<void> deleteSale(int id) async {
    await _apiDataService.deleteSale(id);
  }

  Future<List<Sales>> fetchSalesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getSalesByDateRange(startDate, endDate);
  }

  Future<List<Sales>> fetchSalesByOrderStatus(String status) async {
    return await _apiDataService.getSalesByOrderStatus(status);
  }

  Future<List<Sales>> fetchSalesByPaymentStatus(String status) async {
    return await _apiDataService.getSalesByPaymentStatus(status);
  }

  Future<List<Sales>> fetchSalesByTable(int tableId) async {
    return await _apiDataService.getSalesByTable(tableId);
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

  // ========== REPORTS ==========
  Future<Map<String, dynamic>> getSalesAnalytics(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getSalesAnalytics(startDate, endDate);
  }

  // ========== PAYMENT METHODS ==========
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    return await _apiDataService.getPaymentMethods();
  }

  Future<List<PaymentMethod>> fetchActivePaymentMethods() async {
    return await _apiDataService.getActivePaymentMethods();
  }

  // ========== EXPENSES ==========
  Future<List<Expense>> fetchExpenses() async {
    return await _apiDataService.getExpenses();
  }

  Future<List<Expense>> fetchExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _apiDataService.getExpensesByDateRange(startDate, endDate);
  }

  Future<List<Expense>> fetchExpensesByCategory(int categoryId) async {
    return await _apiDataService.getExpensesByCategory(categoryId);
  }

  Future<List<Expense>> fetchExpensesByParty(int partyId) async {
    return await _apiDataService.getExpensesByParty(partyId);
  }

  Future<List<Expense>> fetchApprovedExpenses() async {
    return await _apiDataService.getApprovedExpenses();
  }

  Future<List<Expense>> fetchPendingExpenses() async {
    return await _apiDataService.getPendingExpenses();
  }

  Future<Expense> createExpense({
    required String title,
    String? description,
    required double amount,
    required int paymentMethodId,
    required DateTime date,
    required int categoryId,
    int? partyId,
    String? receipt,
    required int createdBy,
  }) async {
    return await _apiDataService.createExpense(
      title: title,
      description: description,
      amount: amount,
      paymentMethodId: paymentMethodId,
      date: date,
      categoryId: categoryId,
      partyId: partyId,
      receipt: receipt,
      createdBy: createdBy,
    );
  }

  Future<Expense> updateExpense(int id, Map<String, dynamic> expenseData) async {
    return await _apiDataService.updateExpense(id, expenseData);
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

  Future<ExpensesCategory> createExpenseCategoryWithDescription({
    required String name,
    String? description,
  }) async {
    return await _apiDataService.createExpenseCategoryWithDescription(
      name: name,
      description: description,
    );
  }

  Future<ExpensesCategory> updateExpenseCategory(int id, String name) async {
    return await _apiDataService.updateExpenseCategory(id, name);
  }

  Future<void> deleteExpenseCategory(int id) async {
    await _apiDataService.deleteExpenseCategory(id);
  }

  Future<List<ExpensesCategory>> fetchActiveExpenseCategories() async {
    return await _apiDataService.getActiveExpenseCategories();
  }

  // ========== CARTS ==========
  Future<Map<String, dynamic>> getCartByTable(int tableId) async {
    return await _apiDataService.getCartByTable(tableId);
  }

  Future<Map<String, dynamic>> createCart(int tableId) async {
    return await _apiDataService.createCart(tableId);
  }

  Future<void> addItemToCart(int cartId, int itemId, int quantity, double rate) async {
    await _apiDataService.addItemToCart(cartId, itemId, quantity, rate);
  }

  Future<void> updateCartItem(int cartItemId, int quantity, double rate) async {
    await _apiDataService.updateCartItem(cartItemId, quantity, rate);
  }

  Future<void> removeCartItem(int cartItemId) async {
    await _apiDataService.removeCartItem(cartItemId);
  }

  Future<List<Map<String, dynamic>>> getCartItems(int cartId) async {
    return await _apiDataService.getCartItems(cartId);
  }

  Future<void> clearCartItems(int cartId) async {
    await _apiDataService.clearCartItems(cartId);
  }

  Future<Map<String, dynamic>> checkout(int cartId, Map<String, dynamic> orderData) async {
    return await _apiDataService.checkout(cartId, orderData);
  }

  // ========== PARTIES ==========
  Future<List<Party>> fetchParties() async {
    return await _apiDataService.getParties();
  }

  Future<List<Party>> fetchActiveParties() async {
    return await _apiDataService.getActiveParties();
  }

  Future<List<Party>> fetchCustomers() async {
    return await _apiDataService.getCustomers();
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
