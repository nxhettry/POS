import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import {
  createInventoryItemService,
  updateInventoryItemService,
  getInventoryItemService,
  getAllInventoryItemsService,
  getLowStockItemsService,
  deleteInventoryItemService,
} from "../service/inventoryItem.service.js";
import {
  createStockMovementService,
  getStockMovementsByItemService,
  getAllStockMovementsService,
} from "../service/stockMovement.service.js";

export const createInventoryItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const itemData = req.body;

    if (!itemData.name || !itemData.unit || itemData.currentStock === undefined) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Item name, unit, and current stock are required"));
    }

    const result = await createInventoryItemService(itemData);

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

export const updateInventoryItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const itemData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid inventory item ID is required"));
    }

    const result = await updateInventoryItemService(Number(id), itemData);

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

export const getInventoryItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid inventory item ID is required"));
    }

    const result = await getInventoryItemService(Number(id));

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

export const getAllInventoryItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllInventoryItemsService();

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

export const getLowStockItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getLowStockItemsService();

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

export const deleteInventoryItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid inventory item ID is required"));
    }

    const result = await deleteInventoryItemService(Number(id));

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

export const createStockMovement = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const movementData = req.body;

    if (!movementData.inventoryItemId || !movementData.movementType || 
        movementData.quantity === undefined || !movementData.createdBy) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Inventory item ID, movement type, quantity, and created by are required"));
    }

    const result = await createStockMovementService(movementData);

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

export const getStockMovementsByItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { itemId } = req.params;

    if (!itemId || isNaN(Number(itemId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid inventory item ID is required"));
    }

    const result = await getStockMovementsByItemService(Number(itemId));

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

export const getAllStockMovements = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllStockMovementsService();

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