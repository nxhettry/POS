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
import { validateCreateUserSession, validateUpdateUserSession } from "../validators/userSession.validator.js";

const router = Router();

// Create user session
router.post("/", validateCreateUserSession, createUserSession);

// Update user session
router.put("/:id", validateUpdateUserSession, updateUserSession);

// Get user session by ID
router.get("/:id", getUserSession);

// Get all user sessions
router.get("/", getAllUserSessions);

// Get sessions by user ID
router.get("/user/:userId", getUserSessionsByUserId);

// Get all active sessions
router.get("/status/active", getActiveSessions);

// Get active sessions by user
router.get("/user/:userId/active", getActiveSessionsByUser);

// Get sessions by date range
router.get("/date-range", getSessionsByDateRange);

// End user session (logout)
router.patch("/:id/end", endUserSession);

// End all active sessions for a user
router.patch("/user/:userId/end-all", endAllActiveSessionsForUser);

// Delete user session
router.delete("/:id", deleteUserSession);

export default router;
