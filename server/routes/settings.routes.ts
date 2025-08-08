import { Router } from "express";
import { 
  editRestaurantDetails, 
  getRestaurantDetails,
  editSystemSettings,
  getSystemSettings,
  editBillSettings,
  getBillSettings
} from "../controllers/settings.controllers.js";

const router = Router();

// Restaurant settings routes
router.put("/restaurant", editRestaurantDetails);
router.get("/restaurant", getRestaurantDetails);

// System settings routes
router.put("/system", editSystemSettings);
router.get("/system", getSystemSettings);

// Bill settings routes
router.put("/bill", editBillSettings);
router.get("/bill", getBillSettings);

export default router;