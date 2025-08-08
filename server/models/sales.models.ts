import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import User from "./user.models.js";

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
      allowNull: false,
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
      allowNull: false,
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
      allowNull: false,
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
    timestamps: false,
  }
);

Sales.belongsTo(User, { foreignKey: "createdBy" });

export default Sales;
