import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateTableData } from "../validators/table.validator.js";
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

    if (!tableData.name) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Table name is required"));
    }

    const validation = validateTableData(tableData);

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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    const validation = validateTableData(tableData);

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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getAllTables = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);