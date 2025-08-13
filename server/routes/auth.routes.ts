import { Router } from "express";
import {
  login,
  logout,
  getProfile,
  refreshToken,
} from "../controllers/auth.controllers.js";
import { validateUserLogin } from "../middlewares/validation.middleware.js";

const router = Router();

// Public routes (no authentication required)
router.post("/login", validateUserLogin, login);
router.post("/refresh", refreshToken);

// Protected routes (authentication required)
router.get("/logout", logout);
router.get("/profile", getProfile);

export default router;
