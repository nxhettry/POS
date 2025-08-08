import { Router } from "express";
import {
  createInventoryItem,
  updateInventoryItem,
  getInventoryItem,
  getAllInventoryItems,
  getLowStockItems,
  deleteInventoryItem,
  createStockMovement,
  getAllStockMovements,
  getStockMovementsByItem,
} from "../controllers/inventory.controllers.js";

const router = Router();

router.get("/items/low-stock", getLowStockItems);
router.post("/items", createInventoryItem);
router.put("/items/:id", updateInventoryItem);
router.get("/items/:id", getInventoryItem);
router.get("/items", getAllInventoryItems);
router.delete("/items/:id", deleteInventoryItem);

router.post("/movements", createStockMovement);
router.get("/movements", getAllStockMovements);
router.get("/items/:itemId/movements", getStockMovementsByItem);

export default router;