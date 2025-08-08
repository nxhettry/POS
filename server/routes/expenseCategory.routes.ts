import { Router } from "express";
import {
  createExpenseCategory,
  updateExpenseCategory,
  getExpenseCategory,
  getAllExpenseCategories,
  getActiveExpenseCategories,
  deleteExpenseCategory,
} from "../controllers/expenseCategory.controllers.js";

const router = Router();

router.post("/", createExpenseCategory);
router.put("/:id", updateExpenseCategory);
router.get("/:id", getExpenseCategory);
router.get("/", getAllExpenseCategories);
router.get("/active/all", getActiveExpenseCategories);
router.delete("/:id", deleteExpenseCategory);

export default router;
