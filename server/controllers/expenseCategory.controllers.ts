import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateExpenseCategoryData } from "../validators/expenseCategory.validator.js";
import {
  createExpenseCategoryService,
  updateExpenseCategoryService,
  getExpenseCategoryService,
  getAllExpenseCategoriesService,
  getActiveExpenseCategoriesService,
  deleteExpenseCategoryService,
} from "../service/expenseCategory.service.js";

export const createExpenseCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const expenseCategoryData = req.body;

    if (!expenseCategoryData.name) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Expense category name is required"));
    }

    const validation = validateExpenseCategoryData(expenseCategoryData);

    if (!validation.isValid) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            `Validation failed: ${validation.errors.join(", ")}`
          )
        );
    }

    const result = await createExpenseCategoryService(expenseCategoryData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const updateExpenseCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const expenseCategoryData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense category ID is required"));
    }

    const validation = validateExpenseCategoryData(expenseCategoryData);

    if (!validation.isValid) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            `Validation failed: ${validation.errors.join(", ")}`
          )
        );
    }

    const result = await updateExpenseCategoryService(Number(id), expenseCategoryData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getExpenseCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense category ID is required"));
    }

    const result = await getExpenseCategoryService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllExpenseCategories = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllExpenseCategoriesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const getActiveExpenseCategories = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getActiveExpenseCategoriesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteExpenseCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense category ID is required"));
    }

    const result = await deleteExpenseCategoryService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);
