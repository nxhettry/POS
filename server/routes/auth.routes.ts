import { Router } from "express";
import {
  login,
  logout,
  getProfile,
  refreshToken,
} from "../controllers/auth.controllers.js";
import { authenticate } from "../middlewares/auth.middleware.js";
import { validateUserLogin } from "../middlewares/validation.middleware.js";

const router = Router();

router.post("/login", validateUserLogin, login);
router.post("/refresh", refreshToken);

router.get("/logout", authenticate, logout);
router.get("/profile", authenticate, getProfile);

export default router;
