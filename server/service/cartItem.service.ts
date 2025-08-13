import CartItem from "../models/cartItems.models.js";
import Cart from "../models/cart.models.js";
import MenuItem from "../models/menuItem.models.js";
import sequelize from "../db/connection.js";
import { Transaction } from "sequelize";

export interface CartItemUpdateData {
  id: number;
  cartId?: number;
  itemId?: number;
  quantity?: number;
  rate?: number;
  totalPrice?: number;
  notes?: string;
}

export interface CartItemCreateData {
  cartId: number;
  itemId: number;
  quantity: number;
  rate: number;
  totalPrice?: number;
  notes?: string;
}

export const createCartItemService = async (
  cartItemData: CartItemCreateData | CartItemCreateData[],
  transaction?: Transaction
) => {
  const t = transaction || (await sequelize.transaction());

  try {
    const itemsToCreate = Array.isArray(cartItemData)
      ? cartItemData
      : [cartItemData];

    itemsToCreate.forEach((item) => {
      if (!item.totalPrice) {
        item.totalPrice = item.quantity * item.rate;
      }
    });

    const newCartItems = await CartItem.bulkCreate(itemsToCreate as any, {
      transaction: t,
    });

    if (!transaction) {
      await t.commit();
    }

    return {
      success: true,
      data: newCartItems,
      message: "Cart items created successfully",
    };
  } catch (error: any) {
    if (!transaction) {
      await t.rollback();
    }
    throw new Error(`Failed to create cart items: ${error.message}`);
  }
};

export const updateCartItemService = async (
  cartItemData: CartItemUpdateData | CartItemUpdateData[],
  transaction?: Transaction
) => {
  const t = transaction || (await sequelize.transaction());

  try {
    const itemsToUpdate = Array.isArray(cartItemData)
      ? cartItemData
      : [cartItemData];

    const updatedCartItems = await CartItem.bulkCreate(itemsToUpdate as any, {
      updateOnDuplicate: ["quantity", "totalPrice"],
      transaction: t,
    });

    if (!transaction) {
      await t.commit();
    }

    return {
      success: true,
      data: updatedCartItems,
      message: "Cart items updated successfully",
    };
  } catch (error: any) {
    if (!transaction) {
      await t.rollback();
    }
    throw new Error(`Failed to update cart items: ${error.message}`);
  }
};

export const getCartItemService = async (id: number) => {
  try {
    const cartItem = await CartItem.findByPk(id, {
      include: [Cart, MenuItem],
    });

    if (!cartItem) {
      return {
        success: false,
        data: null,
        message: "Cart item not found",
      };
    }

    return {
      success: true,
      data: cartItem,
      message: "Cart item retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get cart item: ${error.message}`);
  }
};

export const getAllCartItemsService = async () => {
  try {
    const cartItems = await CartItem.findAll({
      include: [Cart, MenuItem],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: cartItems,
      message: "Cart items retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get cart items: ${error.message}`);
  }
};

export const getCartItemsByCartService = async (cartId: number) => {
  try {
    const cartItems = await CartItem.findAll({
      where: { cartId },
      include: [MenuItem],
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: cartItems,
      message: "Cart items retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get cart items by cart: ${error.message}`);
  }
};

export const deleteCartItemService = async (
  id: number,
  transaction?: Transaction
) => {
  const t = transaction || (await sequelize.transaction());

  try {
    const cartItem = await CartItem.findByPk(id, { transaction: t });

    if (!cartItem) {
      if (!transaction) {
        await t.rollback();
      }
      return {
        success: false,
        data: null,
        message: "Cart item not found",
      };
    }

    await cartItem.destroy({ transaction: t });

    if (!transaction) {
      await t.commit();
    }

    return {
      success: true,
      data: null,
      message: "Cart item deleted successfully",
    };
  } catch (error: any) {
    if (!transaction) {
      await t.rollback();
    }
    throw new Error(`Failed to delete cart item: ${error.message}`);
  }
};

export const clearCartService = async (
  cartId: number,
  transaction?: Transaction
) => {
  const t = transaction || (await sequelize.transaction());

  try {
    const cart = await Cart.findByPk(cartId, { transaction: t });

    if (!cart) {
      if (!transaction) {
        await t.rollback();
      }
      return {
        success: false,
        data: null,
        message: "Cart not found",
      };
    }

    await CartItem.destroy({
      where: { cartId },
      transaction: t,
    });

    if (!transaction) {
      await t.commit();
    }

    return {
      success: true,
      data: null,
      message: "Cart cleared successfully",
    };
  } catch (error: any) {
    if (!transaction) {
      await t.rollback();
    }
    throw new Error(`Failed to clear cart: ${error.message}`);
  }
};
