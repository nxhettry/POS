import { Request, Response } from "express";
import {
  createUserService,
  updateUserService,
  getUserService,
  getAllUsersService,
  getUsersByRoleService,
  getActiveUsersService,
  getUserByUsernameService,
  validateUserCredentialsService,
  changePasswordService,
  deleteUserService,
} from "../service/user.service.js";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { AuthenticatedRequest } from "../middlewares/auth.middleware.js";

export const createUser = asyncHandler(async (req: Request, res: Response): Promise<any> => {
  const userData = req.body;

  if (!userData.username || !userData.password || !userData.role) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Username, password, and role are required"));
  }

  const result = await createUserService(userData);
  
  if (!result.success) {
    return res.status(400).json(new apiResponse(400, null, result.message));
  }

  return res.status(201).json(new apiResponse(201, result.data, result.message));
});

export const updateUser = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { id } = req.params;
  const userData = req.body;

  if (!id || isNaN(Number(id))) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid user ID is required"));
  }

  // Security check: Users can only update their own profile unless they're admin
  if (req.user?.role !== 'admin' && req.user?.userId !== Number(id)) {
    return res
      .status(403)
      .json(new apiResponse(403, null, "You can only update your own profile"));
  }

  const result = await updateUserService(Number(id), userData);

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getUser = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { id } = req.params;

  if (!id || isNaN(Number(id))) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid user ID is required"));
  }

  // Security check: Users can only view their own profile unless they're admin
  if (req.user?.role !== 'admin' && req.user?.userId !== Number(id)) {
    return res
      .status(403)
      .json(new apiResponse(403, null, "You can only view your own profile"));
  }

  const result = await getUserService(Number(id));

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getAllUsers = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  // Only admins can view all users
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  const result = await getAllUsersService();
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getUsersByRole = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { role } = req.params;

  // Only admins can view users by role
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  if (!role || !['admin', 'waiter', 'cashier'].includes(role)) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid role is required (admin, waiter, cashier)"));
  }

  const result = await getUsersByRoleService(role);
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getActiveUsers = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  // Only admins can view all active users
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  const result = await getActiveUsersService();
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getUserByUsername = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { username } = req.params;

  // Only admins can search users by username
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  const result = await getUserByUsernameService(username);

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const validateUserCredentials = asyncHandler(async (req: Request, res: Response): Promise<any> => {
  // This function should not be exposed as a public endpoint for security reasons
  return res.status(501).json(new apiResponse(501, null, "This endpoint has been disabled for security reasons"));
});

export const changePassword = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;

  if (!id || isNaN(Number(id))) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid user ID is required"));
  }

  // Security check: Users can only change their own password unless they're admin
  if (req.user?.role !== 'admin' && req.user?.userId !== Number(id)) {
    return res
      .status(403)
      .json(new apiResponse(403, null, "You can only change your own password"));
  }

  const result = await changePasswordService(Number(id), currentPassword, newPassword);

  if (!result.success) {
    return res.status(400).json(new apiResponse(400, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const deleteUser = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { id } = req.params;

  // Only admins can delete users
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  if (!id || isNaN(Number(id))) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid user ID is required"));
  }

  // Prevent self-deletion
  if (req.user?.userId === Number(id)) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "You cannot delete your own account"));
  }

  const result = await deleteUserService(Number(id));

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const toggleUserStatus = asyncHandler(async (req: AuthenticatedRequest, res: Response): Promise<any> => {
  const { id } = req.params;

  // Only admins can change user status
  if (req.user?.role !== 'admin') {
    return res
      .status(403)
      .json(new apiResponse(403, null, "Admin access required"));
  }

  if (!id || isNaN(Number(id))) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "Valid user ID is required"));
  }

  // Prevent self-deactivation
  if (req.user?.userId === Number(id)) {
    return res
      .status(400)
      .json(new apiResponse(400, null, "You cannot deactivate your own account"));
  }

  try {
    const user = await getUserService(Number(id));
    
    if (!user.success) {
      return res
        .status(404)
        .json(new apiResponse(404, null, "User not found"));
    }

    const newStatus = !user.data.isActive;
    const result = await updateUserService(Number(id), { isActive: newStatus });

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, `User ${newStatus ? 'activated' : 'deactivated'} successfully`));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  } catch (error: any) {
    return res
      .status(500)
      .json(new apiResponse(500, null, "Error updating user status"));
  }
});
