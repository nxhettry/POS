import { Router } from "express";
import {
  createMenuCategory,
  updateMenuCategory,
  getMenuCategory,
  getAllMenuCategories,
  deleteMenuCategory,
  createMenuItem,
  updateMenuItem,
  getMenuItem,
  getAllMenuItems,
  getMenuItemsByCategory,
  deleteMenuItem,
} from "../controllers/menu.controllers.js";

const router = Router();

router.post("/categories", createMenuCategory);
router.put("/categories/:id", updateMenuCategory);
router.get("/categories/:id", getMenuCategory);
router.get("/categories", getAllMenuCategories);
router.delete("/categories/:id", deleteMenuCategory);

router.post("/items", createMenuItem);
router.put("/items/:id", updateMenuItem);
router.get("/items/:id", getMenuItem);
router.get("/items", getAllMenuItems);
router.get("/categories/:categoryId/items", getMenuItemsByCategory);
router.delete("/items/:id", deleteMenuItem);

export default router;