import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../models/models.dart';

class ApiDataService {
  final ApiService _apiService = ApiService();

  // ========== AUTHENTICATION ==========
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(Endpoints.login, {
      'username': username,
      'password': password,
    });
    
    if (response['token'] != null) {
      ApiService.setAuthToken(response['token']);
    }
    
    return response;
  }

  Future<void> logout() async {
    await _apiService.get(Endpoints.logout, requiresAuth: true);
    ApiService.clearAuthToken();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiService.get(Endpoints.profile, requiresAuth: true);
  }

  // ========== SETTINGS ==========
  
  Future<Restaurant> getRestaurantSettings() async {
    final response = await _apiService.get(Endpoints.restaurantSettings, requiresAuth: true);
    final restaurantData = response['data'] ?? response;
    return Restaurant.fromMap(restaurantData);
  }

  Future<Restaurant> updateRestaurantSettings(Restaurant restaurant) async {
    final response = await _apiService.put(
      Endpoints.restaurantSettings, 
      restaurant.toMap(), 
      requiresAuth: true,
    );
    final restaurantData = response['data'] ?? response;
    return Restaurant.fromMap(restaurantData);
  }

  Future<SystemSettings> getSystemSettings() async {
    final response = await _apiService.get(Endpoints.systemSettings, requiresAuth: true);
    final settingsData = response['data'] ?? response;
    return SystemSettings.fromMap(settingsData);
  }

  Future<SystemSettings> updateSystemSettings(SystemSettings settings) async {
    final response = await _apiService.put(
      Endpoints.systemSettings, 
      settings.toMap(), 
      requiresAuth: true,
    );
    final settingsData = response['data'] ?? response;
    return SystemSettings.fromMap(settingsData);
  }

  Future<BillSettings> getBillSettings() async {
    final response = await _apiService.get(Endpoints.billSettings, requiresAuth: true);
    final settingsData = response['data'] ?? response;
    return BillSettings.fromMap(settingsData);
  }

  Future<BillSettings> updateBillSettings(BillSettings settings) async {
    final response = await _apiService.put(
      Endpoints.billSettings, 
      settings.toMap(), 
      requiresAuth: true,
    );
    final settingsData = response['data'] ?? response;
    return BillSettings.fromMap(settingsData);
  }

  // ========== TABLES ==========
  
  Future<List<Table>> getTables() async {
    final response = await _apiService.get(Endpoints.tables, requiresAuth: false);
    final data = response['data'] as List? ?? [];
    return data.map((item) => Table(
      id: item['id'],
      name: item['name'] ?? '',
      status: (item['status'] as String?) ?? 'available',
    )).toList();
  }

  Future<Table> getTableById(int id) async {
    final response = await _apiService.get('${Endpoints.tableById}/$id', requiresAuth: true);
    
    // Handle the wrapped response from server
    final tableData = response['data'] ?? response;
    return Table(
      id: tableData['id'], 
      name: tableData['name'] ?? '',
      status: (tableData['status'] as String?) ?? 'available',
    );
  }

  Future<Table> createTable(String name, {String status = 'available'}) async {
    final response = await _apiService.post(
      Endpoints.tables, 
      {
        'name': name,
        'status': status,
      }, 
      requiresAuth: true,
    );
    
    // Handle the wrapped response from server
    final tableData = response['data'] ?? response;
    return Table(
      id: tableData['id'], 
      name: tableData['name'] ?? name,
      status: (tableData['status'] as String?) ?? status,
    );
  }

  Future<Table> updateTable(int id, String name, {String? status}) async {
    final data = {'name': name};
    if (status != null) {
      data['status'] = status;
    }
    
    print('Updating table $id with data: $data');
    final response = await _apiService.put(
      '${Endpoints.tableById}/$id', 
      data, 
      requiresAuth: true,
    );
    print('Update table response: $response');
    
    // Handle the wrapped response from server
    final tableData = response['data'] ?? response;
    return Table(
      id: tableData['id'] ?? id, 
      name: tableData['name'] ?? name,
      status: (tableData['status'] as String?) ?? 'available',
    );
  }

  Future<void> deleteTable(int id) async {
    await _apiService.delete('${Endpoints.tableById}/$id', requiresAuth: true);
  }

  // ========== MENU CATEGORIES ==========
  
  Future<List<Category>> getMenuCategories() async {
    final response = await _apiService.get(Endpoints.menuCategories, requiresAuth: false);
    final data = response['data'] as List? ?? [];
    return data.map((item) => Category(
      id: item['id'],
      name: item['name'],
    )).toList();
  }

  Future<Category> getMenuCategoryById(int id) async {
    final response = await _apiService.get('${Endpoints.menuCategoryById}/$id', requiresAuth: true);
    final categoryData = response['data'] ?? response;
    return Category(id: categoryData['id'], name: categoryData['name']);
  }

  Future<Category> createMenuCategory(String name) async {
    final response = await _apiService.post(
      Endpoints.menuCategories, 
      {'name': name}, 
      requiresAuth: true,
    );
    final categoryData = response['data'] ?? response;
    return Category(id: categoryData['id'], name: categoryData['name']);
  }

  Future<Category> updateMenuCategory(int id, String name) async {
    final response = await _apiService.put(
      '${Endpoints.menuCategoryById}/$id', 
      {'name': name}, 
      requiresAuth: true,
    );
    final categoryData = response['data'] ?? response;
    return Category(id: categoryData['id'], name: categoryData['name']);
  }

  Future<void> deleteMenuCategory(int id) async {
    await _apiService.delete('${Endpoints.menuCategoryById}/$id', requiresAuth: true);
  }

  // ========== MENU ITEMS ==========
  
  Future<List<Item>> getMenuItems() async {
    final response = await _apiService.get(Endpoints.menuItems, requiresAuth: false);
    final data = response['data'] as List? ?? [];
    return data.map((item) => Item(
      id: item['id'],
      categoryId: item['categoryId'],
      itemName: item['itemName'],
      rate: (item['rate']).toDouble(),
      image: item['image'],
    )).toList();
  }

  Future<List<Item>> getMenuItemsByCategory(int categoryId) async {
    final response = await _apiService.get(
      '${Endpoints.menuItemsByCategory}/$categoryId/items', 
      requiresAuth: false,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => Item(
      id: item['id'],
      categoryId: item['categoryId'],
      itemName: item['itemName'],
      rate: (item['rate']).toDouble(),
      image: item['image'],
    )).toList();
  }

  Future<Item> getMenuItemById(int id) async {
    final response = await _apiService.get('${Endpoints.menuItemById}/$id', requiresAuth: true);
    final itemData = response['data'] ?? response;
    return Item(
      id: itemData['id'],
      categoryId: itemData['category_id'] ?? itemData['categoryId'],
      itemName: itemData['name'] ?? itemData['item_name'] ?? itemData['itemName'],
      rate: (itemData['price'] ?? itemData['rate']).toDouble(),
      image: itemData['image'],
    );
  }

  Future<Item> createMenuItem(int categoryId, String itemName, double rate, {String? image}) async {
    final response = await _apiService.post(
      Endpoints.menuItems, 
      {
        'category_id': categoryId,
        'name': itemName,
        'price': rate,
        if (image != null) 'image': image,
      }, 
      requiresAuth: true,
    );
    final itemData = response['data'] ?? response;
    return Item(
      id: itemData['id'],
      categoryId: itemData['category_id'] ?? itemData['categoryId'],
      itemName: itemData['name'] ?? itemData['item_name'] ?? itemData['itemName'],
      rate: (itemData['price'] ?? itemData['rate']).toDouble(),
      image: itemData['image'],
    );
  }

  Future<Item> updateMenuItem(int id, int categoryId, String itemName, double rate, {String? image}) async {
    final response = await _apiService.put(
      '${Endpoints.menuItemById}/$id', 
      {
        'category_id': categoryId,
        'name': itemName,
        'price': rate,
        if (image != null) 'image': image,
      }, 
      requiresAuth: true,
    );
    final itemData = response['data'] ?? response;
    return Item(
      id: itemData['id'],
      categoryId: itemData['category_id'] ?? itemData['categoryId'],
      itemName: itemData['name'] ?? itemData['item_name'] ?? itemData['itemName'],
      rate: (itemData['price'] ?? itemData['rate']).toDouble(),
      image: itemData['image'],
    );
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiService.delete('${Endpoints.menuItemById}/$id', requiresAuth: true);
  }

  // ========== SALES ==========
  
  Future<List<Sales>> getSales() async {
    final response = await _apiService.get(Endpoints.sales, requiresAuth: true);
    final data = response['data'] ?? response;
    return (data as List).map((item) => _mapSalesResponse(item)).toList();
  }

  Future<Sales> getSalesById(int id) async {
    final response = await _apiService.get('${Endpoints.salesById}/$id', requiresAuth: true);
    final salesData = response['data'] ?? response;
    return _mapSalesResponse(salesData);
  }

  Future<List<Sales>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    final queryParams = '?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}';
    final response = await _apiService.get('${Endpoints.sales}$queryParams', requiresAuth: true);
    final data = response['data'] ?? response;
    return (data as List).map((item) => _mapSalesResponse(item)).toList();
  }

  Future<Sales> createSale(Sales sale) async {
    final response = await _apiService.post(
      Endpoints.sales, 
      _mapSalesToRequest(sale), 
      requiresAuth: true,
    );
    final salesData = response['data'] ?? response;
    return _mapSalesResponse(salesData);
  }

  Future<Sales> updateSale(int id, Sales sale) async {
    final response = await _apiService.put(
      '${Endpoints.salesById}/$id', 
      _mapSalesToRequest(sale), 
      requiresAuth: true,
    );
    final salesData = response['data'] ?? response;
    return _mapSalesResponse(salesData);
  }

  Future<void> deleteSale(int id) async {
    await _apiService.delete('${Endpoints.salesById}/$id', requiresAuth: true);
  }

  // Helper method to map sales response from API
  Sales _mapSalesResponse(Map<String, dynamic> response) {
    return Sales(
      invoiceNo: response['invoice_number'] ?? response['invoiceNo'] ?? '',
      table: response['table_name'] ?? response['table'] ?? '',
      orderType: response['order_type'] ?? response['orderType'] ?? 'Dine In',
      items: (response['items'] as List? ?? []).map((item) => CartItem(
        item: {
          'id': item['menu_item_id'] ?? item['id'],
          'itemName': item['item_name'] ?? item['name'],
          'rate': (item['unit_price'] ?? item['rate'] ?? 0).toDouble(),
        },
        quantity: item['quantity'] ?? 1,
      )).toList(),
      subtotal: (response['subtotal'] ?? 0).toDouble(),
      tax: (response['tax_amount'] ?? response['tax'] ?? 0).toDouble(),
      taxRate: (response['tax_rate'] ?? response['taxRate'] ?? 0).toDouble(),
      discount: (response['discount_amount'] ?? response['discount'] ?? 0).toDouble(),
      discountValue: (response['discount_value'] ?? response['discountValue'] ?? 0).toDouble(),
      isDiscountPercentage: response['discount_type'] == 'percentage' || response['isDiscountPercentage'] == true,
      total: (response['total_amount'] ?? response['total'] ?? 0).toDouble(),
      timestamp: DateTime.parse(response['created_at'] ?? response['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Helper method to map sales to API request format
  Map<String, dynamic> _mapSalesToRequest(Sales sale) {
    return {
      'invoice_number': sale.invoiceNo,
      'table_name': sale.table,
      'order_type': sale.orderType,
      'subtotal': sale.subtotal,
      'tax_amount': sale.tax,
      'tax_rate': sale.taxRate,
      'discount_amount': sale.discount,
      'discount_value': sale.discountValue,
      'discount_type': sale.isDiscountPercentage ? 'percentage' : 'amount',
      'total_amount': sale.total,
      'items': sale.items.map((item) => {
        'menu_item_id': item.item['id'],
        'quantity': item.quantity,
        'unit_price': item.item['rate'],
      }).toList(),
    };
  }

  // ========== EXPENSES ==========
  
  Future<List<Expense>> getExpenses() async {
    final response = await _apiService.get(Endpoints.expenses, requiresAuth: true);
    final data = response['data'] ?? response;
    return (data as List).map((item) => Expense.fromMap(item)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final queryParams = '?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}';
    final response = await _apiService.get('${Endpoints.expensesByDateRange}$queryParams', requiresAuth: true);
    final data = response['data'] ?? response;
    return (data as List).map((item) => Expense.fromMap(item)).toList();
  }

  Future<Expense> createExpense(String title, String description, double amount, DateTime date, int categoryId) async {
    final response = await _apiService.post(
      Endpoints.expenses, 
      {
        'title': title,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'category_id': categoryId,
      }, 
      requiresAuth: true,
    );
    final expenseData = response['data'] ?? response;
    return Expense.fromMap(expenseData);
  }

  Future<Expense> updateExpense(Expense expense) async {
    final response = await _apiService.put(
      '${Endpoints.expenseById}/${expense.id}', 
      expense.toMap(), 
      requiresAuth: true,
    );
    final expenseData = response['data'] ?? response;
    return Expense.fromMap(expenseData);
  }

  Future<void> deleteExpense(int id) async {
    await _apiService.delete('${Endpoints.expenseById}/$id', requiresAuth: true);
  }

  // ========== EXPENSE CATEGORIES ==========
  
  Future<List<ExpensesCategory>> getExpenseCategories() async {
    final response = await _apiService.get(Endpoints.expenseCategories, requiresAuth: true);
    final data = response['data'] ?? response;
    return (data as List).map((item) => ExpensesCategory.fromMap(item)).toList();
  }

  Future<ExpensesCategory> createExpenseCategory(String name) async {
    final response = await _apiService.post(
      Endpoints.expenseCategories, 
      {'name': name}, 
      requiresAuth: true,
    );
    final categoryData = response['data'] ?? response;
    return ExpensesCategory.fromMap(categoryData);
  }

  Future<ExpensesCategory> updateExpenseCategory(int id, String name) async {
    final response = await _apiService.put(
      '${Endpoints.expenseCategoryById}/$id', 
      {'name': name}, 
      requiresAuth: true,
    );
    final categoryData = response['data'] ?? response;
    return ExpensesCategory.fromMap(categoryData);
  }

  Future<void> deleteExpenseCategory(int id) async {
    await _apiService.delete('${Endpoints.expenseCategoryById}/$id', requiresAuth: true);
  }

  // ========== UTILITY METHODS ==========

  Future<String> getNextInvoiceNumber() async {
    final sales = await getSales();
    if (sales.isEmpty) {
      return 'INV-0001';
    }
    
    // Extract numeric part from last invoice and increment
    final lastInvoice = sales.last.invoiceNo;
    final numericPart = int.tryParse(lastInvoice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final nextNumber = (numericPart + 1).toString().padLeft(4, '0');
    return 'INV-$nextNumber';
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

  Future<double> getTotalExpensesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final expenses = await getExpensesByDateRange(startOfDay, endOfDay);
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  Future<double> getTotalExpensesForDateRange(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }
}
