import { Request, Response } from "express";
import { validateUserCredentialsService } from "../service/user.service.js";
import {
  createUserSessionService,
  getCurrentActiveSessionService,
} from "../service/userSession.service.js";
import {
  generateTokens,
  getClientIP,
  getDeviceInfo,
} from "../utils/security.js";
import { asyncHandler, apiResponse } from "../utils/api.js";

export const login = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { username, password } = req.body;

    if (!username || !password) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Username and password are required"));
    }

    const userValidation = await validateUserCredentialsService(
      username,
      password
    );

    if (!userValidation.success) {
      return res
        .status(401)
        .json(new apiResponse(401, null, userValidation.message));
    }

    const user = userValidation.data;

    try {
      const tokens = generateTokens({
        userId: user.id,
        username: user.username,
        role: user.role,
      });

      const sessionData = {
        userId: user.id,
        loginTime: new Date(),
        ipAddress: getClientIP(req),
        deviceInfo: getDeviceInfo(req),
        isActive: true,
      };

      const sessionResult = await createUserSessionService(sessionData);

      if (!sessionResult.success) {
        return res
          .status(500)
          .json(new apiResponse(500, null, "Failed to create user session"));
      }

      const responseData = {
        user: {
          id: user.id,
          username: user.username,
          role: user.role,
          email: user.email,
          phone: user.phone,
          isActive: user.isActive,
        },
      };

      return res
        .status(200)
        .cookie("accessToken", tokens.accessToken, {
          httpOnly: true,
          secure: true,
          maxAge: 1000 * 60 * 60 * 24,
          sameSite: "none",
        })
        .json(new apiResponse(200, responseData, "Login successful"));
    } catch (error: any) {
      return res
        .status(500)
        .json(new apiResponse(500, null, `Login error: ${error.message}`));
    }
  }
);

export const logout = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { userId, role } = req as any;

    if (!userId) {
      return res
        .status(401)
        .json(new apiResponse(401, null, "Authentication required"));
    }

    res.clearCookie("accessToken");
    return res
      .status(200)
      .json(new apiResponse(200, null, "Logout successful"));
  }
);

export const getProfile = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { userId, role } = req as any;
    if (!userId) {
      return res
        .status(401)
        .json(new apiResponse(401, null, "Authentication required"));
    }

    try {
      const sessionResult = await getCurrentActiveSessionService(
        userId,
        getClientIP(req),
        getDeviceInfo(req)
      );

      const profileData = {
        userId: userId,
        role: role,
        sessionInfo: sessionResult.success
          ? {
              id: sessionResult.data.id,
              loginTime: sessionResult.data.loginTime,
              ipAddress: sessionResult.data.ipAddress,
              deviceInfo: sessionResult.data.deviceInfo,
              isActive: true,
            }
          : {
              isActive: false,
              message: "No active session found",
            },
      };

      return res
        .status(200)
        .json(
          new apiResponse(200, profileData, "Profile retrieved successfully")
        );
    } catch (error: any) {
      return res
        .status(500)
        .json(new apiResponse(500, null, `Profile error: ${error.message}`));
    }
  }
);

export const refreshToken = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Refresh token is required"));
    }

    return res
      .status(501)
      .json(
        new apiResponse(
          501,
          null,
          "Refresh token functionality not yet implemented"
        )
      );
  }
);
