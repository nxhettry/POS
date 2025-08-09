# Restaurant Management System - Backend Use Cases & Actions

## 1. AUTHENTICATION & USER MANAGEMENT

### Authentication

- **POST** `/api/auth/login` - User login with automatic session creation and 8-hour JWT token
  - Request: `{ "username": "string", "password": "string" }`
  - Response: User info, JWT tokens (8h expiry), and session details
  
- **POST** `/api/auth/logout` - User logout with automatic session cleanup
  - Requires: Bearer token in Authorization header
  - Response: Logout confirmation with ended sessions count
  
- **GET** `/api/auth/profile` - Get current user profile with session info
  - Requires: Bearer token in Authorization header
  - Response: User profile and active session details
  
- **POST** `/api/auth/refresh` - Refresh JWT token (placeholder)
  - Request: `{ "refreshToken": "string" }`

### User Management

- **GET** `/api/users` - List all users (admin only)
- **POST** `/api/users` - Create new user account
- **PUT** `/api/users/:id` - Update user profile
- **PUT** `/api/users/:id/status` - Activate/deactivate user
- **DELETE** `/api/users/:id` - Delete user account

### Session Management

- **GET** `/api/user-sessions/` - List all user sessions
- **GET** `/api/user-sessions/status/active` - List active sessions
- **GET** `/api/user-sessions/user/:userId/active` - Get active sessions for specific user
- **POST** `/api/user-sessions/` - Create user session (manual)
- **PATCH** `/api/user-sessions/:id/end` - Force end user session
- **PATCH** `/api/user-sessions/user/:userId/end-all` - End all sessions for user
- **DELETE** `/api/user-sessions/:id` - Delete user session record

## Authentication Flow

1. **Login**: `POST /api/auth/login`
   - Validates credentials
   - Creates JWT token (8-hour expiry)
   - Automatically creates user session record
   - Returns user info + tokens + session details

2. **Protected Routes**: Include `Authorization: Bearer <token>` header
   - Token is verified by authentication middleware
   - User info is attached to request object

3. **Logout**: `POST /api/auth/logout`
   - Requires valid Bearer token
   - Automatically ends all active sessions for the user
   - Invalidates the session (client should discard token)

## JWT Token Details

- **Access Token**: 8-hour expiry (`JWT_EXPIRES_IN=8h`)
- **Refresh Token**: 30-day expiry (`JWT_REFRESH_EXPIRES_IN=30d`)
- **Issuer**: `ratopos-api`
- **Audience**: `ratopos-client`

## 2. MENU MANAGEMENT

### Menu Categories

- **GET** `/api/menu/categories` - List all categories
- **POST** `/api/menu/categories` - Create new category
- **PUT** `/api/menu/categories/:id` - Update category
- **DELETE** `/api/menu/categories/:id` - Delete category
- **PUT** `/api/menu/categories/:id/toggle` - Toggle category active status

### Menu Items

- **GET** `/api/menu/items` - List all menu items (with filtering by category)
- **GET** `/api/menu/items/:id` - Get specific menu item
- **POST** `/api/menu/items` - Create new menu item
- **PUT** `/api/menu/items/:id` - Update menu item
- **DELETE** `/api/menu/items/:id` - Delete menu item
- **PUT** `/api/menu/items/:id/availability` - Toggle item availability
- **POST** `/api/menu/items/:id/image` - Upload item image

## 3. TABLE MANAGEMENT

### Table Operations

- **GET** `/api/tables` - List all tables
- **POST** `/api/tables` - Create new table
- **PUT** `/api/tables/:id` - Update table details
- **DELETE** `/api/tables/:id` - Delete table
- **PUT** `/api/tables/:id/status` - Update table status (available, occupied, reserved, cleaning)
- **GET** `/api/tables/status` - Get all table statuses

## 4. ORDERING SYSTEM

### Cart Management

- **POST** `/api/cart` - Create new cart for table/user
- **GET** `/api/cart/:tableId` - Get active cart for table
- **PUT** `/api/cart/:id/status` - Update cart status
- **DELETE** `/api/cart/:id` - Clear cart

### Cart Items

- **POST** `/api/cart/:cartId/items` - Add item to cart
- **PUT** `/api/cart/:cartId/items/:itemId` - Update cart item quantity/notes
- **DELETE** `/api/cart/:cartId/items/:itemId` - Remove item from cart
- **GET** `/api/cart/:cartId/items` - List cart items

## 5. SALES MANAGEMENT

### Order Processing

- **POST** `/api/sales` - Create new sale from cart
- **GET** `/api/sales` - List sales (with filtering by date, status, table)
- **GET** `/api/sales/:id` - Get specific sale details
- **PUT** `/api/sales/:id/status` - Update order status
- **PUT** `/api/sales/:id/payment` - Update payment status
- **POST** `/api/sales/:id/items` - Add items to existing sale
- **PUT** `/api/sales/:id/items/:itemId` - Update sale item

### Payment Processing

- **POST** `/api/sales/:id/payment` - Process payment
- **GET** `/api/sales/:id/receipt` - Generate receipt
- **POST** `/api/sales/:id/refund` - Process refund

### Sales Analytics

- **GET** `/api/sales/reports/daily` - Daily sales report
- **GET** `/api/sales/reports/monthly` - Monthly sales report
- **GET** `/api/sales/reports/item-wise` - Item-wise sales analysis
- **GET** `/api/sales/reports/table-wise` - Table-wise performance

## 6. PARTY MANAGEMENT (CUSTOMERS/SUPPLIERS)

### Party Operations

- **GET** `/api/parties` - List all parties (with type filter)
- **POST** `/api/parties` - Create new party
- **GET** `/api/parties/:id` - Get party details
- **PUT** `/api/parties/:id` - Update party information
- **DELETE** `/api/parties/:id` - Delete party
- **PUT** `/api/parties/:id/status` - Toggle party active status

### Party Transactions

- **GET** `/api/parties/:id/transactions` - Get party transaction history
- **POST** `/api/parties/:id/transactions` - Record new transaction
- **GET** `/api/parties/:id/balance` - Get current balance
- **POST** `/api/parties/:id/payment` - Record payment

## 7. EXPENSE MANAGEMENT

### Expense Categories

- **GET** `/api/expenses/categories` - List expense categories
- **POST** `/api/expenses/categories` - Create expense category
- **PUT** `/api/expenses/categories/:id` - Update expense category
- **DELETE** `/api/expenses/categories/:id` - Delete expense category

### Expense Operations

- **GET** `/api/expenses` - List expenses (with date/category filters)
- **POST** `/api/expenses` - Create new expense
- **GET** `/api/expenses/:id` - Get expense details
- **PUT** `/api/expenses/:id` - Update expense
- **DELETE** `/api/expenses/:id` - Delete expense
- **POST** `/api/expenses/:id/receipt` - Upload receipt
- **PUT** `/api/expenses/:id/approve` - Approve expense

### Expense Reports

- **GET** `/api/expenses/reports/category-wise` - Category-wise expense report
- **GET** `/api/expenses/reports/monthly` - Monthly expense report

## 8. INVENTORY MANAGEMENT

### Inventory Items

- **GET** `/api/inventory/items` - List inventory items
- **POST** `/api/inventory/items` - Add new inventory item
- **GET** `/api/inventory/items/:id` - Get item details
- **PUT** `/api/inventory/items/:id` - Update inventory item
- **DELETE** `/api/inventory/items/:id` - Delete inventory item
- **GET** `/api/inventory/low-stock` - Get low stock items

### Stock Management

- **POST** `/api/inventory/:id/stock-in` - Add stock
- **POST** `/api/inventory/:id/stock-out` - Remove stock
- **GET** `/api/inventory/:id/movements` - Get stock movement history
- **POST** `/api/inventory/bulk-update` - Bulk stock update

## 9. PAYMENT METHOD MANAGEMENT

- **GET** `/api/payment-methods` - List payment methods
- **POST** `/api/payment-methods` - Create payment method
- **PUT** `/api/payment-methods/:id` - Update payment method
- **PUT** `/api/payment-methods/:id/status` - Toggle payment method status

## 10. SYSTEM CONFIGURATION

### Restaurant Settings

- **GET** `/api/settings/restaurant` - Get restaurant information
- **PUT** `/api/settings/restaurant` - Update restaurant information
- **POST** `/api/settings/restaurant/logo` - Upload restaurant logo

### System Settings

- **GET** `/api/settings/system` - Get system settings
- **PUT** `/api/settings/system` - Update system settings

### Bill Settings

- **GET** `/api/settings/billing` - Get bill settings
- **PUT** `/api/settings/billing` - Update bill settings

## 11. REPORTING & ANALYTICS

### Dashboard Data

- **GET** `/api/dashboard/summary` - Get dashboard summary
- **GET** `/api/dashboard/recent-orders` - Get recent orders
- **GET** `/api/dashboard/top-items` - Get top selling items

### Reports

- **GET** `/api/reports/sales` - Sales reports with date range
- **GET** `/api/reports/inventory` - Inventory reports
- **GET** `/api/reports/expenses` - Expense reports
- **GET** `/api/reports/profit-loss` - Profit & loss report

## 12. ADDITIONAL FEATURES

### Kitchen Display System

- **GET** `/api/kitchen/orders` - Get pending kitchen orders
- **PUT** `/api/kitchen/orders/:id/status` - Update cooking status
- **GET** `/api/kitchen/orders/completed` - Get completed orders

### Notifications

- **GET** `/api/notifications` - Get user notifications
- **PUT** `/api/notifications/:id/read` - Mark notification as read
- **POST** `/api/notifications/low-stock` - Send low stock alerts

### Data Export/Import

- **GET** `/api/export/sales` - Export sales data
- **GET** `/api/export/inventory` - Export inventory data
- **POST** `/api/import/menu` - Import menu data

## MIDDLEWARE REQUIREMENTS

1. **Authentication Middleware** - Verify JWT tokens
2. **Authorization Middleware** - Role-based access control
3. **Rate Limiting** - Prevent API abuse
4. **Input Validation** - Validate request data
5. **Error Handling** - Centralized error handling
6. **Logging** - Request/response logging
7. **File Upload** - Handle image uploads
8. **CORS** - Cross-origin resource sharing

## REAL-TIME FEATURES (WebSocket)

- Order status updates for kitchen
- Table status changes
- Live order tracking
- New order notifications
- Low stock alerts
- Payment confirmations

This comprehensive list covers all the major functionalities your restaurant management system would need based on your database schema.
