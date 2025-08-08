import { Router } from "express";
import {
  createInventoryItem,
  updateInventoryItem,
  getInventoryItem,
  getAllInventoryItems,
  getLowStockItems,
  deleteInventoryItem,
  createStockMovement,
  updateStockMovement,
  getStockMovement,
  getAllStockMovements,
  getStockMovementsByItem,
  deleteStockMovement,
} from "../controllers/inventory.controllers.js";

const router = Router();

router.get("/items/low-stock", getLowStockItems);
router.post("/items", createInventoryItem);
router.put("/items/:id", updateInventoryItem);
router.get("/items/:id", getInventoryItem);
router.get("/items", getAllInventoryItems);
router.delete("/items/:id", deleteInventoryItem);

router.post("/movements", createStockMovement);
router.put("/movements/:id", updateStockMovement);
router.get("/movements/:id", getStockMovement);
router.get("/movements", getAllStockMovements);
router.get("/items/:itemId/movements", getStockMovementsByItem);
router.delete("/movements/:id", deleteStockMovement);

export default router;