import {
  createUserSessionService,
  updateUserSessionService,
  getUserSessionService,
  getAllUserSessionsService,
  getUserSessionsByUserIdService,
  getActiveSessionsService,
  getActiveSessionsByUserService,
  getSessionsByDateRangeService,
  endUserSessionService,
  endAllActiveSessionsForUserService,
  deleteUserSessionService,
} from "../service/userSession.service.js";
import { asyncHandler, apiResponse } from "../utils/api.js";

export const createUserSession = asyncHandler(async (req: any, res: any) => {
  const result = await createUserSessionService(req.body);
  
  if (!result.success) {
    return res.status(400).json(new apiResponse(400, null, result.message));
  }

  return res.status(201).json(new apiResponse(201, result.data, result.message));
});

export const updateUserSession = asyncHandler(async (req: any, res: any) => {
  const { id } = req.params;
  const result = await updateUserSessionService(Number(id), req.body);

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getUserSession = asyncHandler(async (req: any, res: any) => {
  const { id } = req.params;
  const result = await getUserSessionService(Number(id));

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getAllUserSessions = asyncHandler(async (req: any, res: any) => {
  const result = await getAllUserSessionsService();
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getUserSessionsByUserId = asyncHandler(async (req: any, res: any) => {
  const { userId } = req.params;
  const result = await getUserSessionsByUserIdService(Number(userId));
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getActiveSessions = asyncHandler(async (req: any, res: any) => {
  const result = await getActiveSessionsService();
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getActiveSessionsByUser = asyncHandler(async (req: any, res: any) => {
  const { userId } = req.params;
  const result = await getActiveSessionsByUserService(Number(userId));
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const getSessionsByDateRange = asyncHandler(async (req: any, res: any) => {
  const { startDate, endDate } = req.query;
  const result = await getSessionsByDateRangeService(new Date(startDate as string), new Date(endDate as string));
  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const endUserSession = asyncHandler(async (req: any, res: any) => {
  const { id } = req.params;
  const { logoutTime } = req.body;
  const result = await endUserSessionService(Number(id), logoutTime ? new Date(logoutTime) : undefined);

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const endAllActiveSessionsForUser = asyncHandler(async (req: any, res: any) => {
  const { userId } = req.params;
  const { logoutTime } = req.body;
  const result = await endAllActiveSessionsForUserService(Number(userId), logoutTime ? new Date(logoutTime) : undefined);

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});

export const deleteUserSession = asyncHandler(async (req: any, res: any) => {
  const { id } = req.params;
  const result = await deleteUserSessionService(Number(id));

  if (!result.success) {
    return res.status(404).json(new apiResponse(404, null, result.message));
  }

  return res.status(200).json(new apiResponse(200, result.data, result.message));
});
