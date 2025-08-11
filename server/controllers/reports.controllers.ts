import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import Sales from "../models/sales.models.js";
import SalesItem from "../models/salesItem.models.js";
import MenuItem from "../models/menuItem.models.js";
import Table from "../models/table.model.js";
import PaymentMethod from "../models/paymentMethod.models.js";
import Party from "../models/party.models.js";
import User from "../models/user.models.js";
import Expense from "../models/expenses.models.js";
import ExpenseCategory from "../models/expenseCategories.js";
import { Op } from "sequelize";

export const getSalesReportByDateRange = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Start date and end date are required"));
    }

    try {
      const start = new Date(startDate as string);
      const end = new Date(endDate as string);
      
      // Set end date to end of day
      end.setHours(23, 59, 59, 999);

      const sales = await Sales.findAll({
        where: {
          createdAt: {
            [Op.between]: [start, end],
          },
        },
        include: [
          { model: Table, as: "Table" },
          { model: PaymentMethod, as: "PaymentMethod" },
          { model: Party, as: "Party" },
          { model: User, as: "User" },
          { 
            model: SalesItem, 
            as: "SalesItems",
            include: [{ model: MenuItem, as: "MenuItem" }]
          },
        ],
        order: [["createdAt", "DESC"]],
      });

      return res
        .status(200)
        .json(new apiResponse(200, sales, "Sales data retrieved successfully"));
    } catch (error: any) {
      return res
        .status(500)
        .json(new apiResponse(500, null, `Error fetching sales data: ${error.message}`));
    }
  }
);

export const getExpensesReportByDateRange = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Start date and end date are required"));
    }

    try {
      const start = new Date(startDate as string);
      const end = new Date(endDate as string);
      
      // Set end date to end of day
      end.setHours(23, 59, 59, 999);

      const expenses = await Expense.findAll({
        where: {
          date: {
            [Op.between]: [start, end],
          },
        },
        include: [
          { model: ExpenseCategory, as: "ExpenseCategory" },
          { model: PaymentMethod, as: "PaymentMethod" },
          { model: Party, as: "Party" },
          { model: User, as: "User" },
        ],
        order: [["date", "DESC"]],
      });

      return res
        .status(200)
        .json(new apiResponse(200, expenses, "Expenses data retrieved successfully"));
    } catch (error: any) {
      return res
        .status(500)
        .json(new apiResponse(500, null, `Error fetching expenses data: ${error.message}`));
    }
  }
);

export const getSalesAnalytics = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Start date and end date are required"));
    }

    try {
      const start = new Date(startDate as string);
      const end = new Date(endDate as string);
      end.setHours(23, 59, 59, 999);

      const sales = await Sales.findAll({
        where: {
          createdAt: {
            [Op.between]: [start, end],
          },
        },
        include: [
          { 
            model: SalesItem, 
            as: "SalesItems",
            include: [{ model: MenuItem, as: "MenuItem" }]
          },
        ],
      });

      const expenses = await Expense.findAll({
        where: {
          date: {
            [Op.between]: [start, end],
          },
        },
        include: [
          { model: ExpenseCategory, as: "ExpenseCategory" },
        ],
      });

      // Calculate analytics
      let totalSales = 0;
      let totalSubtotal = 0;
      let totalTax = 0;
      let totalItemsSold = 0;
      const itemStats: { [key: string]: { quantity: number; revenue: number; name: string } } = {};
      const dailySales: { [key: string]: number } = {};
      const orderTypeStats = { dineIn: 0, takeaway: 0 };
      const paymentStatusStats = { paid: 0, pending: 0, partial: 0, refunded: 0 };
      const orderStatusStats = { pending: 0, preparing: 0, ready: 0, served: 0, cancelled: 0 };

      sales.forEach(sale => {
        const saleData = sale as any;
        totalSales += parseFloat(saleData.total || 0);
        totalSubtotal += parseFloat(saleData.subTotal || 0);
        totalTax += parseFloat(saleData.tax || 0);

        // Daily sales
        const dateKey = new Date(saleData.createdAt).toISOString().split('T')[0];
        dailySales[dateKey] = (dailySales[dateKey] || 0) + parseFloat(saleData.total || 0);

        // Order type stats
        if (saleData.orderType === 'dine-in' || saleData.orderType === 'Dine In') {
          orderTypeStats.dineIn++;
        } else if (saleData.orderType === 'takeaway' || saleData.orderType === 'Takeaway') {
          orderTypeStats.takeaway++;
        }

        // Payment status stats
        const paymentStatus = saleData.paymentStatus;
        if (paymentStatusStats.hasOwnProperty(paymentStatus)) {
          (paymentStatusStats as any)[paymentStatus]++;
        }

        // Order status stats
        const orderStatus = saleData.orderStatus;
        if (orderStatusStats.hasOwnProperty(orderStatus)) {
          (orderStatusStats as any)[orderStatus]++;
        }

        // Item stats
        if (saleData.SalesItems) {
          saleData.SalesItems.forEach((item: any) => {
            const itemName = item.itemName;
            const quantity = parseFloat(item.quantity || 0);
            const revenue = parseFloat(item.totalPrice || 0);
            totalItemsSold += quantity;

            if (itemStats[itemName]) {
              itemStats[itemName].quantity += quantity;
              itemStats[itemName].revenue += revenue;
            } else {
              itemStats[itemName] = { 
                name: itemName, 
                quantity: quantity, 
                revenue: revenue 
              };
            }
          });
        }
      });

      let totalExpenses = 0;
      const expenseCategories: { [key: string]: number } = {};

      expenses.forEach(expense => {
        const expenseData = expense as any;
        totalExpenses += parseFloat(expenseData.amount || 0);

        const categoryName = expenseData.ExpenseCategory?.name || 'Unknown';
        expenseCategories[categoryName] = (expenseCategories[categoryName] || 0) + parseFloat(expenseData.amount || 0);
      });

      // Sort items by quantity sold
      const topItems = Object.values(itemStats)
        .sort((a, b) => b.quantity - a.quantity)
        .slice(0, 10);

      const analytics = {
        summary: {
          totalSales: totalSales,
          totalExpenses: totalExpenses,
          netProfit: totalSales - totalExpenses,
          totalOrders: sales.length,
          totalItemsSold: totalItemsSold,
          averageOrderValue: sales.length > 0 ? totalSales / sales.length : 0,
          totalSubtotal: totalSubtotal,
          totalTax: totalTax,
        },
        dailySales: dailySales,
        topItems: topItems,
        orderTypeStats: orderTypeStats,
        paymentStatusStats: paymentStatusStats,
        orderStatusStats: orderStatusStats,
        expenseCategories: expenseCategories,
      };

      return res
        .status(200)
        .json(new apiResponse(200, analytics, "Sales analytics retrieved successfully"));
    } catch (error: any) {
      return res
        .status(500)
        .json(new apiResponse(500, null, `Error fetching sales analytics: ${error.message}`));
    }
  }
);