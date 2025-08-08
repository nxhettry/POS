import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";

class InventoryItem extends Model {}

InventoryItem.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    unit: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    currentStock: {
      type: DataTypes.DECIMAL,
      defaultValue: 0.0,
    },
    minimumStock: {
      type: DataTypes.DECIMAL,
      allowNull: true,
    },
    costPrice: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    supplierId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    lastStockUpdate: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "InventoryItem",
    tableName: "inventory_items",
    timestamps: true,
  }
);

export default InventoryItem;
