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

const router = Router();

router.post("/", createUser);

router.put("/:id", updateUser);

router.get("/:id", getUser);

router.get("/", getAllUsers);

router.get("/role/:role", getUsersByRole);

router.get("/status/active", getActiveUsers);

router.get("/username/:username", getUserByUsername);

router.put("/:id/change-password", changePassword);

router.patch("/:id/toggle-status", toggleUserStatus);

router.delete("/:id", deleteUser);

export default router;
