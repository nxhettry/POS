import User from "../models/user.models.js";
import {
  hashPassword,
  comparePassword,
  validatePasswordStrength,
} from "../utils/security.js";
import { Op } from "sequelize";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createUserService = async (
  userData: any
): Promise<ServiceResponse<any>> => {
  try {
    const passwordValidation = validatePasswordStrength(userData.password);
    if (!passwordValidation.isValid) {
      return {
        success: false,
        message: `Password validation failed: ${passwordValidation.errors.join(
          ", "
        )}`,
      };
    }

    const existingUser = await User.findOne({
      where: { username: userData.username },
    });

    if (existingUser) {
      return {
        success: false,
        message: "Username already exists",
      };
    }

    const hashedPassword = await hashPassword(userData.password);

    const user = await User.create({
      ...userData,
      password: hashedPassword,
    });

    const userResponse = { ...user.toJSON() };
    delete userResponse.password;

    return {
      success: true,
      data: userResponse,
      message: "User created successfully",
    };
  } catch (error: any) {
    return {
      success: false,
      message: `Error creating user: ${error.message}`,
    };
  }
};

export const updateUserService = async (
  id: number,
  userData: any
): Promise<ServiceResponse<any>> => {
  try {
    const user = await User.findByPk(id);
    if (!user) {
      return {
        success: false,
        message: "User not found",
      };
    }

    if (userData.username) {
      const existingUser = await User.findOne({
        where: {
          username: userData.username,
          id: { [Op.ne]: id },
        },
      });

      if (existingUser) {
        return {
          success: false,
          message: "Username already exists",
        };
      }
    }

    const updateData = { ...userData };
    delete updateData.password;

    await user.update(updateData);

    const userResponse = { ...user.toJSON() };
    delete userResponse.password;

    return {
      success: true,
      data: userResponse,
      message: "User updated successfully",
    };
  } catch (error: any) {
    return {
      success: false,
      message: `Error updating user: ${error.message}`,
    };
  }
};

export const getUserService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const user = await User.findByPk(id, {
    attributes: { exclude: ["password"] },
  });

  if (!user) {
    return {
      success: false,
      message: "User not found",
    };
  }

  return {
    success: true,
    data: user,
    message: "User retrieved successfully",
  };
};

export const getAllUsersService = async (): Promise<ServiceResponse<any[]>> => {
  const users = await User.findAll({
    attributes: { exclude: ["password"] },
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: users,
    message: "Users retrieved successfully",
  };
};

export const getUsersByRoleService = async (
  role: string
): Promise<ServiceResponse<any[]>> => {
  const users = await User.findAll({
    where: {
      role: role,
    },
    attributes: { exclude: ["password"] },
    order: [["username", "ASC"]],
  });

  return {
    success: true,
    data: users,
    message: `Users with role ${role} retrieved successfully`,
  };
};

export const getActiveUsersService = async (): Promise<
  ServiceResponse<any[]>
> => {
  const users = await User.findAll({
    where: {
      isActive: true,
    },
    attributes: { exclude: ["password"] },
    order: [["username", "ASC"]],
  });

  return {
    success: true,
    data: users,
    message: "Active users retrieved successfully",
  };
};

export const getUserByUsernameService = async (
  username: string
): Promise<ServiceResponse<any>> => {
  const user = await User.findOne({
    where: {
      username: username,
    },
    attributes: { exclude: ["password"] },
  });

  if (!user) {
    return {
      success: false,
      message: "User not found",
    };
  }

  return {
    success: true,
    data: user,
    message: "User retrieved successfully",
  };
};

export const validateUserCredentialsService = async (
  username: string,
  password: string
): Promise<ServiceResponse<any>> => {
  try {
    const user = await User.findOne({
      where: {
        username: username,
        isActive: true,
      },
    });

    if (!user) {
      return {
        success: false,
        message: "Invalid credentials",
      };
    }

    const userJson = user.toJSON() as any;

    const isPasswordValid = await comparePassword(password, userJson.password);

    if (!isPasswordValid) {
      return {
        success: false,
        message: "Invalid credentials",
      };
    }

    const userResponse = { ...userJson };
    delete userResponse.password;

    return {
      success: true,
      data: userResponse,
      message: "User authenticated successfully",
    };
  } catch (error: any) {
    return {
      success: false,
      message: `Authentication error: ${error.message}`,
    };
  }
};

export const changePasswordService = async (
  id: number,
  currentPassword: string,
  newPassword: string
): Promise<ServiceResponse<any>> => {
  try {
    const passwordValidation = validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      return {
        success: false,
        message: `Password validation failed: ${passwordValidation.errors.join(
          ", "
        )}`,
      };
    }

    const user = await User.findByPk(id);
    if (!user) {
      return {
        success: false,
        message: "User not found",
      };
    }

    const userJson = user.toJSON() as any;

    const isCurrentPasswordValid = await comparePassword(
      currentPassword,
      userJson.password
    );

    if (!isCurrentPasswordValid) {
      return {
        success: false,
        message: "Current password is incorrect",
      };
    }

    const hashedNewPassword = await hashPassword(newPassword);
    await user.update({ password: hashedNewPassword });

    return {
      success: true,
      data: null,
      message: "Password changed successfully",
    };
  } catch (error: any) {
    return {
      success: false,
      message: `Error changing password: ${error.message}`,
    };
  }
};

export const deleteUserService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const user = await User.findByPk(id);
  if (!user) {
    return {
      success: false,
      message: "User not found",
    };
  }

  await user.destroy();
  return {
    success: true,
    data: null,
    message: "User deleted successfully",
  };
};
