import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateExpenseData } from "../validators/expense.validator.js";
import {
  createExpenseService,
  updateExpenseService,
  getExpenseService,
  getAllExpensesService,
  getExpensesByCategoryService,
  getExpensesByPartyService,
  getExpensesByCreatorService,
  getExpensesByDateRangeService,
  getApprovedExpensesService,
  getPendingExpensesService,
  deleteExpenseService,
} from "../service/expense.service.js";

export const createExpense = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const expenseData = req.body;

    if (
      !expenseData.title ||
      expenseData.amount === undefined ||
      !expenseData.paymentMethodId ||
      !expenseData.date ||
      !expenseData.categoryId ||
      !expenseData.createdBy
    ) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Title, amount, payment method ID, date, category ID, and created by are required"
          )
        );
    }

    const validation = validateExpenseData(expenseData);

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

    try {
      const result = await createExpenseService(expenseData);

      if (result.success) {
        return res
          .status(201)
          .json(new apiResponse(201, result.data, result.message));
      } else {
        return res.status(400).json(new apiResponse(400, null, result.message));
      }
    } catch (error) {
      return res
        .status(500)
        .json(new apiResponse(500, null, "Internal server error"));
    }
  }
);

export const updateExpense = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const expenseData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense ID is required"));
    }

    const validation = validateExpenseData(expenseData);

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

    const result = await updateExpenseService(Number(id), expenseData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getExpense = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense ID is required"));
    }

    const result = await getExpenseService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllExpenses = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllExpensesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getExpensesByCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { categoryId } = req.params;

    if (!categoryId || isNaN(Number(categoryId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid category ID is required"));
    }

    const result = await getExpensesByCategoryService(Number(categoryId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getExpensesByParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { partyId } = req.params;

    if (!partyId || isNaN(Number(partyId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const result = await getExpensesByPartyService(Number(partyId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getExpensesByCreator = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { createdBy } = req.params;

    if (!createdBy || isNaN(Number(createdBy))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid creator ID is required"));
    }

    const result = await getExpensesByCreatorService(Number(createdBy));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getExpensesByDateRange = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Start date and end date are required as query parameters"
          )
        );
    }

    const start = new Date(startDate as string);
    const end = new Date(endDate as string);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid date format is required"));
    }

    if (start > end) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Start date must be before or equal to end date"
          )
        );
    }

    const result = await getExpensesByDateRangeService(
      startDate as string,
      endDate as string
    );

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getApprovedExpenses = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getApprovedExpensesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getPendingExpenses = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getPendingExpensesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteExpense = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid expense ID is required"));
    }

    const result = await deleteExpenseService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);
