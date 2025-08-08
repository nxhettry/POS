import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";

class PaymentMethod extends Model {}

PaymentMethod.init(
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
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
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
    modelName: "PaymentMethod",
    tableName: "payment_methods",
    timestamps: false,
  }
);

export default PaymentMethod;
