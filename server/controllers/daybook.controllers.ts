import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import Daybook from "../models/daybook.models.js";
import DaybookTransaction from "../models/daybookTransaction.models.js";
import { Op } from "sequelize";

// Get today's daybook summary
export const getTodaysSummary = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get opening balance (daybook entry)
    const daybook = await Daybook.findOne({
      where: {
        date: today.toISOString().split('T')[0]
      }
    });

    // Get all transactions for today
    const transactions = await DaybookTransaction.findAll({
      where: {
        timestamp: {
          [Op.gte]: today,
          [Op.lt]: tomorrow
        }
      },
      order: [['timestamp', 'ASC']]
    });

    // Calculate summaries
    const summary = {
      openingBalance: {
        cash: (daybook as any)?.openingCashBalance || 0,
        online: (daybook as any)?.openingBankBalance || 0
      },
      sales: {
        cash: 0,
        online: 0
      },
      expenses: {
        cash: 0,
        online: 0
      },
      netCash: 0,
      netOnline: 0,
      totalNet: 0
    };

    transactions.forEach(transaction => {
      const transactionData = transaction as any;
      if (transactionData.transactionType === 'sale') {
        if (transactionData.paymentMode === 'cash') {
          summary.sales.cash += Number(transactionData.amount) || 0;
        } else if (transactionData.paymentMode === 'online') {
          summary.sales.online += Number(transactionData.amount) || 0;
        }
      } else if (transactionData.transactionType === 'expense') {
        if (transactionData.paymentMode === 'cash') {
          summary.expenses.cash += Number(transactionData.amount) || 0;
        } else if (transactionData.paymentMode === 'online') {
          summary.expenses.online += Number(transactionData.amount) || 0;
        }
      }
    });

    summary.netCash = Number(summary.openingBalance.cash) + summary.sales.cash - summary.expenses.cash;
    summary.netOnline = Number(summary.openingBalance.online) + summary.sales.online - summary.expenses.online;
    summary.totalNet = summary.netCash + summary.netOnline;

    return res
      .status(200)
      .json(new apiResponse(200, { summary, transactions }, "Today's summary retrieved successfully"));
  }
);

// Get daybook entries for a date range
export const getDaybookEntries = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { startDate, endDate } = req.query;
    
    const whereClause: any = {};
    
    if (startDate && endDate) {
      whereClause.timestamp = {
        [Op.gte]: new Date(startDate as string),
        [Op.lte]: new Date(endDate as string)
      };
    } else {
      // Default to today
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      whereClause.timestamp = {
        [Op.gte]: today,
        [Op.lt]: tomorrow
      };
    }

    const entries = await DaybookTransaction.findAll({
      where: whereClause,
      order: [['timestamp', 'DESC']]
    });

    return res
      .status(200)
      .json(new apiResponse(200, entries, "Daybook entries retrieved successfully"));
  }
);

// Get daybook summary for a specific date
export const getDaybookSummary = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { date } = req.params;
    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);
    const nextDay = new Date(targetDate);
    nextDay.setDate(nextDay.getDate() + 1);

    // Get daybook for the date
    const daybook = await Daybook.findOne({
      where: {
        date: targetDate.toISOString().split('T')[0]
      }
    });

    // Get all transactions for the date
    const transactions = await DaybookTransaction.findAll({
      where: {
        timestamp: {
          [Op.gte]: targetDate,
          [Op.lt]: nextDay
        }
      },
      order: [['timestamp', 'ASC']]
    });

    // Calculate summary
    const summary = {
      date: targetDate.toISOString().split('T')[0],
      openingBalance: {
        cash: (daybook as any)?.openingCashBalance || 0,
        online: (daybook as any)?.openingBankBalance || 0
      },
      sales: {
        cash: 0,
        online: 0,
        count: 0
      },
      expenses: {
        cash: 0,
        online: 0,
        count: 0
      },
      netCash: 0,
      netOnline: 0,
      totalNet: 0
    };

    transactions.forEach(transaction => {
      const transactionData = transaction as any;
      if (transactionData.transactionType === 'sale') {
        if (transactionData.paymentMode === 'cash') {
          summary.sales.cash += Number(transactionData.amount) || 0;
        } else if (transactionData.paymentMode === 'online') {
          summary.sales.online += Number(transactionData.amount) || 0;
        }
        summary.sales.count++;
      } else if (transactionData.transactionType === 'expense') {
        if (transactionData.paymentMode === 'cash') {
          summary.expenses.cash += Number(transactionData.amount) || 0;
        } else if (transactionData.paymentMode === 'online') {
          summary.expenses.online += Number(transactionData.amount) || 0;
        }
        summary.expenses.count++;
      }
    });

    summary.netCash = Number(summary.openingBalance.cash) + summary.sales.cash - summary.expenses.cash;
    summary.netOnline = Number(summary.openingBalance.online) + summary.sales.online - summary.expenses.online;
    summary.totalNet = summary.netCash + summary.netOnline;

    return res
      .status(200)
      .json(new apiResponse(200, summary, "Daybook summary retrieved successfully"));
  }
);

// Get daybook by date
export const getDaybookByDate = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { date } = req.params;
    
    if (!date) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Date is required"));
    }

    const targetDate = new Date(date);
    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    const daybook = await Daybook.findOne({
      where: {
        date: {
          [Op.between]: [startOfDay.toISOString().split('T')[0], endOfDay.toISOString().split('T')[0]]
        }
      },
      include: [
        {
          model: DaybookTransaction,
          as: 'DaybookTransactions'
        }
      ]
    });

    if (!daybook) {
      return res
        .status(404)
        .json(new apiResponse(404, null, "No daybook found for this date"));
    }

    return res
      .status(200)
      .json(new apiResponse(200, daybook, "Daybook retrieved successfully"));
  }
);
