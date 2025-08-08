import { Router } from "express";
import {
  createPaymentMethod,
  updatePaymentMethod,
  getPaymentMethod,
  getAllPaymentMethods,
  getActivePaymentMethods,
  deletePaymentMethod,
} from "../controllers/payment-methods.controllers.js";

const router = Router();

router.post("/", createPaymentMethod);
router.put("/:id", updatePaymentMethod);
router.get("/:id", getPaymentMethod);
router.get("/", getAllPaymentMethods);
router.get("/active/all", getActivePaymentMethods);
router.delete("/:id", deletePaymentMethod);

export default router;
