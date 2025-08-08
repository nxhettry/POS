import { Router } from "express";
import {
  createUser,
  updateUser,
  getUser,
  getAllUsers,
  getUsersByRole,
  getActiveUsers,
  getUserByUsername,
  changePassword,
  deleteUser,
  toggleUserStatus,
} from "../controllers/user.controllers.js";
import {
  validateUserRegistration,
  validateUserUpdate,
  validatePasswordChange,
  sanitizeInputs,
} from "../middlewares/validation.middleware.js";

const router = Router();

router.use(sanitizeInputs);

// All routes are public for offline application - no rate limiting
router.post(
  "/",
  validateUserRegistration,
  createUser
);

router.put(
  "/:id",
  validateUserUpdate,
  updateUser
);

router.get("/:id", getUser);

router.get("/", getAllUsers);

router.get("/role/:role", getUsersByRole);

router.get("/status/active", getActiveUsers);

router.get("/username/:username", getUserByUsername);

router.put(
  "/:id/change-password",
  validatePasswordChange,
  changePassword
);

router.patch("/:id/toggle-status", toggleUserStatus);

router.delete("/:id", deleteUser);

export default router;
