import Expense from "../models/expenses.models.js";
import ExpenseCategory from "../models/expenseCategories.js";
import PaymentMethod from "../models/paymentMethod.models.js";
import Party from "../models/party.models.js";
import User from "../models/user.models.js";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createExpenseService = async (
  expenseData: any
): Promise<ServiceResponse<any>> => {
  const expense = await Expense.create(expenseData);
  const expenseWithIncludes = await Expense.findByPk((expense as any).id, {
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
  });

  return {
    success: true,
    data: expenseWithIncludes,
    message: "Expense created successfully",
  };
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

  await expense.update(expenseData);
  const updatedExpense = await Expense.findByPk(id, {
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
  });

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

export const getAllExpensesService = async (): Promise<ServiceResponse<any[]>> => {
  const expenses = await Expense.findAll({
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [["date", "DESC"], ["createdAt", "DESC"]],
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
    order: [["date", "DESC"], ["createdAt", "DESC"]],
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
    order: [["date", "DESC"], ["createdAt", "DESC"]],
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
    order: [["date", "DESC"], ["createdAt", "DESC"]],
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
  const expenses = await Expense.findAll({
    where: {
      date: {
        [require('sequelize').Op.between]: [startDate, endDate],
      },
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [["date", "DESC"], ["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: expenses,
    message: `Expenses from ${startDate} to ${endDate} retrieved successfully`,
  };
};

export const getApprovedExpensesService = async (): Promise<ServiceResponse<any[]>> => {
  const expenses = await Expense.findAll({
    where: {
      approvedBy: {
        [require('sequelize').Op.not]: null,
      },
    },
    include: [
      { model: ExpenseCategory, as: "ExpenseCategory" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
    ],
    order: [["date", "DESC"], ["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: expenses,
    message: "Approved expenses retrieved successfully",
  };
};

export const getPendingExpensesService = async (): Promise<ServiceResponse<any[]>> => {
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
    order: [["date", "DESC"], ["createdAt", "DESC"]],
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
