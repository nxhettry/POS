import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import ExpenseCategory from "./expenseCategories.js";
import PaymentMethod from "./paymentMethod.models.js";
import User from "./user.models.js";
import Party from "./party.models.js";

class Expense extends Model {}

Expense.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.STRING,
    },
    amount: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    paymentMethodId: {
      type: DataTypes.INTEGER,
      references: {
        model: PaymentMethod,
        key: "id",
      },
      allowNull: false,
    },
    date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    categoryId: {
      type: DataTypes.INTEGER,
      references: {
        model: ExpenseCategory,
        key: "id",
      },
      allowNull: false,
    },
    partyId: {
      type: DataTypes.INTEGER,
      references: {
        model: Party,
        key: "id",
      },
      allowNull: true,
    },
    receipt: {
      type: DataTypes.STRING,
    },
    createdBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: true,
    },
    approvedBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: true,
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
    modelName: "Expense",
    tableName: "expenses",
    timestamps: false,
  }
);

Expense.belongsTo(ExpenseCategory, { foreignKey: "categoryId" });
Expense.belongsTo(PaymentMethod, { foreignKey: "paymentMethodId" });
Expense.belongsTo(Party, { foreignKey: "partyId" });
Expense.belongsTo(User, { foreignKey: "createdBy" });
Expense.belongsTo(User, { foreignKey: "approvedBy" });

export default Expense;
