import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import Cart from "./cart.models.js";
import MenuItem from "./menuItem.models.js";

class CartItem extends Model {}

CartItem.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    cartId: {
      type: DataTypes.INTEGER,
      references: {
        model: Cart,
        key: "id",
      },
      allowNull: false,
    },
    itemId: {
      type: DataTypes.INTEGER,
      references: {
        model: MenuItem,
        key: "id",
      },
      allowNull: false,
    },
    quantity: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    rate: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    totalPrice: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    notes: {
      type: DataTypes.STRING,
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "CartItem",
    tableName: "cart_items",
    timestamps: false,
  }
);

CartItem.belongsTo(Cart, { foreignKey: "cartId" });
CartItem.belongsTo(MenuItem, { foreignKey: "itemId" });

export default CartItem;
