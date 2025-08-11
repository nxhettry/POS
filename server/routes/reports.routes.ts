import { Router } from "express";
import {
  getSalesReportByDateRange,
  getExpensesReportByDateRange,
  getSalesAnalytics,
} from "../controllers/reports.controllers.js";

const router = Router();

// Get sales data for a date range
router.get("/sales", getSalesReportByDateRange);

// Get expenses data for a date range
router.get("/expenses", getExpensesReportByDateRange);

// Get comprehensive analytics for a date range
router.get("/analytics", getSalesAnalytics);

export default router;