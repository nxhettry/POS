import MenuCategory from "../models/menuCategory.models.js";

interface MenuCategoryUpdateData {
  name?: string;
  description?: string;
  isActive?: boolean;
}

interface MenuCategoryCreateData {
  name: string;
  description?: string;
  isActive?: boolean;
}

export const createMenuCategoryService = async (categoryData: MenuCategoryCreateData) => {
  try {
    const newCategory = await MenuCategory.create(categoryData as any);
    return {
      success: true,
      data: newCategory,
      message: "Menu category created successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to create menu category: ${error.message}`);
  }
};

export const updateMenuCategoryService = async (id: number, categoryData: MenuCategoryUpdateData) => {
  try {
    const category = await MenuCategory.findByPk(id);
    
    if (!category) {
      return {
        success: false,
        data: null,
        message: "Menu category not found"
      };
    }

    const updatedCategory = await category.update(categoryData);
    
    return {
      success: true,
      data: updatedCategory,
      message: "Menu category updated successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to update menu category: ${error.message}`);
  }
};

export const getMenuCategoryService = async (id: number) => {
  try {
    const category = await MenuCategory.findByPk(id);
    
    if (!category) {
      return {
        success: false,
        data: null,
        message: "Menu category not found"
      };
    }

    return {
      success: true,
      data: category,
      message: "Menu category retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get menu category: ${error.message}`);
  }
};

export const getAllMenuCategoriesService = async () => {
  try {
    const categories = await MenuCategory.findAll({
      order: [['id', 'ASC']]
    });

    return {
      success: true,
      data: categories,
      message: "Menu categories retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get menu categories: ${error.message}`);
  }
};

export const deleteMenuCategoryService = async (id: number) => {
  try {
    const category = await MenuCategory.findByPk(id);
    
    if (!category) {
      return {
        success: false,
        data: null,
        message: "Menu category not found"
      };
    }

    await category.destroy();
    
    return {
      success: true,
      data: null,
      message: "Menu category deleted successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to delete menu category: ${error.message}`);
  }
};
