import ExpenseCategory from "../models/expenseCategories.js";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createExpenseCategoryService = async (
  expenseCategoryData: any
): Promise<ServiceResponse<any>> => {
  const expenseCategory = await ExpenseCategory.create(expenseCategoryData);
  return {
    success: true,
    data: expenseCategory,
    message: "Expense category created successfully",
  };
};

export const updateExpenseCategoryService = async (
  id: number,
  expenseCategoryData: any
): Promise<ServiceResponse<any>> => {
  const expenseCategory = await ExpenseCategory.findByPk(id);
  if (!expenseCategory) {
    return {
      success: false,
      message: "Expense category not found",
    };
  }

  await expenseCategory.update(expenseCategoryData);
  return {
    success: true,
    data: expenseCategory,
    message: "Expense category updated successfully",
  };
};

export const getExpenseCategoryService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const expenseCategory = await ExpenseCategory.findByPk(id);
  if (!expenseCategory) {
    return {
      success: false,
      message: "Expense category not found",
    };
  }

  return {
    success: true,
    data: expenseCategory,
    message: "Expense category retrieved successfully",
  };
};

export const getAllExpenseCategoriesService = async (): Promise<ServiceResponse<any[]>> => {
  const expenseCategories = await ExpenseCategory.findAll({
    order: [["name", "ASC"]],
  });

  return {
    success: true,
    data: expenseCategories,
    message: "Expense categories retrieved successfully",
  };
};

export const getActiveExpenseCategoriesService = async (): Promise<ServiceResponse<any[]>> => {
  const expenseCategories = await ExpenseCategory.findAll({
    where: {
      isActive: true,
    },
    order: [["name", "ASC"]],
  });

  return {
    success: true,
    data: expenseCategories,
    message: "Active expense categories retrieved successfully",
  };
};

export const deleteExpenseCategoryService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const expenseCategory = await ExpenseCategory.findByPk(id);
  if (!expenseCategory) {
    return {
      success: false,
      message: "Expense category not found",
    };
  }

  await expenseCategory.destroy();
  return {
    success: true,
    data: null,
    message: "Expense category deleted successfully",
  };
};
