import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import MenuItem from "./menuItem.models.js";

class SalesItem extends Model {}

SalesItem.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    salesId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    itemId: {
      type: DataTypes.INTEGER,
      references: {
        model: "menu_items",
        key: "id",
      },
      allowNull: false,
    },
    itemName: {
      type: DataTypes.STRING,
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
    modelName: "SalesItem",
    tableName: "sales_items",
    timestamps: false,
  }
);

SalesItem.belongsTo(MenuItem, { foreignKey: "itemId", as: "MenuItem" });

export default SalesItem;
