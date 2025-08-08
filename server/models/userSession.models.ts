import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import User from "./user.models.js";

class UserSession extends Model {}

UserSession.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: false,
    },
    loginTime: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    logoutTime: {
      type: DataTypes.DATE,
    },
    ipAddress: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    deviceInfo: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    sequelize,
    modelName: "UserSession",
    tableName: "user_sessions",
    timestamps: false,
  }
);

UserSession.belongsTo(User, { foreignKey: "userId" });

export default UserSession;
