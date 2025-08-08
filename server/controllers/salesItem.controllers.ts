import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateSalesItemData } from "../validators/salesItem.validator.js";
import {
  createSalesItemService,
  updateSalesItemService,
  getSalesItemService,
  getAllSalesItemsService,
  getSalesItemsBySalesService,
  getSalesItemsByMenuItemService,
  deleteSalesItemService,
  deleteSalesItemsBySalesService,
} from "../service/salesItem.service.js";

export const createSalesItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const salesItemData = req.body;

    if (!salesItemData.salesId || !salesItemData.itemId || !salesItemData.itemName || 
        salesItemData.quantity === undefined || salesItemData.rate === undefined) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Sales ID, item ID, item name, quantity, and rate are required"));
    }

    const validation = validateSalesItemData(salesItemData);

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

    const result = await createSalesItemService(salesItemData);

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

export const updateSalesItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const salesItemData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales item ID is required"));
    }

    const validation = validateSalesItemData(salesItemData);

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

    const result = await updateSalesItemService(Number(id), salesItemData);

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

export const getSalesItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales item ID is required"));
    }

    const result = await getSalesItemService(Number(id));

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

export const getAllSalesItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllSalesItemsService();

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

export const getSalesItemsBySales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { salesId } = req.params;

    if (!salesId || isNaN(Number(salesId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales ID is required"));
    }

    const result = await getSalesItemsBySalesService(Number(salesId));

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

export const getSalesItemsByMenuItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { itemId } = req.params;

    if (!itemId || isNaN(Number(itemId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid menu item ID is required"));
    }

    const result = await getSalesItemsByMenuItemService(Number(itemId));

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

export const deleteSalesItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales item ID is required"));
    }

    const result = await deleteSalesItemService(Number(id));

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

export const deleteSalesItemsBySales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { salesId } = req.params;

    if (!salesId || isNaN(Number(salesId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales ID is required"));
    }

    const result = await deleteSalesItemsBySalesService(Number(salesId));

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
