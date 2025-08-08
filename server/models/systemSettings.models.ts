import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";

class SystemSettings extends Model {}

SystemSettings.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    currency: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    dateFormat: {
      type: DataTypes.ENUM("YYYY-MM-DD", "DD-MM-YYYY"),
      defaultValue: "YYYY-MM-DD",
    },
    language: {
      type: DataTypes.ENUM("en", "np"),
      defaultValue: "en",
    },
    defaultTaxRate: {
      type: DataTypes.DECIMAL,
      defaultValue: 0.0,
    },
    autoBackup: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    sessionTimeout: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "SystemSettings",
    tableName: "system_settings",
    timestamps: true,
  }
);

export default SystemSettings;
