import UserSession from "../models/userSession.models.js";
import { Op } from "sequelize";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createUserSessionService = async (
  sessionData: any
): Promise<ServiceResponse<any>> => {
  const session = await UserSession.create(sessionData);

  return {
    success: true,
    data: session,
    message: "User session created successfully",
  };
};

export const updateUserSessionService = async (
  id: number,
  sessionData: any
): Promise<ServiceResponse<any>> => {
  const session = await UserSession.findByPk(id);
  if (!session) {
    return {
      success: false,
      message: "User session not found",
    };
  }

  await session.update(sessionData);

  return {
    success: true,
    data: session,
    message: "User session updated successfully",
  };
};

export const getUserSessionService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const session = await UserSession.findByPk(id, {
    include: ['User']
  });

  if (!session) {
    return {
      success: false,
      message: "User session not found",
    };
  }

  return {
    success: true,
    data: session,
    message: "User session retrieved successfully",
  };
};

export const getAllUserSessionsService = async (): Promise<ServiceResponse<any[]>> => {
  const sessions = await UserSession.findAll({
    include: ['User'],
    order: [["loginTime", "DESC"]],
  });

  return {
    success: true,
    data: sessions,
    message: "User sessions retrieved successfully",
  };
};

export const getUserSessionsByUserIdService = async (
  userId: number
): Promise<ServiceResponse<any[]>> => {
  const sessions = await UserSession.findAll({
    where: {
      userId: userId,
    },
    include: ['User'],
    order: [["loginTime", "DESC"]],
  });

  return {
    success: true,
    data: sessions,
    message: "User sessions retrieved successfully",
  };
};

export const getActiveSessionsService = async (): Promise<ServiceResponse<any[]>> => {
  const sessions = await UserSession.findAll({
    where: {
      logoutTime: null,
    },
    include: ['User'],
    order: [["loginTime", "DESC"]],
  });

  return {
    success: true,
    data: sessions,
    message: "Active sessions retrieved successfully",
  };
};

export const getActiveSessionsByUserService = async (
  userId: number
): Promise<ServiceResponse<any[]>> => {
  const sessions = await UserSession.findAll({
    where: {
      userId: userId,
      logoutTime: null,
    },
    include: ['User'],
    order: [["loginTime", "DESC"]],
  });

  return {
    success: true,
    data: sessions,
    message: "Active user sessions retrieved successfully",
  };
};

export const getSessionsByDateRangeService = async (
  startDate: Date,
  endDate: Date
): Promise<ServiceResponse<any[]>> => {
  const sessions = await UserSession.findAll({
    where: {
      loginTime: {
        [Op.between]: [startDate, endDate],
      },
    },
    include: ['User'],
    order: [["loginTime", "DESC"]],
  });

  return {
    success: true,
    data: sessions,
    message: "Sessions retrieved successfully",
  };
};

export const endUserSessionService = async (
  id: number,
  logoutTime?: Date
): Promise<ServiceResponse<any>> => {
  const session = await UserSession.findByPk(id);
  if (!session) {
    return {
      success: false,
      message: "User session not found",
    };
  }

  await session.update({
    logoutTime: logoutTime || new Date(),
  });

  return {
    success: true,
    data: session,
    message: "User session ended successfully",
  };
};

export const endAllActiveSessionsForUserService = async (
  userId: number,
  logoutTime?: Date
): Promise<ServiceResponse<any>> => {
  const activeSessions = await UserSession.findAll({
    where: {
      userId: userId,
      logoutTime: null,
    },
  });

  if (activeSessions.length === 0) {
    return {
      success: true,
      data: null,
      message: "No active sessions found for user",
    };
  }

  await UserSession.update(
    { logoutTime: logoutTime || new Date() },
    {
      where: {
        userId: userId,
        logoutTime: null,
      },
    }
  );

  return {
    success: true,
    data: { endedSessions: activeSessions.length },
    message: "All active sessions ended successfully",
  };
};

export const deleteUserSessionService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const session = await UserSession.findByPk(id);
  if (!session) {
    return {
      success: false,
      message: "User session not found",
    };
  }

  await session.destroy();
  return {
    success: true,
    data: null,
    message: "User session deleted successfully",
  };
};
