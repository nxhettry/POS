import { Router } from "express";
import {
  createSales,
  updateSales,
  getSales,
  getAllSales,
  getSalesByOrderStatus,
  getSalesByPaymentStatus,
  getSalesByTable,
  getSalesByParty,
  deleteSales,
  getNextInvoiceNumber,
} from "../controllers/sales.controllers.js";

const router = Router();

router.get("/next-invoice-number", getNextInvoiceNumber);
router.post("/", createSales);
router.put("/:id", updateSales);
router.get("/:id", getSales);
router.get("/", getAllSales);
router.get("/order-status/:status", getSalesByOrderStatus);
router.get("/payment-status/:status", getSalesByPaymentStatus);
router.get("/table/:tableId", getSalesByTable);
router.get("/party/:partyId", getSalesByParty);
router.delete("/:id", deleteSales);

export default router;
