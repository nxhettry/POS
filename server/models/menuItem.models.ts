import { Model, DataTypes } from "sequelize";
import sequelize from "../db/connection.js";
import MenuCategory from "./menuCategory.models.js";

class MenuItem extends Model {}

MenuItem.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    categoryId: {
      type: DataTypes.INTEGER,
      references: {
        model: MenuCategory,
        key: "id",
      },
    },
    itemName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    rate: {
      type: DataTypes.DECIMAL,
      allowNull: false,
    },
    image: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    isAvailable: {
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
    modelName: "MenuItem",
    tableName: "menu_items",
    timestamps: true,
  }
);

MenuItem.belongsTo(MenuCategory, { foreignKey: "categoryId" });

export default MenuItem;
