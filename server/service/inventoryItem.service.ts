import InventoryItem from "../models/inventoryItem.models.js";
import { Op } from "sequelize";
import sequelize from "../db/connection.js";

interface InventoryItemUpdateData {
  name?: string;
  unit?: string;
  currentStock?: number;
  minimumStock?: number;
  costPrice?: number;
  supplierId?: number;
}

interface InventoryItemCreateData {
  name: string;
  unit: string;
  currentStock?: number;
  minimumStock?: number;
  costPrice: number;
  supplierId?: number;
}

export const createInventoryItemService = async (
  itemData: InventoryItemCreateData
) => {
  try {
    const existingItem = await InventoryItem.findOne({
      where: {
        name: {
          [Op.iLike]: itemData.name.trim(),
        },
      },
    });

    if (existingItem) {
      return {
        success: false,
        data: null,
        message: "Inventory item with this name already exists",
      };
    }

    const newItem = await InventoryItem.create(itemData as any);
    return {
      success: true,
      data: newItem,
      message: "Inventory item created successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to create inventory item: ${error.message}`);
  }
};

export const updateInventoryItemService = async (
  id: number,
  itemData: InventoryItemUpdateData
) => {
  try {
    const item = await InventoryItem.findByPk(id);

    if (!item) {
      return {
        success: false,
        data: null,
        message: "Inventory item not found",
      };
    }

    if (itemData.name) {
      const existingItem = await InventoryItem.findOne({
        where: {
          name: {
            [Op.iLike]: itemData.name.trim(),
          },
          id: {
            [Op.ne]: id,
          },
        },
      });

      if (existingItem) {
        return {
          success: false,
          data: null,
          message: "Another inventory item with this name already exists",
        };
      }
    }

    const updatedItem = await item.update({
      ...itemData,
      lastStockUpdate:
        itemData.currentStock !== undefined
          ? new Date()
          : item.get("lastStockUpdate"),
    });

    return {
      success: true,
      data: updatedItem,
      message: "Inventory item updated successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to update inventory item: ${error.message}`);
  }
};

export const getInventoryItemService = async (id: number) => {
  try {
    const item = await InventoryItem.findByPk(id);

    if (!item) {
      return {
        success: false,
        data: null,
        message: "Inventory item not found",
      };
    }

    return {
      success: true,
      data: item,
      message: "Inventory item retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get inventory item: ${error.message}`);
  }
};

export const getAllInventoryItemsService = async () => {
  try {
    const items = await InventoryItem.findAll({
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: items,
      message: "Inventory items retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get inventory items: ${error.message}`);
  }
};

export const getLowStockItemsService = async () => {
  try {
    const items = await InventoryItem.findAll({
      where: sequelize.where(
        sequelize.col("currentStock"),
        "<=",
        sequelize.col("minimumStock")
      ),
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: items,
      message: "Low stock items retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get low stock items: ${error.message}`);
  }
};

export const deleteInventoryItemService = async (id: number) => {
  try {
    const item = await InventoryItem.findByPk(id);

    if (!item) {
      return {
        success: false,
        data: null,
        message: "Inventory item not found",
      };
    }

    await item.destroy();

    return {
      success: true,
      data: null,
      message: "Inventory item deleted successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to delete inventory item: ${error.message}`);
  }
};
