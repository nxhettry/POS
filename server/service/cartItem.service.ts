import CartItem from "../models/cartItems.models.js";
import Cart from "../models/cart.models.js";
import MenuItem from "../models/menuItem.models.js";

interface CartItemUpdateData {
  cartId?: number;
  itemId?: number;
  quantity?: number;
  rate?: number;
  totalPrice?: number;
  notes?: string;
}

interface CartItemCreateData {
  cartId: number;
  itemId: number;
  quantity: number;
  rate: number;
  totalPrice?: number;
  notes?: string;
}

export const createCartItemService = async (
  cartItemData: CartItemCreateData
) => {
  try {
    if (!cartItemData.totalPrice) {
      cartItemData.totalPrice = cartItemData.quantity * cartItemData.rate;
    }

    const newCartItem = await CartItem.create(cartItemData as any);
    return {
      success: true,
      data: newCartItem,
      message: "Cart item created successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to create cart item: ${error.message}`);
  }
};

export const updateCartItemService = async (
  id: number,
  cartItemData: CartItemUpdateData
) => {
  try {
    const cartItem = await CartItem.findByPk(id);

    if (!cartItem) {
      return {
        success: false,
        data: null,
        message: "Cart item not found",
      };
    }

    if (
      cartItemData.quantity !== undefined &&
      cartItemData.rate !== undefined &&
      !cartItemData.totalPrice
    ) {
      cartItemData.totalPrice = cartItemData.quantity * cartItemData.rate;
    } else if (
      cartItemData.quantity !== undefined &&
      !cartItemData.totalPrice
    ) {
      const currentRate = parseFloat(cartItem.get("rate") as string) || 0;
      cartItemData.totalPrice = cartItemData.quantity * currentRate;
    } else if (cartItemData.rate !== undefined && !cartItemData.totalPrice) {
      const currentQuantity =
        parseFloat(cartItem.get("quantity") as string) || 0;
      cartItemData.totalPrice = currentQuantity * cartItemData.rate;
    }

    const updatedCartItem = await cartItem.update(cartItemData);

    return {
      success: true,
      data: updatedCartItem,
      message: "Cart item updated successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to update cart item: ${error.message}`);
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

export const deleteCartItemService = async (id: number) => {
  try {
    const cartItem = await CartItem.findByPk(id);

    if (!cartItem) {
      return {
        success: false,
        data: null,
        message: "Cart item not found",
      };
    }

    await cartItem.destroy();

    return {
      success: true,
      data: null,
      message: "Cart item deleted successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to delete cart item: ${error.message}`);
  }
};

export const clearCartService = async (cartId: number) => {
  try {
    const cart = await Cart.findByPk(cartId);

    if (!cart) {
      return {
        success: false,
        data: null,
        message: "Cart not found",
      };
    }

    await CartItem.destroy({
      where: { cartId },
    });

    return {
      success: true,
      data: null,
      message: "Cart cleared successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to clear cart: ${error.message}`);
  }
};
