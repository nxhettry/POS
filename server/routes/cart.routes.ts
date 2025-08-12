import { Router } from "express";
import {
  createCart,
  updateCart,
  getCart,
  getAllCarts,
  getCartsByStatus,
  getCartsByTable,
  deleteCart,
  createCartItem,
  updateCartItem,
  getCartItem,
  getAllCartItems,
  getCartItemsByCart,
  deleteCartItem,
  clearCart,
  addToCart,
  updateCartItems,
  checkoutCart,
} from "../controllers/cart.controllers.js";

const router = Router();

router.post("/add-to-cart", addToCart);
router.put("/update-items", updateCartItems);
router.post("/:cartId/checkout", checkoutCart);

router.get("/status/:status", getCartsByStatus);
router.get("/table/:tableId", getCartsByTable);
router.post("/", createCart);
router.put("/:id", updateCart);
router.get("/:id", getCart);
router.get("/", getAllCarts);
router.delete("/:id", deleteCart);

router.post("/items", createCartItem);
router.put("/items/:id", updateCartItem);
router.get("/items/:id", getCartItem);
router.get("/items", getAllCartItems);
router.get("/:cartId/items", getCartItemsByCart);
router.delete("/items/:id", deleteCartItem);
router.delete("/:cartId/clear", clearCart);

export default router;
