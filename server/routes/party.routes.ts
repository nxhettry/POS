import { Router } from "express";
import {
  createParty,
  updateParty,
  getParty,
  getAllParties,
  getPartiesByType,
  getActiveParties,
  deleteParty,
  createPartyTransaction,
  updatePartyTransaction,
  getPartyTransaction,
  getAllPartyTransactions,
  getPartyTransactionsByParty,
  getPartyTransactionsByType,
  deletePartyTransaction,
} from "../controllers/party.controllers.js";

const router = Router();

router.post("/", createParty);
router.put("/:id", updateParty);
router.get("/:id", getParty);
router.get("/", getAllParties);
router.get("/type/:type", getPartiesByType);
router.get("/active/all", getActiveParties);
router.delete("/:id", deleteParty);

router.post("/transactions", createPartyTransaction);
router.put("/transactions/:id", updatePartyTransaction);
router.get("/transactions/:id", getPartyTransaction);
router.get("/transactions", getAllPartyTransactions);
router.get("/:partyId/transactions", getPartyTransactionsByParty);
router.get("/transactions/type/:type", getPartyTransactionsByType);
router.delete("/transactions/:id", deletePartyTransaction);

export default router;
