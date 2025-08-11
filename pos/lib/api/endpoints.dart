class Endpoints {
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/profile';

  static const String restaurantSettings = '/api/settings/restaurant';
  static const String systemSettings = '/api/settings/system';
  static const String billSettings = '/api/settings/bill';

  static const String tables = '/api/tables';
  static const String tableById = '/api/tables';

  static const String menuCategories = '/api/menu/categories';
  static const String menuCategoryById = '/api/menu/categories';

  static const String menuItems = '/api/menu/items';
  static const String menuItemById = '/api/menu/items';
  static const String menuItemsByCategory = '/api/menu/categories';

  static const String inventoryItems = '/api/inventory/items';
  static const String inventoryItemById = '/api/inventory/items';
  static const String lowStockItems = '/api/inventory/items/low-stock';
  static const String stockMovements = '/api/inventory/movements';
  static const String stockMovementsByItem = '/api/inventory/items';

  static const String parties = '/api/parties';
  static const String partyById = '/api/parties';
  static const String partiesByType = '/api/parties/type';
  static const String activeParties = '/api/parties/active/all';
  static const String partyTransactions = '/api/parties/transactions';
  static const String partyTransactionById = '/api/parties/transactions';
  static const String transactionsByParty = '/api/parties';
  static const String transactionsByType = '/api/parties/transactions/type';

  static const String users = '/api/users';
  static const String userById = '/api/users';
  static const String usersByRole = '/api/users/role';
  static const String activeUsers = '/api/users/status/active';
  static const String userByUsername = '/api/users/username';
  static const String changePassword = '/api/users';
  static const String toggleUserStatus = '/api/users';

  static const String userSessions = '/api/user-sessions';
  static const String userSessionById = '/api/user-sessions';
  static const String sessionsByUser = '/api/user-sessions/user';
  static const String activeSessions = '/api/user-sessions/status/active';
  static const String activeSessionsByUser = '/api/user-sessions/user';
  static const String sessionsByDateRange = '/api/user-sessions/date-range';
  static const String endSession = '/api/user-sessions';
  static const String endAllUserSessions = '/api/user-sessions/user';

  static const String carts = '/api/cart';
  static const String cartById = '/api/cart';
  static const String cartsByStatus = '/api/cart/status';
  static const String cartsByTable = '/api/cart/table';
  static const String clearCart = '/api/cart';

  static const String cartItems = '/api/cart/items';
  static const String cartItemById = '/api/cart/items';
  static const String itemsByCart = '/api/cart';

  static const String sales = '/api/sales';
  static const String salesById = '/api/sales';
  static const String salesByOrderStatus = '/api/sales/order-status';
  static const String salesByPaymentStatus = '/api/sales/payment-status';
  static const String salesByTable = '/api/sales/table';
  static const String salesByParty = '/api/sales/party';
  static const String nextInvoiceNumber = '/api/sales/next-invoice-number';

  static const String salesItems = '/api/sales-items';
  static const String salesItemById = '/api/sales-items';
  static const String salesItemsBySales = '/api/sales-items/sales';
  static const String salesItemsByMenuItem = '/api/sales-items/menu-item';
  static const String deleteAllSalesItems = '/api/sales-items/sales';

  static const String expenses = '/api/expenses';
  static const String expenseById = '/api/expenses';
  static const String expensesByCategory = '/api/expenses/category';
  static const String expensesByParty = '/api/expenses/party';
  static const String expensesByCreator = '/api/expenses/creator';
  static const String expensesByDateRange = '/api/expenses/date-range';
  static const String approvedExpenses = '/api/expenses/approved/all';
  static const String pendingExpenses = '/api/expenses/pending/all';

  static const String expenseCategories = '/api/expense-categories';
  static const String expenseCategoryById = '/api/expense-categories';
  static const String activeExpenseCategories =
      '/api/expense-categories/active/all';

  static const String paymentMethods = '/api/payment-methods';
  static const String paymentMethodById = '/api/payment-methods';
  static const String activePaymentMethods = '/api/payment-methods/active/all';

  static const String reports = '/api/reports';

  // Daybook endpoints
  static const String daybookTodaysSummary = '/api/daybook/today-summary';
  static const String daybookEntries = '/api/daybook/entries';
  static const String daybookSummary = '/api/daybook/summary';
  static const String daybookByDate = '/api/daybook/date';
}
