import { Router } from "express";
import userRoutes from "./user.routes.js";
import cartRoutes from "./cart.routes.js";
import salesRoutes from "./sales.routes.js";
import salesItemRoutes from "./salesItem.routes.js";
import partyRoutes from "./party.routes.js";
import expenseRoutes from "./expenses.routes.js";
import expenseCategoryRoutes from "./expenseCategory.routes.js";
import paymentMethodRoutes from "./payment-methods.routes.js";
import settingsRoutes from "./settings.routes.js";
import userSessionRoutes from "./userSession.routes.js";
import menuRoutes from "./menu.routes.js";
import inventoryRoutes from "./inventory.routes.js";
import tablesRoutes from "./tables.routes.js";
import reportsRoutes from "./reports.routes.js";

const router = Router();

router.use("/users", userRoutes);
router.use("/cart", cartRoutes);
router.use("/sales", salesRoutes);
router.use("/sales-items", salesItemRoutes);
router.use("/parties", partyRoutes);
router.use("/expenses", expenseRoutes);
router.use("/expense-categories", expenseCategoryRoutes);
router.use("/payment-methods", paymentMethodRoutes);
router.use("/settings", settingsRoutes);
router.use("/user-sessions", userSessionRoutes);
router.use("/menu", menuRoutes);
router.use("/inventory", inventoryRoutes);
router.use("/tables", tablesRoutes);
router.use("/reports", reportsRoutes);

export default router;
