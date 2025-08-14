import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import User from "./user.models.js";
import Table from "./table.model.js";
import PaymentMethod from "./paymentMethod.models.js";
import Party from "./party.models.js";

class Sales extends Model {}

Sales.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    tableId: {
      type: DataTypes.INTEGER,
      references: {
        model: "tables",
        key: "id",
      },
    },
    orderType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    orderStatus: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    paymentStatus: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    paymentMethodId: {
      type: DataTypes.INTEGER,
      references: {
        model: "payment_methods",
        key: "id",
      },
    },
    subTotal: {
      type: DataTypes.DECIMAL,
    },
    tax: {
      type: DataTypes.DECIMAL,
    },
    total: {
      type: DataTypes.DECIMAL,
    },
    partyId: {
      type: DataTypes.INTEGER,
      references: {
        model: "parties",
        key: "id",
      },
      defaultValue: 1,
    },
    createdBy: {
      type: DataTypes.INTEGER,
      references: {
        model: "users",
        key: "id",
      },
    },
    signedBy: {
      type: DataTypes.INTEGER,
      references: {
        model: "users",
        key: "id",
      },
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
    modelName: "Sales",
    tableName: "sales",
    timestamps: true,
  }
);

Sales.belongsTo(User, { foreignKey: "createdBy", as: "User" });
Sales.belongsTo(Table, { foreignKey: "tableId", as: "Table" });
Sales.belongsTo(PaymentMethod, { foreignKey: "paymentMethodId", as: "PaymentMethod" });
Sales.belongsTo(Party, { foreignKey: "partyId", as: "Party" });

export default Sales;
