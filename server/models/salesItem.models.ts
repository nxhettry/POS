import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import Sales from "./sales.models.js";
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
      references: {
        model: Sales,
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

SalesItem.belongsTo(Sales, { foreignKey: "salesId" });
SalesItem.belongsTo(MenuItem, { foreignKey: "itemId" });

export default SalesItem;
