import { NextFunction, Request, Response } from "express";

export interface AuthenticatedRequest extends Request {
  userId: number;
  role: string;
}

export const authenticate = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.cookies;

    console.log("Token ", token);
    
    
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token"
    });
  }
};
