import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import Daybook from "./daybook.models.js";

class DaybookTransaction extends Model {}

DaybookTransaction.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    daybookId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Daybook,
        key: "id",
      },
    },
    transactionType: {
      type: DataTypes.ENUM(
        "sale",
        "expense",
        "opening_balance",
        "closing_balance"
      ),
      allowNull: false,
    },
    paymentMode: {
      type: DataTypes.ENUM("cash", "online"),
      allowNull: false,
    },
    referenceId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: "Reference to sales, expenses, or other related records",
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    timestamp: {
      type: DataTypes.DATE,
      allowNull: false,
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
    modelName: "DaybookTransaction",
    tableName: "daybook_transactions",
    timestamps: true,
  }
);

DaybookTransaction.belongsTo(Daybook, { foreignKey: "daybookId" });
Daybook.hasMany(DaybookTransaction, { foreignKey: "daybookId" });

export default DaybookTransaction;
