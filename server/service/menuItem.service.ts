import MenuItem from "../models/menuItem.models.js";
import MenuCategory from "../models/menuCategory.models.js";

interface MenuItemUpdateData {
  categoryId?: number;
  itemName?: string;
  description?: string;
  rate?: number;
  image?: string;
  isAvailable?: boolean;
}

interface MenuItemCreateData {
  categoryId: number;
  itemName: string;
  description?: string;
  rate: number;
  image?: string;
  isAvailable?: boolean;
}

export const createMenuItemService = async (itemData: MenuItemCreateData) => {
  try {
    const newItem = await MenuItem.create(itemData as any);
    return {
      success: true,
      data: newItem,
      message: "Menu item created successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to create menu item: ${error.message}`);
  }
};

export const updateMenuItemService = async (id: number, itemData: MenuItemUpdateData) => {
  try {
    const item = await MenuItem.findByPk(id);
    
    if (!item) {
      return {
        success: false,
        data: null,
        message: "Menu item not found"
      };
    }

    const updatedItem = await item.update(itemData);
    
    return {
      success: true,
      data: updatedItem,
      message: "Menu item updated successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to update menu item: ${error.message}`);
  }
};

export const getMenuItemService = async (id: number) => {
  try {
    const item = await MenuItem.findByPk(id, {
      include: [MenuCategory]
    });
    
    if (!item) {
      return {
        success: false,
        data: null,
        message: "Menu item not found"
      };
    }

    return {
      success: true,
      data: item,
      message: "Menu item retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get menu item: ${error.message}`);
  }
};

export const getAllMenuItemsService = async () => {
  try {
    const items = await MenuItem.findAll({
      include: [MenuCategory],
      order: [['id', 'ASC']]
    });

    return {
      success: true,
      data: items,
      message: "Menu items retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get menu items: ${error.message}`);
  }
};

export const getMenuItemsByCategoryService = async (categoryId: number) => {
  try {
    const items = await MenuItem.findAll({
      where: { categoryId },
      include: [MenuCategory],
      order: [['id', 'ASC']]
    });

    return {
      success: true,
      data: items,
      message: "Menu items retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get menu items by category: ${error.message}`);
  }
};

export const deleteMenuItemService = async (id: number) => {
  try {
    const item = await MenuItem.findByPk(id);
    
    if (!item) {
      return {
        success: false,
        data: null,
        message: "Menu item not found"
      };
    }

    await item.destroy();
    
    return {
      success: true,
      data: null,
      message: "Menu item deleted successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to delete menu item: ${error.message}`);
  }
};
