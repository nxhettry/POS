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

    const result = await updateCartItemService(Number(id), cartItemData);

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

export const addToCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const requestData: AddToCartRequest = req.body;

    if (!requestData.tableId) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Table ID is required"));
    }

    if (
      !requestData.items ||
      !Array.isArray(requestData.items) ||
      requestData.items.length === 0
    ) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Items array is required and must not be empty"
          )
        );
    }

    for (const item of requestData.items) {
      if (!item.menuItemId || item.quantity <= 0 || item.rate < 0) {
        return res
          .status(400)
          .json(
            new apiResponse(
              400,
              null,
              "Each item must have valid menuItemId, quantity, and rate"
            )
          );
      }

      if (item.totalPrice !== item.quantity * item.rate) {
        return res
          .status(400)
          .json(
            new apiResponse(
              400,
              null,
              "Total price must equal quantity * rate for each item"
            )
          );
      }
    }

    const transaction = await sequelize.transaction();

    try {
      const cartData = {
        tableId: requestData.tableId,
        userId: requestData.userId,
        status: "open" as const,
      };

      const cartValidation = validateCartData(cartData);
      if (!cartValidation.isValid) {
        await transaction.rollback();
        return res
          .status(400)
          .json(
            new apiResponse(
              400,
              null,
              `Cart validation failed: ${cartValidation.errors.join(", ")}`
            )
          );
      }

      const cartResult = await createCartService(cartData);
      if (!cartResult.success) {
        await transaction.rollback();
        return res
          .status(400)
          .json(new apiResponse(400, null, cartResult.message));
      }

      const cart = cartResult.data;
      const createdItems = [];

      for (const item of requestData.items) {
        const cartItemData = {
          cartId: (cart as any).id,
          itemId: item.menuItemId,
          quantity: item.quantity,
          rate: item.rate,
          totalPrice: item.totalPrice,
          notes: item.notes,
        };

        const itemValidation = validateCartItemData(cartItemData);
        if (!itemValidation.isValid) {
          await transaction.rollback();
          return res
            .status(400)
            .json(
              new apiResponse(
                400,
                null,
                `Cart item validation failed: ${itemValidation.errors.join(
                  ", "
                )}`
              )
            );
        }

        const itemResult = await createCartItemService(cartItemData);
        if (!itemResult.success) {
          await transaction.rollback();
          return res
            .status(400)
            .json(new apiResponse(400, null, itemResult.message));
        }

        createdItems.push(itemResult.data);
      }

      await transaction.commit();

      return res.status(201).json(
        new apiResponse(
          201,
          {
            cart: cart,
            items: createdItems,
            itemCount: createdItems.length,
            totalAmount: createdItems.reduce(
              (sum, item) => sum + parseFloat((item as any).totalPrice),
              0
            ),
          },
          "Cart created with items successfully"
        )
      );
    } catch (error: any) {
      await transaction.rollback();
      return res
        .status(500)
        .json(
          new apiResponse(500, null, `Error creating cart: ${error.message}`)
        );
    }
  }
);

export const updateCartItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const requestData: UpdateCartItemsRequest = req.body;

    if (!requestData.cartId) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Cart ID is required"));
    }

    if (
      !requestData.items ||
      !Array.isArray(requestData.items) ||
      requestData.items.length === 0
    ) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Items array is required and must not be empty"
          )
        );
    }

    for (const item of requestData.items) {
      if (!item.menuItemId || item.quantity <= 0 || item.rate < 0) {
        return res
          .status(400)
          .json(
            new apiResponse(
              400,
              null,
              "Each item must have valid menuItemId, quantity, and rate"
            )
          );
      }

      if (item.totalPrice !== item.quantity * item.rate) {
        return res
          .status(400)
          .json(
            new apiResponse(
              400,
              null,
              "Total price must equal quantity * rate for each item"
            )
          );
      }
    }

    const transaction = await sequelize.transaction();

    try {
      const cartResult = await getCartService(requestData.cartId);
      if (!cartResult.success) {
        await transaction.rollback();
        return res
          .status(404)
          .json(new apiResponse(404, null, "Cart not found"));
      }

      const clearResult = await clearCartService(requestData.cartId);
      if (!clearResult.success) {
        await transaction.rollback();
        return res
          .status(400)
          .json(new apiResponse(400, null, clearResult.message));
      }

      const createdItems = [];

      for (const item of requestData.items) {
        const cartItemData = {
          cartId: requestData.cartId,
          itemId: item.menuItemId,
          quantity: item.quantity,
          rate: item.rate,
          totalPrice: item.totalPrice,
          notes: item.notes,
        };

        const itemValidation = validateCartItemData(cartItemData);
        if (!itemValidation.isValid) {
          await transaction.rollback();
          return res
            .status(400)
            .json(
              new apiResponse(
                400,
                null,
                `Cart item validation failed: ${itemValidation.errors.join(
                  ", "
                )}`
              )
            );
        }

        const itemResult = await createCartItemService(cartItemData);
        if (!itemResult.success) {
          await transaction.rollback();
          return res
            .status(400)
            .json(new apiResponse(400, null, itemResult.message));
        }

        createdItems.push(itemResult.data);
      }

      await transaction.commit();

      return res.status(200).json(
        new apiResponse(
          200,
          {
            cart: cartResult.data,
            items: createdItems,
            itemCount: createdItems.length,
            totalAmount: createdItems.reduce(
              (sum, item) => sum + parseFloat((item as any).totalPrice),
              0
            ),
          },
          "Cart items updated successfully"
        )
      );
    } catch (error: any) {
      await transaction.rollback();
      return res
        .status(500)
        .json(
          new apiResponse(
            500,
            null,
            `Error updating cart items: ${error.message}`
          )
        );
    }
  }
);

export const checkoutCart = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { cartId } = req.params;

    if (!cartId || isNaN(Number(cartId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid cart ID is required"));
    }

    const transaction = await sequelize.transaction();

    try {
      const cartResult = await getCartService(Number(cartId));
      if (!cartResult.success) {
        await transaction.rollback();
        return res
          .status(404)
          .json(new apiResponse(404, null, "Cart not found"));
      }

      const cart = cartResult.data;

      if (cart && (cart as any).status !== "open") {
        await transaction.rollback();
        return res
          .status(400)
          .json(new apiResponse(400, null, "Cart is not open for checkout"));
      }

      const itemsResult = await getCartItemsByCartService(Number(cartId));
      if (
        !itemsResult.success ||
        !itemsResult.data ||
        itemsResult.data.length === 0
      ) {
        await transaction.rollback();
        return res
          .status(400)
          .json(new apiResponse(400, null, "Cart has no items to checkout"));
      }

      const cartItems = itemsResult.data;

      const totalAmount = cartItems.reduce(
        (sum, item) => sum + parseFloat((item as any).totalPrice),
        0
      );

      const updateResult = await updateCartService(Number(cartId), {
        status: "closed",
      });
      if (!updateResult.success) {
        await transaction.rollback();
        return res
          .status(400)
          .json(new apiResponse(400, null, updateResult.message));
      }

      await transaction.commit();

      return res.status(200).json(
        new apiResponse(
          200,
          {
            cart: updateResult.data,
            items: cartItems,
            itemCount: cartItems.length,
            totalAmount: totalAmount,
            checkoutTime: new Date(),
          },
          "Cart checked out successfully"
        )
      );
    } catch (error: any) {
      await transaction.rollback();
      return res
        .status(500)
        .json(
          new apiResponse(
            500,
            null,
            `Error checking out cart: ${error.message}`
          )
        );
    }
  }
);
