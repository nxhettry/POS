import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import {
  createTableService,
  updateTableService,
  getTableService,
  getAllTablesService,
  deleteTableService,
} from "../service/table.service.js";

export const createTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const tableData = req.body;

    if (!tableData.tableNumber || !tableData.capacity) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Table number and capacity are required"));
    }

    const result = await createTableService(tableData);

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

export const updateTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const tableData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid table ID is required"));
    }

    const result = await updateTableService(Number(id), tableData);

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

export const getTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid table ID is required"));
    }

    const result = await getTableService(Number(id));

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

export const getAllTables = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllTablesService();

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

export const deleteTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid table ID is required"));
    }

    const result = await deleteTableService(Number(id));

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