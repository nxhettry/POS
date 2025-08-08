import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateMenuCategoryData } from "../validators/menuCategory.validator.js";
import { validateMenuItemData } from "../validators/menuItem.validator.js";
import {
  createMenuCategoryService,
  updateMenuCategoryService,
  getMenuCategoryService,
  getAllMenuCategoriesService,
  deleteMenuCategoryService,
} from "../service/menuCategory.service.js";
import {
  createMenuItemService,
  updateMenuItemService,
  getMenuItemService,
  getAllMenuItemsService,
  getMenuItemsByCategoryService,
  deleteMenuItemService,
} from "../service/menuItem.service.js";

export const createMenuCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const categoryData = req.body;

    if (!categoryData.name) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Category name is required"));
    }

    const validation = validateMenuCategoryData(categoryData);

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

    try {
      const result = await createMenuCategoryService(categoryData);

      if (result.success) {
        return res
          .status(201)
          .json(new apiResponse(201, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const updateMenuCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const categoryData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid category ID is required"));
    }

    const validation = validateMenuCategoryData(categoryData);

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

    try {
      const result = await updateMenuCategoryService(Number(id), categoryData);

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getMenuCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid category ID is required"));
    }

    try {
      const result = await getMenuCategoryService(Number(id));

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getAllMenuCategories = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
      const result = await getAllMenuCategoriesService();

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const deleteMenuCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid category ID is required"));
    }

    try {
      const result = await deleteMenuCategoryService(Number(id));

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const createMenuItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const itemData = req.body;

    if (!itemData.itemName || !itemData.categoryId || itemData.rate === undefined) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Item name, category ID, and rate are required"));
    }

    const validation = validateMenuItemData(itemData);

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

    try {
      const result = await createMenuItemService(itemData);

      if (result.success) {
        return res
          .status(201)
          .json(new apiResponse(201, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const updateMenuItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const itemData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid item ID is required"));
    }

    const validation = validateMenuItemData(itemData);

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

    try {
      const result = await updateMenuItemService(Number(id), itemData);

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getMenuItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid item ID is required"));
    }

    try {
      const result = await getMenuItemService(Number(id));

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getAllMenuItems = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
      const result = await getAllMenuItemsService();

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getMenuItemsByCategory = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { categoryId } = req.params;

    if (!categoryId || isNaN(Number(categoryId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid category ID is required"));
    }

    try {
      const result = await getMenuItemsByCategoryService(Number(categoryId));

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const deleteMenuItem = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid item ID is required"));
    }

    try {
      const result = await deleteMenuItemService(Number(id));

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);