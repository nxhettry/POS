import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";

class Table extends Model {}

Table.init(
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
    status: {
      type: DataTypes.ENUM("available", "occupied", "reserved"),
      defaultValue: "available",
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
    modelName: "Table",
    tableName: "tables",
    timestamps: false,
  }
);

export default Table;
