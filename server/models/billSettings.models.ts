import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";

class BillSettings extends Model {}

BillSettings.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    includeTax: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    includeDiscount: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    printCustomerCopy: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    printKitchenCopy: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    showItemCode: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    billFooter: {
      type: DataTypes.STRING,
      defaultValue: "Thank you for visiting!",
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "BillSettings",
    tableName: "bill_settings",
    timestamps: true,
  }
);

export default BillSettings;
