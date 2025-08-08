import Cart from "../models/cart.models.js";
import User from "../models/user.models.js";
import CartItem from "../models/cartItems.models.js";
import MenuItem from "../models/menuItem.models.js";

interface CartUpdateData {
  tableId?: number;
  userId?: number;
  status?: "open" | "closed" | "cancelled";
}

interface CartCreateData {
  tableId: number;
  userId?: number;
  status?: "open" | "closed" | "cancelled";
}

export const createCartService = async (cartData: CartCreateData) => {
  try {
    const newCart = await Cart.create(cartData as any);
    return {
      success: true,
      data: newCart,
      message: "Cart created successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to create cart: ${error.message}`);
  }
};

export const updateCartService = async (id: number, cartData: CartUpdateData) => {
  try {
    const cart = await Cart.findByPk(id);
    
    if (!cart) {
      return {
        success: false,
        data: null,
        message: "Cart not found"
      };
    }

    const updatedCart = await cart.update(cartData);
    
    return {
      success: true,
      data: updatedCart,
      message: "Cart updated successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to update cart: ${error.message}`);
  }
};

export const getCartService = async (id: number) => {
  try {
    const cart = await Cart.findByPk(id, {
      include: [
        User,
        {
          model: CartItem,
          include: [MenuItem]
        }
      ]
    });
    
    if (!cart) {
      return {
        success: false,
        data: null,
        message: "Cart not found"
      };
    }

    return {
      success: true,
      data: cart,
      message: "Cart retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get cart: ${error.message}`);
  }
};

export const getAllCartsService = async () => {
  try {
    const carts = await Cart.findAll({
      include: [User],
      order: [['id', 'DESC']]
    });

    return {
      success: true,
      data: carts,
      message: "Carts retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts: ${error.message}`);
  }
};

export const getCartsByStatusService = async (status: "open" | "closed" | "cancelled") => {
  try {
    const carts = await Cart.findAll({
      where: { status },
      include: [User],
      order: [['id', 'DESC']]
    });

    return {
      success: true,
      data: carts,
      message: "Carts retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts by status: ${error.message}`);
  }
};

export const getCartsByTableService = async (tableId: number) => {
  try {
    const carts = await Cart.findAll({
      where: { tableId },
      include: [
        User,
        {
          model: CartItem,
          include: [MenuItem]
        }
      ],
      order: [['id', 'DESC']]
    });

    return {
      success: true,
      data: carts,
      message: "Carts retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts by table: ${error.message}`);
  }
};

export const deleteCartService = async (id: number) => {
  try {
    const cart = await Cart.findByPk(id);
    
    if (!cart) {
      return {
        success: false,
        data: null,
        message: "Cart not found"
      };
    }

    await cart.destroy();
    
    return {
      success: true,
      data: null,
      message: "Cart deleted successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to delete cart: ${error.message}`);
  }
};
