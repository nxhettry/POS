import Cart from "../models/cart.models.js";
import User from "../models/user.models.js";
import CartItem from "../models/cartItems.models.js";
import MenuItem from "../models/menuItem.models.js";
import sequelize from "../db/connection.js";
import {
  CartItemCreateData,
  CartItemUpdateData,
  createCartItemService,
} from "./cartItem.service.js";

interface CartUpdateData {
  tableId?: number;
  createdBy?: number;
  status?: "open" | "closed" | "cancelled";
}

interface CartCreateData {
  tableId: number;
  createdBy?: number;
  status?: "open" | "closed" | "cancelled";
  items?: CartItemCreateData[];
}

export const createCartService = async (cartData: CartCreateData) => {
  const transaction = await sequelize.transaction();

  try {
    if (cartData.tableId) {
      const isCartPresent = await Cart.findOne({
        where: {
          tableId: cartData.tableId,
          status: "open",
        },
        transaction,
      });

      if (isCartPresent) {
        const cartItemsObj: CartItemCreateData[] | [] =
          cartData.items?.map((item) => ({
            ...item,
            cartId: isCartPresent.dataValues.id as number,
          })) || [];

        const existingCartItems = await CartItem.findAll({
          where: {
            cartId: isCartPresent.dataValues.id,
          },
          transaction,
        });

        const existingItemsMap = new Map<number, any>();
        existingCartItems.forEach((item) => {
          existingItemsMap.set(item.dataValues.itemId, item.dataValues);
        });

        const itemsToUpdate: CartItemUpdateData[] = [];
        const itemsToCreate: CartItemCreateData[] = [];

        cartItemsObj.forEach((newItem) => {
          if (existingItemsMap.has(newItem.itemId)) {
            const existingItem = existingItemsMap.get(newItem.itemId)!;
            itemsToUpdate.push({
              id: existingItem.id,
              quantity: newItem.quantity,
              totalPrice: newItem.quantity * newItem.rate,
            });
          } else {
            itemsToCreate.push(newItem);
          }
        });

        if (itemsToUpdate.length > 0) {
          await Promise.all(
            itemsToUpdate.map((item) =>
              CartItem.update(
                {
                  quantity: item.quantity,
                  totalPrice: item.totalPrice,
                },
                {
                  where: { id: item.id },
                  transaction,
                }
              )
            )
          );
        }

        if (itemsToCreate.length > 0) {
          await createCartItemService(itemsToCreate, transaction);
        }

        await transaction.commit();
        return {
          success: true,
          data: isCartPresent,
          message: "Cart updated successfully",
        };
      }
    }

    const newCart = await Cart.create(cartData as any, { transaction });

    const cartId = newCart.dataValues.id as number;
    if (!cartId) {
      throw new Error("Failed to create cart");
    }

    console.log("\n\n\nNew Cart : ", newCart);

    const cartItemsObj: CartItemCreateData[] | [] =
      cartData.items?.map((item) => ({
        ...item,
        cartId,
      })) || [];

    console.log("\n\n\nCart items object : ", cartItemsObj);

    console.log("\n\n\nNow creating cart items ...");
    const cartItems = await createCartItemService(cartItemsObj, transaction);

    console.log("\n\n\nCart itmes : ", cartItems);
    if (!cartItems) {
      throw new Error("Failed to create cart items");
    }

    await transaction.commit();
    return {
      success: true,
      data: newCart,
      message: "Cart created successfully",
    };
  } catch (error: any) {
    await transaction.rollback();
    throw new Error(`Failed to create cart: ${error.message}`);
  }
};

export const updateCartService = async (
  id: number,
  cartData: CartUpdateData
) => {
  const transaction = await sequelize.transaction();

  try {
    const cart = await Cart.findByPk(id, { transaction });

    if (!cart) {
      await transaction.rollback();
      return {
        success: false,
        data: null,
        message: "Cart not found",
      };
    }

    const updatedCart = await cart.update(cartData, { transaction });

    await transaction.commit();
    return {
      success: true,
      data: updatedCart,
      message: "Cart updated successfully",
    };
  } catch (error: any) {
    await transaction.rollback();
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
          include: [MenuItem],
        },
      ],
    });

    if (!cart) {
      return {
        success: false,
        data: null,
        message: "Cart not found",
      };
    }

    return {
      success: true,
      data: cart,
      message: "Cart retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get cart: ${error.message}`);
  }
};

export const getAllCartsService = async () => {
  try {
    const carts = await Cart.findAll({
      include: [User],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: carts,
      message: "Carts retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts: ${error.message}`);
  }
};

export const getCartsByStatusService = async (
  status: "open" | "closed" | "cancelled"
) => {
  try {
    const carts = await Cart.findAll({
      where: { status },
      include: [User],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: carts,
      message: "Carts retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts by status: ${error.message}`);
  }
};

export const getCartsByTableService = async (tableId: number) => {
  try {
    const data = await Cart.findAll({
      where: {
        tableId,
        status: "open",
      },
      include: [
        User,
        {
          model: CartItem,
          include: [MenuItem],
        },
      ],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: data,
      message: "Carts retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get carts by table: ${error.message}`);
  }
};

export const deleteCartService = async (id: number) => {
  const transaction = await sequelize.transaction();

  try {
    const cart = await Cart.findByPk(id, { transaction });

    if (!cart) {
      await transaction.rollback();
      return {
        success: false,
        data: null,
        message: "Cart not found",
      };
    }

    await cart.destroy({ transaction });

    await transaction.commit();
    return {
      success: true,
      data: null,
      message: "Cart deleted successfully",
    };
  } catch (error: any) {
    await transaction.rollback();
    throw new Error(`Failed to delete cart: ${error.message}`);
  }
};
