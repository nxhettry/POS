import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateInventoryItemData } from "../validators/inventoryItem.validator.js";
import { validateStockMovementData } from "../validators/stockMovement.validator.js";
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
  updateStockMovementService,
  getStockMovementService,
  getAllStockMovementsService,
  getStockMovementsByItemService,
  deleteStockMovementService,
} from "../service/stockMovement.service.js";

export const createInventoryItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const itemData = req.body;

    if (!itemData.name || !itemData.unit || itemData.costPrice === undefined) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Name, unit, and cost price are required"));
    }

    const validation = validateInventoryItemData(itemData);

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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    const validation = validateInventoryItemData(itemData);

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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getAllInventoryItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getLowStockItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const createStockMovement = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const movementData = req.body;

    if (!movementData.inventoryItemId || !movementData.type || movementData.quantity === undefined || movementData.unitCost === undefined) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Inventory item ID, type, quantity, and unit cost are required"));
    }

    const validation = validateStockMovementData(movementData);

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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const updateStockMovement = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const movementData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid stock movement ID is required"));
    }

    const validation = validateStockMovementData(movementData);

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
      const result = await updateStockMovementService(Number(id), movementData);

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

export const getStockMovement = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid stock movement ID is required"));
    }

    try {
      const result = await getStockMovementService(Number(id));

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

export const getAllStockMovements = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
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

    try {
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
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const deleteStockMovement = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid stock movement ID is required"));
    }

    try {
      const result = await deleteStockMovementService(Number(id));

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