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
    invoiceNo: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    tableId: {
      type: DataTypes.INTEGER,
      references: {
        model: Table,
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
        model: PaymentMethod,
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
        model: Party,
        key: "id",
      },
    },
    createdBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
    },
    signedBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
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

Sales.belongsTo(User, { foreignKey: "createdBy" });
Sales.belongsTo(Table, { foreignKey: "tableId" });
Sales.belongsTo(PaymentMethod, { foreignKey: "paymentMethodId" });
Sales.belongsTo(Party, { foreignKey: "partyId" });

export default Sales;
