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


router.put("/restaurant", editRestaurantDetails);
router.get("/restaurant", getRestaurantDetails);


router.put("/system", editSystemSettings);
router.get("/system", getSystemSettings);


router.put("/bill", editBillSettings);
router.get("/bill", getBillSettings);

export default router;