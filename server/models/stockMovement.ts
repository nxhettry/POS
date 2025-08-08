import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import InventoryItem from "./inventoryItem.models.js";
import User from "./user.models.js";

class StockMovement extends Model {}

StockMovement.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    inventoryItemId: {
      type: DataTypes.INTEGER,
      references: {
        model: InventoryItem,
        key: "id",
      },
      allowNull: false,
    },
    type: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    quantity: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    unitCost: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    reference: {
      type: DataTypes.STRING,
    },
    notes: {
      type: DataTypes.STRING,
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    createdBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
    },
  },
  {
    sequelize,
    modelName: "StockMovement",
    tableName: "stock_movements",
    timestamps: false,
  }
);

StockMovement.belongsTo(InventoryItem, { foreignKey: "inventoryItemId" });
StockMovement.belongsTo(User, { foreignKey: "createdBy" });

export default StockMovement;
