import { Router } from "express";
import {
  getTodaysSummary,
  getDaybookEntries,
  getDaybookSummary,
  getDaybookByDate,
} from "../controllers/daybook.controllers.js";

const router = Router();

// Apply auth middleware to all routes

// Get today's daybook summary
router.get("/today-summary", getTodaysSummary);

// Get daybook entries (with optional date range)
router.get("/entries", getDaybookEntries);

// Get daybook summary for a specific date
router.get("/summary/:date", getDaybookSummary);

// Get daybook by date
router.get("/date/:date", getDaybookByDate);

export default router;
