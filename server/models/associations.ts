import Cart from "./cart.models.js";
import CartItem from "./cartItems.models.js";
import MenuItem from "./menuItem.models.js";
import Sales from "./sales.models.js";
import SalesItem from "./salesItem.models.js";

// Cart associations
Cart.hasMany(CartItem, { foreignKey: "cartId" });
CartItem.belongsTo(Cart, { foreignKey: "cartId" });
CartItem.belongsTo(MenuItem, { foreignKey: "itemId" });

// Sales associations
Sales.hasMany(SalesItem, { foreignKey: "salesId", as: "SalesItems" });
SalesItem.belongsTo(Sales, { foreignKey: "salesId" });

export { Cart, CartItem, MenuItem, Sales, SalesItem };
