import { Router } from "express";
import {
  createExpense,
  updateExpense,
  getExpense,
  getAllExpenses,
  getExpensesByCategory,
  getExpensesByParty,
  getExpensesByCreator,
  getExpensesByDateRange,
  getApprovedExpenses,
  getPendingExpenses,
  deleteExpense,
} from "../controllers/expenses.controllers.js";

const router = Router();

router.post("/", createExpense);
router.get(
  "/date-range",
  getExpensesByDateRange
);
router.get("/category/:categoryId", getExpensesByCategory);
router.get("/creator/:createdBy", getExpensesByCreator);
router.get("/party/:partyId", getExpensesByParty);
router.put("/:id", updateExpense);
router.get("/:id", getExpense);
router.get("/", getAllExpenses);
router.get("/approved/all", getApprovedExpenses);
router.get("/pending/all", getPendingExpenses);
router.delete("/:id", deleteExpense);

export default router;
