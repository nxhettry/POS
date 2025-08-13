import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateCartData } from "../validators/cart.validator.js";
import { validateCartItemData } from "../validators/cartItem.validator.js";
import {
  createCartService,
  updateCartService,
  getCartService,
  getAllCartsService,
  getCartsByStatusService,
  getCartsByTableService,
  deleteCartService,
} from "../service/cart.service.js";
import {
  createCartItemService,
  updateCartItemService,
  getCartItemService,
  getAllCartItemsService,
  getCartItemsByCartService,
  deleteCartItemService,
  clearCartService,
} from "../service/cartItem.service.js";
import sequelize from "../db/connection.js";

interface CartItemRequest {
  cartId: number | null;
  menuItemId: number;
  quantity: number;
  rate: number;
  totalPrice: number;
  notes?: string;
}

interface AddToCartRequest {
  tableId: number;
  userId?: number;
  items: CartItemRequest[];
}

interface UpdateCartItemsRequest {
  cartId: number;
  items: CartItemRequest[];
}

export const createCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const cartData = req.body;

    if (!cartData.tableId) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Table ID is required"));
    }

    const validation = validateCartData(cartData);

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

    const result = await createCartService(cartData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const updateCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const cartData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const validation = validateCartData(cartData);

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

    const result = await updateCartService(Number(id), cartData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const result = await getCartService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllCarts = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllCartsService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getCartsByStatus = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { status } = req.params;

    const validStatuses = ["open", "closed", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Valid status is required (open, closed, cancelled)"
          )
        );
    }

    const result = await getCartsByStatusService(
      status as "open" | "closed" | "cancelled"
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

export const getCartsByTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { tableId } = req.params;

    if (!tableId || isNaN(Number(tableId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid table ID is required"));
    }

    const result = await getCartsByTableService(Number(tableId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const result = await deleteCartService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const createCartItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const cartItemData = req.body;

    if (
      !cartItemData.cartId ||
      !cartItemData.menuItemId ||
      cartItemData.quantity === undefined
    ) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Cart ID, menu item ID, and quantity are required"
          )
        );
    }

    const validation = validateCartItemData(cartItemData);

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

    const result = await createCartItemService(cartItemData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const updateCartItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const cartItemData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart item ID is required"));
    }

    const validation = validateCartItemData(cartItemData);

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

    const result = await updateCartItemService(cartItemData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getCartItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart item ID is required"));
    }

    const result = await getCartItemService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllCartItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllCartItemsService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getCartItemsByCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { cartId } = req.params;

    if (!cartId || isNaN(Number(cartId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const result = await getCartItemsByCartService(Number(cartId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteCartItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart item ID is required"));
    }

    const result = await deleteCartItemService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const clearCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { cartId } = req.params;

    if (!cartId || isNaN(Number(cartId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const result = await clearCartService(Number(cartId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);
