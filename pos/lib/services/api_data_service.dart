import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../models/models.dart';

class ApiDataService {
  final ApiService _apiService = ApiService();

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

  Future<Restaurant> getRestaurantSettings() async {
    final response = await _apiService.get(
      Endpoints.restaurantSettings,
      requiresAuth: true,
    );
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
    final response = await _apiService.get(
      Endpoints.systemSettings,
      requiresAuth: true,
    );
    final settingsData = response['data'] ?? response;
    return SystemSettings.fromMap(settingsData);
  }

  Future<SystemSettings> updateSystemSettings(SystemSettings settings) async {
    final response = await _apiService.put(
      Endpoints.systemSettings,
      settings.toJson(),
      requiresAuth: true,
    );
    final settingsData = response['data'] ?? response;
    return SystemSettings.fromMap(settingsData);
  }

  Future<BillSettings> getBillSettings() async {
    final response = await _apiService.get(
      Endpoints.billSettings,
      requiresAuth: true,
    );
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

  Future<List<Table>> getTables() async {
    final response = await _apiService.get(
      Endpoints.tables,
      requiresAuth: false,
    );
    final data = response['data'] as List? ?? [];
    return data
        .map(
          (item) => Table(
            id: item['id'],
            name: item['name'] ?? '',
            status: (item['status'] as String?) ?? 'available',
          ),
        )
        .toList();
  }

  Future<Table> getTableById(int id) async {
    final response = await _apiService.get(
      '${Endpoints.tableById}/$id',
      requiresAuth: true,
    );

    final tableData = response['data'] ?? response;
    return Table(
      id: tableData['id'],
      name: tableData['name'] ?? '',
      status: (tableData['status'] as String?) ?? 'available',
    );
  }

  Future<Table> createTable(String name, {String status = 'available'}) async {
    final response = await _apiService.post(Endpoints.tables, {
      'name': name,
      'status': status,
    }, requiresAuth: true);

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

  Future<List<Category>> getMenuCategories() async {
    final response = await _apiService.get(
      Endpoints.menuCategories,
      requiresAuth: false,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => Category.fromJson(item)).toList();
  }

  Future<Category> getMenuCategoryById(int id) async {
    final response = await _apiService.get(
      '${Endpoints.menuCategoryById}/$id',
      requiresAuth: false,
    );
    final categoryData = response['data'] ?? response;
    return Category.fromJson(categoryData);
  }

  Future<Category> createMenuCategory(
    String name, {
    String? description,
  }) async {
    final response = await _apiService.post(Endpoints.menuCategories, {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    }, requiresAuth: true);
    final categoryData = response['data'] ?? response;
    return Category.fromJson(categoryData);
  }

  Future<Category> updateMenuCategory(
    int id,
    String name, {
    String? description,
  }) async {
    final response = await _apiService
        .put('${Endpoints.menuCategoryById}/$id', {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        }, requiresAuth: true);
    final categoryData = response['data'] ?? response;
    return Category.fromJson(categoryData);
  }

  Future<void> deleteMenuCategory(int id) async {
    await _apiService.delete(
      '${Endpoints.menuCategoryById}/$id',
      requiresAuth: true,
    );
  }

  Future<List<Item>> getMenuItems() async {
    final response = await _apiService.get(
      Endpoints.menuItems,
      requiresAuth: false,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => Item.fromJson(item)).toList();
  }

  Future<List<Item>> getMenuItemsByCategory(int categoryId) async {
    final response = await _apiService.get(
      '${Endpoints.menuItemsByCategory}/$categoryId/items',
      requiresAuth: false,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => Item.fromJson(item)).toList();
  }

  Future<Item> getMenuItemById(int id) async {
    final response = await _apiService.get(
      '${Endpoints.menuItemById}/$id',
      requiresAuth: false,
    );
    final itemData = response['data'] ?? response;
    return Item.fromJson(itemData);
  }

  Future<Item> createMenuItem(
    int categoryId,
    String itemName,
    double rate, {
    String? description,
    String? image,
  }) async {
    final response = await _apiService.post(Endpoints.menuItems, {
      'categoryId': categoryId,
      'itemName': itemName,
      'rate': rate,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (image != null) 'image': image,
    }, requiresAuth: true);
    final itemData = response['data'] ?? response;
    return Item.fromJson(itemData);
  }

  Future<Item> updateMenuItem(
    int id,
    int categoryId,
    String itemName,
    double rate, {
    String? description,
    String? image,
  }) async {
    final response = await _apiService.put('${Endpoints.menuItemById}/$id', {
      'categoryId': categoryId,
      'itemName': itemName,
      'rate': rate,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (image != null) 'image': image,
    }, requiresAuth: true);
    final itemData = response['data'] ?? response;
    return Item.fromJson(itemData);
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiService.delete(
      '${Endpoints.menuItemById}/$id',
      requiresAuth: true,
    );
  }

  Future<List<Sales>> getSales() async {
    final response = await _apiService.get(Endpoints.sales, requiresAuth: true);
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => Sales.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Sales> getSalesById(int id) async {
    final response = await _apiService.get(
      '${Endpoints.salesById}/$id',
      requiresAuth: true,
    );
    final salesData = response['data'] ?? response;
    return Sales.fromJson(salesData as Map<String, dynamic>);
  }

  Future<List<Sales>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.reports}/sales?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
        requiresAuth: true,
      );
      final data = response['data'] ?? response;

      if (data is List) {
        return data
            .map((item) => Sales.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching sales by date range: $e');

      final sales = await getSales();
      return sales.where((sale) {
        return sale.timestamp.isAfter(
              startDate.subtract(const Duration(seconds: 1)),
            ) &&
            sale.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    }
  }

  Future<List<Sales>> getSalesByOrderStatus(String status) async {
    final response = await _apiService.get(
      '${Endpoints.salesByOrderStatus}/$status',
      requiresAuth: true,
    );
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => Sales.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Sales>> getSalesByPaymentStatus(String status) async {
    final response = await _apiService.get(
      '${Endpoints.salesByPaymentStatus}/$status',
      requiresAuth: true,
    );
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => Sales.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Sales>> getSalesByTable(int tableId) async {
    final response = await _apiService.get(
      '${Endpoints.salesByTable}/$tableId',
      requiresAuth: true,
    );
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => Sales.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Sales> createSale(Sales sale) async {
    String orderType = sale.orderType.toLowerCase();
    if (orderType == 'dine_in') orderType = 'dine-in';

    final requestData = {
      'tableId': sale.tableId,
      'orderType': orderType,
      'orderStatus': sale.orderStatus,
      'paymentStatus': sale.paymentStatus,
      'paymentMethodId': sale.paymentMethodId,
      'subTotal': sale.subtotal,
      'tax': sale.tax,
      'total': sale.total,
      'partyId': sale.partyId,
      'createdBy': sale.createdBy ?? 1,
      'signedBy': sale.signedBy ?? 1,
    };

    print('=== CREATE SALE REQUEST (FLUTTER) ===');
    print('Request data: ${requestData.toString()}');
    print('Endpoint: ${Endpoints.sales}');

    final response = await _apiService.post(
      Endpoints.sales,
      requestData,
      requiresAuth: false,
    );
    final salesData = response['data'] ?? response;
    final createdSale = Sales.fromJson(salesData as Map<String, dynamic>);

    if (sale.items.isNotEmpty) {
      await _createSalesItems(createdSale.id!, sale.items);
    }

    return createdSale;
  }

  Future<void> _createSalesItems(int salesId, List<dynamic> items) async {
    for (var item in items) {
      Map<String, dynamic> salesItemData;

      if (item is CartItem) {
        salesItemData = {
          'salesId': salesId,
          'itemId': item.item['id'],
          'itemName': item.item['item_name'] ?? item.item['itemName'],
          'quantity': item.quantity,
          'rate': item.item['rate'],
          'totalPrice': item.totalPrice,
        };
      } else if (item is Map<String, dynamic>) {
        salesItemData = {
          'salesId': salesId,
          'itemId': item['item']['id'],
          'itemName': item['item']['item_name'] ?? item['item']['itemName'],
          'quantity': item['quantity'],
          'rate': item['item']['rate'],
          'totalPrice': item['totalPrice'],
        };
      } else {
        continue;
      }

      print('=== CREATE SALES ITEM REQUEST (FLUTTER) ===');
      print('Sales Item data: ${salesItemData.toString()}');

      try {
        await _apiService.post(
          Endpoints.salesItems,
          salesItemData,
          requiresAuth: false,
        );
      } catch (e) {
        print('Error creating sales item: $e');
      }
    }
  }

  Future<Sales> updateSale(int id, Sales sale) async {
    final requestData = {
      'tableId': sale.tableId,
      'orderType': sale.orderType,
      'orderStatus': sale.orderStatus,
      'paymentStatus': sale.paymentStatus,
      'paymentMethodId': sale.paymentMethodId,
      'subTotal': sale.subtotal,
      'tax': sale.tax,
      'total': sale.total,
      'partyId': sale.partyId,
      'signedBy': sale.signedBy,
    };

    final response = await _apiService.put(
      '${Endpoints.salesById}/$id',
      requestData,
      requiresAuth: true,
    );
    final salesData = response['data'] ?? response;
    return Sales.fromJson(salesData as Map<String, dynamic>);
  }

  Future<void> deleteSale(int id) async {
    await _apiService.delete('${Endpoints.salesById}/$id', requiresAuth: true);
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _apiService.get(
      Endpoints.paymentMethods,
      requiresAuth: false,
    );
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<PaymentMethod>> getActivePaymentMethods() async {
    final response = await _apiService.get(
      Endpoints.activePaymentMethods,
      requiresAuth: false,
    );
    final data = response['data'] ?? response;

    if (data is List) {
      return data
          .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _apiService.get(Endpoints.expenses);
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('400') ||
          errorString.contains('404') ||
          errorString.contains('no expenses found') ||
          errorString.contains('not found') ||
          errorString.contains('empty')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.reports}/expenses?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
        requiresAuth: true,
      );
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching expenses by date range: $e');

      try {
        final queryParams =
            '?startDate=${startDate.toIso8601String().split('T')[0]}&endDate=${endDate.toIso8601String().split('T')[0]}';
        final response = await _apiService.get(
          '${Endpoints.expensesByDateRange}$queryParams',
          requiresAuth: true,
        );
        final data = response['data'] ?? response;
        if (data is List) {
          return data.map((item) => Expense.fromMap(item)).toList();
        }
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
      }
      return [];
    }
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.expensesByCategory}/$categoryId',
        requiresAuth: true,
      );
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      if (e.toString().contains('400') ||
          e.toString().contains('No expenses found')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<Expense>> getExpensesByParty(int partyId) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.expensesByParty}/$partyId',
        requiresAuth: true,
      );
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      if (e.toString().contains('400') ||
          e.toString().contains('No expenses found')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<Expense>> getApprovedExpenses() async {
    try {
      final response = await _apiService.get(
        Endpoints.approvedExpenses,
        requiresAuth: true,
      );
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      if (e.toString().contains('400') ||
          e.toString().contains('No expenses found')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<Expense>> getPendingExpenses() async {
    try {
      final response = await _apiService.get(
        Endpoints.pendingExpenses,
        requiresAuth: true,
      );
      final data = response['data'] ?? response;
      if (data is List) {
        return data.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      if (e.toString().contains('400') ||
          e.toString().contains('No expenses found')) {
        return [];
      }
      rethrow;
    }
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
    final requestData = {
      'title': title,
      'description': description,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'partyId': partyId,
      'receipt': receipt,
      'createdBy': createdBy,
    };

    print('=== CREATE EXPENSE REQUEST (FLUTTER) ===');
    print('Request data: ${requestData.toString()}');
    print('Endpoint: ${Endpoints.expenses}');
    print('Timestamp: ${DateTime.now().toIso8601String()}');

    try {
      final response = await _apiService.post(
        Endpoints.expenses,
        requestData,
        requiresAuth: true,
      );
      print('Response received: ${response.toString()}');
      final expenseData = response['data'] ?? response;
      print('Parsed expense data: ${expenseData.toString()}');
      final expense = Expense.fromMap(expenseData);
      print('Created expense object: ${expense.toString()}');
      return expense;
    } catch (e) {
      print('Error creating expense: $e');
      rethrow;
    }
  }

  Future<Expense> updateExpense(
    int id,
    Map<String, dynamic> expenseData,
  ) async {
    final response = await _apiService.put(
      '${Endpoints.expenseById}/$id',
      expenseData,
      requiresAuth: true,
    );
    final data = response['data'] ?? response;
    return Expense.fromMap(data);
  }

  Future<void> deleteExpense(int id) async {
    await _apiService.delete(
      '${Endpoints.expenseById}/$id',
      requiresAuth: true,
    );
  }

  Future<List<Party>> getParties() async {
    final response = await _apiService.get(
      Endpoints.parties,
      requiresAuth: true,
    );
    final data = response['data'] ?? response;
    return (data as List).map((item) => Party.fromJson(item)).toList();
  }

  Future<List<Party>> getActiveParties() async {
    final response = await _apiService.get(
      Endpoints.activeParties,
      requiresAuth: false,
    );
    final data = response['data'] ?? response;
    return (data as List).map((item) => Party.fromJson(item)).toList();
  }

  Future<List<Party>> getCustomers() async {
    final response = await _apiService.get(
      '${Endpoints.partiesByType}/customer',
      requiresAuth: false,
    );
    final data = response['data'] ?? response;
    return (data as List).map((item) => Party.fromJson(item)).toList();
  }

  Future<List<ExpensesCategory>> getExpenseCategories() async {
    final response = await _apiService.get(
      Endpoints.expenseCategories,
      requiresAuth: false,
    );
    final data = response['data'] ?? response;
    return (data as List)
        .map((item) => ExpensesCategory.fromMap(item))
        .toList();
  }

  Future<ExpensesCategory> createExpenseCategory(String name) async {
    final response = await _apiService.post(Endpoints.expenseCategories, {
      'name': name,
    }, requiresAuth: true);
    final categoryData = response['data'] ?? response;
    return ExpensesCategory.fromMap(categoryData);
  }

  Future<ExpensesCategory> createExpenseCategoryWithDescription({
    required String name,
    String? description,
  }) async {
    final Map<String, dynamic> payload = {'name': name};
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }

    final response = await _apiService.post(
      Endpoints.expenseCategories,
      payload,
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
    await _apiService.delete(
      '${Endpoints.expenseCategoryById}/$id',
      requiresAuth: true,
    );
  }

  Future<List<ExpensesCategory>> getActiveExpenseCategories() async {
    final response = await _apiService.get(
      Endpoints.activeExpenseCategories,
      requiresAuth: true,
    );
    final data = response['data'] ?? response;
    return (data as List)
        .map((item) => ExpensesCategory.fromMap(item))
        .toList();
  }

  Future<double> getTotalExpensesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final expenses = await getExpensesByDateRange(startOfDay, endOfDay);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<double> getTotalExpensesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<String> getNextInvoiceNumber() async {
    try {
      final response = await _apiService.get(Endpoints.nextInvoiceNumber);

      if (response['success'] == true && response['data'] != null) {
        return response['data']['invoiceNumber'] ?? 'INV 001';
      } else {
        final sales = await getSales();
        final nextId = sales.isEmpty ? 1 : (sales.length + 1);
        return 'INV ${nextId.toString().padLeft(3, '0')}';
      }
    } catch (e) {
      try {
        final sales = await getSales();
        final nextId = sales.isEmpty ? 1 : (sales.length + 1);
        return 'INV ${nextId.toString().padLeft(3, '0')}';
      } catch (localError) {
        return 'INV 001';
      }
    }
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

  Future<Map<String, dynamic>> getCartByTable(int tableId) async {
    final response = await _apiService.get(
      '${Endpoints.cartsByTable}/$tableId',
      requiresAuth: true,
    );

    final data = response['data'] ?? response;

    if (data is List) {
      if (data.isEmpty) {
        return {};
      } else {
        return data.first as Map<String, dynamic>;
      }
    }

    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCart(int tableId) async {
    final response = await _apiService.post(Endpoints.carts, {
      'tableId': tableId,
      'userId': 1,
      'status': 'open',
    }, requiresAuth: true);
    return response['data'] ?? response;
  }

  Future<void> addItemToCart(
    int cartId,
    int itemId,
    int quantity,
    double rate,
  ) async {
    await _apiService.post(Endpoints.cartItems, {
      'cartId': cartId,
      'itemId': itemId,
      'quantity': quantity,
      'rate': rate,
      'totalPrice': quantity * rate,
    }, requiresAuth: true);
  }

  Future<void> updateCartItem(int cartItemId, int quantity, double rate) async {
    await _apiService.put('${Endpoints.cartItemById}/$cartItemId', {
      'quantity': quantity,
      'rate': rate,
      'totalPrice': quantity * rate,
    }, requiresAuth: true);
  }

  Future<void> removeCartItem(int cartItemId) async {
    await _apiService.delete(
      '${Endpoints.cartItemById}/$cartItemId',
      requiresAuth: true,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(int cartId) async {
    final response = await _apiService.get(
      '${Endpoints.itemsByCart}/$cartId/items',
      requiresAuth: true,
    );
    final data = response['data'] as List? ?? [];
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> clearCartItems(int cartId) async {
    await _apiService.delete(
      '${Endpoints.clearCart}/$cartId/clear',
      requiresAuth: true,
    );
  }

  Future<Map<String, dynamic>> checkout(
    int cartId,
    Map<String, dynamic> orderData,
  ) async {
    final response = await _apiService.post(
      '${Endpoints.sales}',
      orderData,
      requiresAuth: true,
    );

    await _apiService.put('${Endpoints.cartById}/$cartId', {
      'status': 'closed',
    }, requiresAuth: true);

    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> getSalesAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiService.get(
        '${Endpoints.reports}/analytics?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
        requiresAuth: true,
      );
      return response['data'] ?? response;
    } catch (e) {
      print('Error fetching sales analytics: $e');
      return {};
    }
  }
}
