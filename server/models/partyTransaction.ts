import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import Party from "./party.models.js";
import User from "./user.models.js";

class PartyTransaction extends Model {}

PartyTransaction.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    partyId: {
      type: DataTypes.INTEGER,
      references: {
        model: Party,
        key: "id",
      },
      allowNull: false,
    },
    type: {
      type: DataTypes.ENUM("debit", "credit"),
      allowNull: false,
    },
    amount: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    balanceBefore: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    balanceAfter: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    reference: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    description: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    createdBy: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: false,
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: "PartyTransaction",
    tableName: "party_transactions",
    timestamps: false,
  }
);

PartyTransaction.belongsTo(Party, { foreignKey: "partyId" });
PartyTransaction.belongsTo(User, { foreignKey: "createdBy" });

export default PartyTransaction;
