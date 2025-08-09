import { Router } from "express";
import {
  createUserSession,
  updateUserSession,
  getUserSession,
  getAllUserSessions,
  getUserSessionsByUserId,
  getActiveSessions,
  getActiveSessionsByUser,
  getSessionsByDateRange,
  endUserSession,
  endAllActiveSessionsForUser,
  deleteUserSession,
} from "../controllers/userSession.controllers.js";
import {
  validateCreateUserSession,
  validateUpdateUserSession,
} from "../validators/userSession.validator.js";

const router = Router();

router.post("/", validateCreateUserSession, createUserSession);

router.put("/:id", validateUpdateUserSession, updateUserSession);

router.get("/:id", getUserSession);

router.get("/", getAllUserSessions);

router.get("/user/:userId", getUserSessionsByUserId);

router.get("/status/active", getActiveSessions);

router.get("/user/:userId/active", getActiveSessionsByUser);

router.get("/date-range", getSessionsByDateRange);

router.patch("/:id/end", endUserSession);

router.patch("/user/:userId/end-all", endAllActiveSessionsForUser);

router.delete("/:id", deleteUserSession);

export default router;
