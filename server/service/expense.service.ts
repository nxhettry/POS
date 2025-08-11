import Expense from "../models/expenses.models.js";
import ExpenseCategory from "../models/expenseCategories.js";
import PaymentMethod from "../models/paymentMethod.models.js";
import Party from "../models/party.models.js";
import User from "../models/user.models.js";
import { addExpenseTransactionService } from "./daybook.service.js";
import { isNonCreditPayment } from "../utils/payment.utils.js";
import { Op } from "sequelize";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createExpenseService = async (
  expenseData: any
): Promise<ServiceResponse<any>> => {
  try {
    console.log("=== CREATE EXPENSE SERVICE ===");
    console.log("Expense data received:", JSON.stringify(expenseData, null, 2));

    const expense = await Expense.create(expenseData);
    console.log(
      "Expense created in DB:",
      JSON.stringify(expense.toJSON(), null, 2)
    );

    const expenseWithIncludes = await Expense.findByPk((expense as any).id, {
      include: [
        { model: ExpenseCategory, as: "ExpenseCategory" },
        { model: PaymentMethod, as: "PaymentMethod" },
        { model: Party, as: "Party" },
        { model: User, as: "User" },
      ],
    });
    console.log(
      "Expense with includes:",
      JSON.stringify(expenseWithIncludes?.toJSON(), null, 2)
    );

    if (
      expenseData.paymentMethodId &&
      (expenseData.approvedBy || expenseData.approvedBy === undefined)
    ) {
      const isNonCredit = await isNonCreditPayment(expenseData.paymentMethodId);
      console.log("Payment method is non-credit:", isNonCredit);
      if (isNonCredit) {
        try {
          await addExpenseTransactionService(
            (expense as any).id,
            expenseData.amount || 0,
            expenseData.paymentMethodId,
            expenseData.date,
            expenseData.createdBy?.toString() || "system"
          );
          console.log("Added to daybook successfully");
        } catch (error) {
          console.error("Error adding expense to daybook:", error);
        }
      }
    }

    return {
      success: true,
      data: expenseWithIncludes,
      message: "Expense created successfully",
    };
  } catch (error) {
    console.error("Error in createExpenseService:", error);
    return {
      success: false,
      message: `Failed to create expense: ${
        error instanceof Error ? error.message : "Unknown error"
      }`,
    };
  }
};

export const updateExpenseService = async (
  id: number,
  expenseData: any
): Promise<ServiceResponse<any>> => {
  const expense = await Expense.findByPk(id);
  if (!expense) {
    return {
      success: false,
      message: "Expense not found",
    };
  }

  const oldPaymentMethodId = (expense as any).paymentMethodId;
  const oldApprovedBy = (expense as any).approvedBy;

  await expense.update(expenseData);
  const updatedExpense = await Expense.findByPk(id, {
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
  });

  const paymentMethodId = expenseData.paymentMethodId || oldPaymentMethodId;
  const shouldAddToDaybook =
    (expenseData.paymentMethodId &&
      expenseData.paymentMethodId !== oldPaymentMethodId) ||
    (expenseData.approvedBy && !oldApprovedBy);

  if (paymentMethodId && shouldAddToDaybook) {
    const isNonCredit = await isNonCreditPayment(paymentMethodId);
    if (isNonCredit) {
      try {
        await addExpenseTransactionService(
          id,
          expenseData.amount || (expense as any).amount || 0,
          paymentMethodId,
          expenseData.date || (expense as any).date,
          expenseData.createdBy?.toString() ||
            (expense as any).createdBy?.toString() ||
            "system"
        );
      } catch (error) {
        console.error("Error adding expense update to daybook:", error);
      }
    }
  }

  return {
    success: true,
    data: updatedExpense,
    message: "Expense updated successfully",
  };
};

export const getExpenseService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const expense = await Expense.findByPk(id, {
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
  });

  if (!expense) {
    return {
      success: false,
      message: "Expense not found",
    };
  }

  return {
    success: true,
    data: expense,
    message: "Expense retrieved successfully",
  };
};

export const getAllExpensesService = async (): Promise<
  ServiceResponse<any[]>
> => {
  const expenses = await Expense.findAll({
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: "Expenses retrieved successfully",
  };
};

export const getExpensesByCategoryService = async (
  categoryId: number
): Promise<ServiceResponse<any[]>> => {
  const expenses = await Expense.findAll({
    where: {
      categoryId: categoryId,
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: `Expenses for category ${categoryId} retrieved successfully`,
  };
};

export const getExpensesByPartyService = async (
  partyId: number
): Promise<ServiceResponse<any[]>> => {
  const expenses = await Expense.findAll({
    where: {
      partyId: partyId,
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: `Expenses for party ${partyId} retrieved successfully`,
  };
};

export const getExpensesByCreatorService = async (
  createdBy: number
): Promise<ServiceResponse<any[]>> => {
  const expenses = await Expense.findAll({
    where: {
      createdBy: createdBy,
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: `Expenses created by user ${createdBy} retrieved successfully`,
  };
};

export const getExpensesByDateRangeService = async (
  startDate: string,
  endDate: string
): Promise<ServiceResponse<any[]>> => {
  const startDateTime = new Date(startDate);
  startDateTime.setUTCHours(0, 0, 0, 0);

  const endDateTime = new Date(endDate);
  endDateTime.setUTCHours(23, 59, 59, 999);

  const expenses = await Expense.findAll({
    where: {
      date: {
        [Op.between]: [startDateTime, endDateTime],
      },
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: `Expenses from ${startDate} to ${endDate} retrieved successfully`,
  };
};

export const getApprovedExpensesService = async (): Promise<
  ServiceResponse<any[]>
> => {
  const expenses = await Expense.findAll({
    where: {
      approvedBy: {
        [Op.not]: null,
      },
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: "Approved expenses retrieved successfully",
  };
};

export const getPendingExpensesService = async (): Promise<
  ServiceResponse<any[]>
> => {
  const expenses = await Expense.findAll({
    where: {
      approvedBy: null,
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [
      ["date", "DESC"],
      ["createdAt", "DESC"],
    ],
  });

  return {
    success: true,
    data: expenses,
    message: "Pending expenses retrieved successfully",
  };
};

export const deleteExpenseService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const expense = await Expense.findByPk(id);
  if (!expense) {
    return {
      success: false,
      message: "Expense not found",
    };
  }

  await expense.destroy();
  return {
    success: true,
    data: null,
    message: "Expense deleted successfully",
  };
};
