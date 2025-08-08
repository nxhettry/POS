import SalesItem from "../models/salesItem.models.js";
import Sales from "../models/sales.models.js";
import MenuItem from "../models/menuItem.models.js";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createSalesItemService = async (
  salesItemData: any
): Promise<ServiceResponse<any>> => {
  // Calculate total price automatically
  if (salesItemData.quantity && salesItemData.rate) {
    salesItemData.totalPrice = salesItemData.quantity * salesItemData.rate;
  }

  const salesItem = await SalesItem.create(salesItemData);
  const salesItemWithIncludes = await SalesItem.findByPk((salesItem as any).id, {
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
  });

  return {
    success: true,
    data: salesItemWithIncludes,
    message: "Sales item created successfully",
  };
};

export const updateSalesItemService = async (
  id: number,
  salesItemData: any
): Promise<ServiceResponse<any>> => {
  const salesItem = await SalesItem.findByPk(id);
  if (!salesItem) {
    return {
      success: false,
      message: "Sales item not found",
    };
  }

  // Recalculate total price if quantity or rate is updated
  if (salesItemData.quantity || salesItemData.rate) {
    const currentData = salesItem.toJSON() as any;
    const newQuantity = salesItemData.quantity || currentData.quantity;
    const newRate = salesItemData.rate || currentData.rate;
    salesItemData.totalPrice = newQuantity * newRate;
  }

  await salesItem.update(salesItemData);
  const updatedSalesItem = await SalesItem.findByPk(id, {
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
  });

  return {
    success: true,
    data: updatedSalesItem,
    message: "Sales item updated successfully",
  };
};

export const getSalesItemService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const salesItem = await SalesItem.findByPk(id, {
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
  });

  if (!salesItem) {
    return {
      success: false,
      message: "Sales item not found",
    };
  }

  return {
    success: true,
    data: salesItem,
    message: "Sales item retrieved successfully",
  };
};

export const getAllSalesItemsService = async (): Promise<ServiceResponse<any[]>> => {
  const salesItems = await SalesItem.findAll({
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: salesItems,
    message: "Sales items retrieved successfully",
  };
};

export const getSalesItemsBySalesService = async (
  salesId: number
): Promise<ServiceResponse<any[]>> => {
  const salesItems = await SalesItem.findAll({
    where: {
      salesId: salesId,
    },
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
    order: [["createdAt", "ASC"]],
  });

  return {
    success: true,
    data: salesItems,
    message: `Sales items for sales ${salesId} retrieved successfully`,
  };
};

export const getSalesItemsByMenuItemService = async (
  itemId: number
): Promise<ServiceResponse<any[]>> => {
  const salesItems = await SalesItem.findAll({
    where: {
      itemId: itemId,
    },
    include: [
      { model: Sales, as: "Sales" },
      { model: MenuItem, as: "MenuItem" },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: salesItems,
    message: `Sales items for menu item ${itemId} retrieved successfully`,
  };
};

export const deleteSalesItemService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const salesItem = await SalesItem.findByPk(id);
  if (!salesItem) {
    return {
      success: false,
      message: "Sales item not found",
    };
  }

  await salesItem.destroy();
  return {
    success: true,
    data: null,
    message: "Sales item deleted successfully",
  };
};

export const deleteSalesItemsBySalesService = async (
  salesId: number
): Promise<ServiceResponse<any>> => {
  const deletedCount = await SalesItem.destroy({
    where: {
      salesId: salesId,
    },
  });

  return {
    success: true,
    data: { deletedCount },
    message: `${deletedCount} sales items deleted for sales ${salesId}`,
  };
};
