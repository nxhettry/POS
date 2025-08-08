import { Router } from "express";
import {
  createTable,
  updateTable,
  getTable,
  getAllTables,
  deleteTable,
} from "../controllers/tables.controllers.js";

const router = Router();

router.post("/", createTable);
router.put("/:id", updateTable);
router.get("/:id", getTable);
router.get("/", getAllTables);
router.delete("/:id", deleteTable);

export default router;