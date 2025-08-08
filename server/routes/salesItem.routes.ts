import { Router } from "express";
import {
  createSalesItem,
  updateSalesItem,
  getSalesItem,
  getAllSalesItems,
  getSalesItemsBySales,
  getSalesItemsByMenuItem,
  deleteSalesItem,
  deleteSalesItemsBySales,
} from "../controllers/salesItem.controllers.js";

const router = Router();

router.post("/", createSalesItem);
router.put("/:id", updateSalesItem);
router.get("/:id", getSalesItem);
router.get("/", getAllSalesItems);
router.get("/sales/:salesId", getSalesItemsBySales);
router.get("/menu-item/:itemId", getSalesItemsByMenuItem);
router.delete("/:id", deleteSalesItem);
router.delete("/sales/:salesId/all", deleteSalesItemsBySales);

export default router;
